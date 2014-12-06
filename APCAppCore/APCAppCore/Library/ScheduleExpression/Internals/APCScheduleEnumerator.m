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
@property (nonatomic, assign) NSInteger     year;

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
		NSArray* calendarUnits = @[ @(NSCalendarUnitYear),
									@(NSCalendarUnitMonth),
									@(NSCalendarUnitDay),
									@(NSCalendarUnitHour),
									@(NSCalendarUnitMinute),
									@(NSCalendarUnitTimeZone),
									@(NSCalendarUnitCalendar) ];

		NSDateComponents* beginComponents = [NSDateComponents components: calendarUnits
												  inGregorianUTCFromDate: begin];

		_beginningMoment	= begin;
		_endingMoment		= end;
		_year				= beginComponents.year;

		APCTimeSelectorEnumerator* minuteEnumerator = [minuteSelector enumeratorBeginningAt:@(beginComponents.minute)];
		APCTimeSelectorEnumerator* hourEnumerator   = [hourSelector   enumeratorBeginningAt:@(beginComponents.hour)];


		// Track these three enumerators individually, so that
		// when we roll over the month or year, we can recompute
		// the days of the month specified by our weekday selector.
		self.dayEnumerator   = [dayOfMonthSelector enumeratorBeginningAt:@(beginComponents.day)];
		self.monthEnumerator = [monthSelector      enumeratorBeginningAt:@(beginComponents.month)];
		self.yearEnumerator  = [yearSelector       enumeratorBeginningAt:@(beginComponents.year)];

		/*
		 Creating these arrays in the SAME ORDER:  kMinuteIndex, kHourIndex, kDayIndex, kMonthIndex, kYearIndex.
		 */
		_calendarComponents	= [ @[ @(beginComponents.minute),
								   @(beginComponents.hour),
								   @(beginComponents.day),
								   @(beginComponents.month),
								   @(beginComponents.year)] mutableCopy];

		_enumerators = [ @[ minuteEnumerator,
						    hourEnumerator,
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
		

		// Now compute the days of the month for the actual, specified
		// month and year.  We do the same thing each time through
		// -nextObject, below.
		[self recomputeDaysAfterRollingOverMonthOrYearStartingOnDay: @(beginComponents.day)];


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
			 If we rolled over the month or year, tell the day iterator
			 about it, so it can figure out what the "days of the week"
			 mean for this month and year.
			 */
			if (enumerator == self.monthEnumerator || enumerator == self.yearEnumerator)
			{
				/*
				 The "nil" parameter means:  roll over to the first
				 legal day in the next month.  (The alternative is to
				 skip through that month until we find a particular
				 day; we do that during initialization.)
				 */
				[self recomputeDaysAfterRollingOverMonthOrYearStartingOnDay: nil];
			}

			/*
			 Aaaaaaand we're done:  we found a dateComponent
			 we could increment, so we've found a nextMoment,
			 and can stop looking.
			 */
        }
        else
        {
            //  Rollover the current enumerator and move to the next one.
            //  Enumerators (0 ... ndx - 1) have already been rolled over
			//  at this point.
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
    
    return savedMoment;
}

- (void) recomputeDaysAfterRollingOverMonthOrYearStartingOnDay: (NSNumber *) startDay
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
		day = self.dayEnumerator.nextObjectAfterRollover;

	else if ([selector matches: startDay])
		day = startDay;

	else
		day = [selector nextMomentAfter: startDay];

	self.calendarComponents [kDayIndex] = day;
}

- (NSDate*) componentsToDate
{
	NSDateComponents *components = [NSDateComponents componentsInGregorianUTC];
	components.year     = [self.calendarComponents [kYearIndex]   integerValue];
    components.month    = [self.calendarComponents [kMonthIndex]  integerValue];
    components.day      = [self.calendarComponents [kDayIndex]    integerValue];
    components.hour     = [self.calendarComponents [kHourIndex]   integerValue];
    components.minute   = [self.calendarComponents [kMinuteIndex] integerValue];
    
    return [components date];
}

@end
