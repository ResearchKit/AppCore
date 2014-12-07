// 
//  APCScheduleEnumerator.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCScheduleEnumerator.h"
#import "APCTimeSelectorEnumerator.h"
#import "APCDayOfMonthSelector.h"
#import "NSDateComponents+Helper.h"


/** We may make this a parameter, at some point. */
#define CONVERT_TO_LOCAL_TIME_ZONE_WHEN_EMITTING_ENUMERATED_DATES  NO


static NSInteger    kMinuteIndex = 0;
static NSInteger    kHourIndex   = 1;
static NSInteger    kDayIndex    = 2;
static NSInteger    kMonthIndex  = 3;
static NSInteger    kYearIndex   = 4;


@interface APCScheduleEnumerator ()

@property (nonatomic, strong) NSDate*       beginningMoment;
@property (nonatomic, strong) NSDate*       endingMoment;
@property (nonatomic, strong) NSDate*       nextMoment;
@property (nonatomic, strong) NSString*		originalCronExpression;		// for debug-printouts only.

/**
 These two variables must be the same length and contain
 corresponding items in the same sequence.
 */
@property (nonatomic, strong) NSMutableArray*   enumerators;           //  array of APCTimeSelectorEnumerator
@property (nonatomic, strong) NSMutableArray*   calendarComponents;    //  arrray of NSNumbers

/**
 These variables let us figure out if we just rolled over
 the month or year, so we can then recompute the days.
 */
@property (nonatomic, strong) APCTimeSelectorEnumerator *dayEnumerator;
@property (nonatomic, strong) APCTimeSelectorEnumerator *monthEnumerator;
@property (nonatomic, strong) APCTimeSelectorEnumerator *yearEnumerator;
@property (nonatomic, strong) APCTimeSelectorEnumerator *hourEnumerator;
@property (nonatomic, strong) APCTimeSelectorEnumerator *minuteEnumerator;

/**
 If we're converting to the user's local time zone (or any other
 time zone), this will contain the offset.  We'll use this
 both to convert the incoming start/stop dates and the outbound
 enumerated dates.
 */
@property (nonatomic, assign) NSTimeInterval timeZoneOffset;

@end


@implementation APCScheduleEnumerator

- (instancetype)initWithBeginningTime:(NSDate*)begin
                       minuteSelector:(APCTimeSelector*)minuteSelector
                         hourSelector:(APCTimeSelector*)hourSelector
                   dayOfMonthSelector:(APCTimeSelector*)dayOfMonthSelector
                        monthSelector:(APCTimeSelector*)monthSelector
                         yearSelector:(APCTimeSelector*)yearSelector
{
    return [self initWithBeginningTime:begin
                            endingTime:nil
                        minuteSelector:minuteSelector
                          hourSelector:hourSelector
                    dayOfMonthSelector:dayOfMonthSelector
                         monthSelector:monthSelector
                          yearSelector:yearSelector];
}

- (instancetype)initWithBeginningTime:(NSDate*)begin
                           endingTime:(NSDate*)end
                       minuteSelector:(APCTimeSelector*)minuteSelector
                         hourSelector:(APCTimeSelector*)hourSelector
                   dayOfMonthSelector:(APCTimeSelector*)dayOfMonthSelector
                        monthSelector:(APCTimeSelector*)monthSelector
                         yearSelector:(APCTimeSelector*)yearSelector
{
	self = [super init];

	if (self)
	{
		/*
		 If we're going to convert internal dates to the user's
		 local time zone when we emit them, we can also expect
		 the inbound dates to be in the user's local time zone.
		 So:  Convert them to UTC.
		 */
		self.timeZoneOffset = 0;

		if (CONVERT_TO_LOCAL_TIME_ZONE_WHEN_EMITTING_ENUMERATED_DATES)
		{
			NSDate *referenceDate = begin ?: [NSDate date];
			NSTimeZone *zone = [NSTimeZone localTimeZone];
			NSTimeInterval timeZoneOffset = [zone secondsFromGMTForDate: referenceDate];

			self.timeZoneOffset = timeZoneOffset;

			if (begin != nil)
				begin = [NSDate dateWithTimeIntervalSince1970: begin.timeIntervalSince1970 + timeZoneOffset];

			if (end != nil)
				end = [NSDate dateWithTimeIntervalSince1970: end.timeIntervalSince1970 + timeZoneOffset];
		}

		NSArray* calendarUnits = @[ @(NSCalendarUnitYear),
									@(NSCalendarUnitMonth),
									@(NSCalendarUnitDay),
									@(NSCalendarUnitHour),
									@(NSCalendarUnitMinute),
									@(NSCalendarUnitTimeZone),
									@(NSCalendarUnitCalendar),
									];

		NSDateComponents *beginComponents = [NSDateComponents components: calendarUnits inGregorianLocalFromDate: begin];

		_beginningMoment	= begin;
		_endingMoment		= end;


		// Track these three enumerators individually, so that
		// when we roll over the month or year, we can recompute
		// the days of the month specified by our weekday selector.
		self.yearEnumerator		= [yearSelector		enumeratorBeginningAt: @(beginComponents.year)];
		self.monthEnumerator	= [monthSelector	enumeratorBeginningAt: @(beginComponents.month)];
		self.hourEnumerator		= [hourSelector		enumeratorBeginningAt: @(beginComponents.hour)];
		self.minuteEnumerator	= [minuteSelector	enumeratorBeginningAt: @(beginComponents.minute)];


		// The day-of-month selector is special:  it needs to know
		// the month and year.
		APCDayOfMonthSelector *realDayOfMonthSelector = (APCDayOfMonthSelector *) dayOfMonthSelector;

		[realDayOfMonthSelector recomputeDaysBasedOnMonth: @(beginComponents.month)
													 year: @(beginComponents.year)];

		self.dayEnumerator = [dayOfMonthSelector enumeratorBeginningAt: @(beginComponents.day)];

		
		/*
		 Creating these arrays in the SAME ORDER: 
		 kMinuteIndex, kHourIndex, kDayIndex, kMonthIndex, kYearIndex.
		 */
		_calendarComponents	= [ @[ @(beginComponents.minute),
								   @(beginComponents.hour),
								   @(beginComponents.day),
								   @(beginComponents.month),
								   @(beginComponents.year)] mutableCopy];

		_enumerators = [ @[ self.minuteEnumerator,
						    self.hourEnumerator,
						    self.dayEnumerator,
						    self.monthEnumerator,
						    self.yearEnumerator] mutableCopy];
		

		//  Prime the enumerators to their first valid value. If a given enumerator's first valid value is
		//  greater than the corresponding given `begin` component then all lower granularity components are
		//  reset to the selector's first valid value.
		//
		//	Start with the year enumerator; end with the minute enumerator.
		NSInteger index = kYearIndex;
		do
		{
			APCTimeSelectorEnumerator* enumerator = _enumerators [index];
			NSNumber* firstEnumeratedValue = enumerator.nextObject;

			if (firstEnumeratedValue == nil)
			{
				// No valid values for the enumeration sequence.
				// This is an exception -- it should never happen.
				self = nil;
				break;
			}
			
			else
			{
				NSNumber* thisCalendarComponent = _calendarComponents [index];
				NSComparisonResult comparison = [firstEnumeratedValue compare: thisCalendarComponent];
				BOOL enumeratorValueIsCalendarStartValue = (comparison == NSOrderedSame);
				BOOL enumeratorValueIsLaterThanCalendarValue = (comparison == NSOrderedDescending);

				if (enumeratorValueIsCalendarStartValue)
				{
					--index;
				}

				else if (enumeratorValueIsLaterThanCalendarValue)
				{
					_calendarComponents [index] = firstEnumeratedValue;

					for (--index; index >= kMinuteIndex; --index)
					{
						enumerator = _enumerators [index];
						firstEnumeratedValue = [enumerator reset];
						_calendarComponents [index] = firstEnumeratedValue;
					}
				}

				else
				{
					// Enumerator value is earlier than calendar value.
					// This is an exception -- it should never happen.
					self = nil;
					break;
				}
			}
		} while (index >= kMinuteIndex);

		self.nextMoment = [self componentsToDate];

		// Have we passed the end date?
		if ([self.nextMoment compare:self.endingMoment] == NSOrderedDescending)  // meaning:  if (self.next > self.end) { ... }
		{
			self.nextMoment = nil;
		}
	}

	return self;
}


/**
 This method is the core of how iteration happens.  Each
 time we hit this method, increment the "minutes" field to
 the next legal minute.  If that rolls over (from 59 to 0,
 say, by returning "nil"), reset it to its starting point,
 and increment the "hours" field.  If "hours" rolls over,
 increment "days."  And so on, up through "years."

 The catch:  when we roll over a month or year, we have to
 recompute all the days in the new month-and-year
 combination.  It might not matter, except that:

 - the day-of-month selector might specify days up through
   31, even if the current month only has 28, 29, or 30 days

 - the day-of-week selector specifies weekdays (Monday,
   Friday, etc.), but we need a list of actual dates, and
   those change every month
 
 So after we roll over a month and/or year, we'll feed the
 new month and year to our day-of-month enumerator, so that
 the next time we iterate through it, it gives us the right
 dates for "Tuesday" (or whatever weekdays it represents).
 */
- (NSDate*) nextObject
{
    NSDate*   savedMoment		= self.nextMoment;
    NSNumber* nextPoint			= nil;
    NSInteger enumeratorIndex	= kMinuteIndex;

    do
    {
		APCTimeSelectorEnumerator *enumerator = self.enumerators [enumeratorIndex];
        nextPoint = [enumerator nextObject];
        
        if (nextPoint != nil)
        {
            self.calendarComponents [enumeratorIndex] = nextPoint;

			/*
			 If we rolled over the month or year, recompute the
			 days we care about for this month and year.
			 */
			if (enumeratorIndex == kMonthIndex || enumeratorIndex == kYearIndex)
			{
				APCDayOfMonthSelector *selector = (APCDayOfMonthSelector *) self.dayEnumerator.selector;

				[selector recomputeDaysBasedOnMonth: self.calendarComponents [kMonthIndex]
											   year: self.calendarComponents [kYearIndex]];

				self.dayEnumerator = [selector enumeratorBeginningAt: nil];
				self.enumerators [kDayIndex] = self.dayEnumerator;

				NSNumber *nextDay = [self.dayEnumerator nextObject];
				self.calendarComponents [kDayIndex] = nextDay;
			}

			/*
			 Aaaaaaand we're done:  we found a dateComponent
			 we could increment, so we've found a nextMoment,
			 and can stop looking.
			 */
        }
        else
        {
            /*
			 Rollover the current enumerator and move to the next one.
			 Enumerators (0 ... index - 1) have already been rolled over
			 at this point.

			 Note that if the enumerator we're about to roll over is the
			 dayOfMonth enumerator, its "rolled over" value will be wrong,
			 by definition:  we're rolling over into a new month, and any
			 rules for calculating days of the month (like "every other
			 Monday") will have to be reevaluated.  We'll do that shortly,
			 in the above part of this "if" statement, after rolling over
			 to the new month or year.
			 */
			NSNumber* firstMomentForThisEnumerator = [enumerator nextObjectAfterRollover];
            self.calendarComponents [enumeratorIndex] = firstMomentForThisEnumerator;
            ++enumeratorIndex;
        }
    } while (nextPoint == nil && enumeratorIndex <= kYearIndex);
    
    self.nextMoment = [self componentsToDate];
    
	// Have we passed the end date?
	if ([self.nextMoment compare:self.endingMoment] == NSOrderedDescending)  // meaning:  if (self.next > self.end) { ... }
    {
        self.nextMoment = nil;
    }

	// The catch:  the user is expecting dates in local time.
	// Our calculations have been in UTC (London, without
	// daylight savings).  Convert.  (Eventually:  make this
	// an init parameter?)
    NSDate* localDate = savedMoment;
    
    if (localDate != nil && CONVERT_TO_LOCAL_TIME_ZONE_WHEN_EMITTING_ENUMERATED_DATES)
    {
		localDate = [NSDate dateWithTimeIntervalSince1970: localDate.timeIntervalSince1970 - self.timeZoneOffset];
    }

    return localDate;
}

/**
 Retruns the next legal day after the rollover.
 If the start day is past that day, returns nil.
 */
- (NSNumber *) recomputeDaysAfterRollingOverMonthOrYearStartingOnDay: (NSNumber *) startDay
{
	APCDayOfMonthSelector *selector = (APCDayOfMonthSelector *) self.dayEnumerator.selector;

	NSNumber *month = self.calendarComponents [kMonthIndex];
	NSNumber *year  = self.calendarComponents [kYearIndex];

	[selector recomputeDaysBasedOnMonth: month
								   year: year];


	// Create and prime a new enumerator, as we did during -init.
	self.dayEnumerator = [selector enumeratorBeginningAt: startDay];
	self.enumerators [kDayIndex] = self.dayEnumerator;
	[self.dayEnumerator nextObject];

	NSNumber *day = nil;

	if (startDay == nil)
		day = self.dayEnumerator.nextObjectAfterRollover;		// i.e., selector.initialValue

	else if ([selector matches: startDay])
		day = startDay;

	else
	{
		// If the startDay is after the last legal day in this month,
		// this will return nil.  That's fine.
		day = [selector nextMomentAfter: startDay];
	}

	return day;
}

- (NSDate*) componentsToDate
{
	NSDateComponents *components = [NSDateComponents componentsInGregorianLocal];
	
	components.year     = [self.calendarComponents [kYearIndex]   integerValue];
    components.month    = [self.calendarComponents [kMonthIndex]  integerValue];
    components.day      = [self.calendarComponents [kDayIndex]    integerValue];
    components.hour     = [self.calendarComponents [kHourIndex]   integerValue];
    components.minute   = [self.calendarComponents [kMinuteIndex] integerValue];
    
    return [components date];
}

@end
