// 
//  APCScheduleEnumerator.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCScheduleEnumerator.h"
#import "APCTimeSelectorEnumerator.h"
#import "APCDayOfMonthSelector.h"

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

@property (nonatomic, strong) NSCalendar*       calendar;
@property (nonatomic, assign) NSInteger         year;

/**
 These two variables must be the same length and contain
 corresponding items in the same sequence.
 */
@property (nonatomic, strong) NSArray*          enumerators;    //  array of APCTimeSelectorEnumerator
@property (nonatomic, strong) NSMutableArray*   componenets;    //  arrray of NSNumbers

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
        NSDateComponents*   beginComponents = nil;
        NSCalendarUnit      calendarUnits   = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
        
        _beginningMoment = begin;
        _endingMoment    = end;
        
        _calendar       = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        beginComponents = [_calendar components:calendarUnits fromDate:begin];
        _year           = beginComponents.year;
        _componenets    = [NSMutableArray arrayWithArray:@[@(beginComponents.minute),
                                                           @(beginComponents.hour),
                                                           @(beginComponents.day),
                                                           @(beginComponents.month),
                                                           @(beginComponents.year)]];
        
        APCTimeSelectorEnumerator* minuteEnumerator = [minuteSelector enumeratorBeginningAt:@(beginComponents.minute)];
        APCTimeSelectorEnumerator* hourEnumerator   = [hourSelector   enumeratorBeginningAt:@(beginComponents.hour)];


		// Track these three enumerators individually, so that
		// when we roll over the month or year, we can recompute
		// the days of the month specified by our weekday selector.
        self.dayEnumerator   = [dayOfMonthSelector enumeratorBeginningAt:@(beginComponents.day)];
        self.monthEnumerator = [monthSelector      enumeratorBeginningAt:@(beginComponents.month)];
        self.yearEnumerator  = [yearSelector       enumeratorBeginningAt:@(beginComponents.year)];

		
        _enumerators = @[minuteEnumerator, hourEnumerator, self.dayEnumerator, self.monthEnumerator, self.yearEnumerator];
        

        //  Prime the enumerators to their first valid value. If a given enumerator's first valid value is
        //  greater than the corresponding given `begin` component then all lower granularity components are
        //  reset to the selector's first valid value.
        NSInteger   ndx = _enumerators.count - 1;
        do
        {
            NSNumber*   value = [_enumerators[ndx] nextObject];
            
            if (value == nil)
            {
                //  No valid values for the enumeration sequence
                self = nil;
                break;
            }
            else
            {
                NSComparisonResult  comparison = [value compare:_componenets[ndx]];
                if (comparison == NSOrderedSame)
                {
                    _componenets[ndx] = value;
                    --ndx;
                }
                else if (comparison == NSOrderedDescending)
                {
                    _componenets[ndx] = value;
                    for (--ndx; ndx >= 0; --ndx)
                    {
                        _componenets[ndx] = [_enumerators[ndx] reset];
                    }
                }
                else
                {
                    //  Exception: shouldn't happen.
                    self = nil;
                    break;
                }
            }
        } while (ndx >= 0);
        

		// Now compute the days of the month for the actual, specified
		// month and year.  We do the same thing each time through
		// -nextObject, below.
		[self recomputeDaysAfterRollingOverMonthOrYear];


        _nextMoment = [self componentsToDate];
    }
    
    return self;
}


/**
 Ron:  this method seems to contain the core of how iteration
 happens.  E.g., this is where we say:
 -	roll over to the next minute

 -	if we've gotten to the last minute -- if the minute
	iterator returns nil -- "reset" that enumerator (a
	custom method) and roll the next-outermost enumerator
	to its next object
 */
- (NSDate*)nextObject
{
    NSDate*   savedMoment		= self.nextMoment;
    NSNumber* nextPoint			= nil;
    NSInteger enumeratorIndex	= 0;


	/*
	 The point:  each time we hit this method, increment the "minutes"
	 field to the next legal minute.  If that rolls over (from 59 to 0,
	 say), reset it to its starting point, and increment the "hours"
	 field.  If "hours" rolls over, increment "days."  And so on, up 
	 through "years."
	 
	 The catch:  when we roll over the "day" iterator, that actually
	 means we just moved from one month to the next month (and, if
	 it was December, the next year).  One of our optional "day" specifiers
	 is "weekdays."  If the weekday specifier says something like "every
	 Tuesday," that means different dates for March 2014 and April 2014.
	 So after we roll over a month and/or year, we'll feed the new month
	 and year to our day-of-month enumerator, to make sure that the next
	 time we iterate through it, it gives us the right dates for
	 "Tuesday" (or whatever weekdays it represents).
	 
	 Ed wrote the code for paragraph 1.
	 Ron amended it to support paragraph 2.
	 */
    do
    {
		APCTimeSelectorEnumerator *enumerator = self.enumerators [enumeratorIndex];
        nextPoint = [enumerator nextObject];
        
        if (nextPoint != nil)
        {
            self.componenets[enumeratorIndex] = nextPoint;

			/*
			 If we rolled over the month or year, tell the day iterator
			 about it, so it can figure out what the "days of the week"
			 mean for this month and year.
			 */
			if (enumerator == self.monthEnumerator || enumerator == self.yearEnumerator)
			{
				[self recomputeDaysAfterRollingOverMonthOrYear];
			}
        }
        else
        {
            //  Rollover the current enumerator and move to the next one.
            //  Enumerators (0 ... ndx - 1) have already been rolled over
			//  at this point.
            self.componenets[enumeratorIndex] = [enumerator nextObjectAfterRollover];
            ++enumeratorIndex;
        }
    } while (nextPoint == nil && enumeratorIndex < self.enumerators.count);
    
    self.nextMoment = [self componentsToDate];
    
    //  Have the range been exceeded?
    if ([self.endingMoment compare:self.nextMoment] == NSOrderedAscending)
    {
        self.nextMoment = nil;
    }
    
    return savedMoment;
}

- (void) recomputeDaysAfterRollingOverMonthOrYear
{
	APCDayOfMonthSelector *selector = (APCDayOfMonthSelector *) self.dayEnumerator.selector;

	NSNumber *month = self.componenets [kMonthIndex];
	NSNumber *year  = self.componenets [kYearIndex];

	[selector recomputeDaysBasedOnCalendar: self.calendar
									 month: month
									  year: year];

	self.componenets [kDayIndex] = self.dayEnumerator.nextObjectAfterRollover;
}

- (NSDate*)componentsToDate
{
    NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
    
    dateComponents.calendar = self.calendar;
    dateComponents.year     = [self.componenets[kYearIndex]   integerValue];
    dateComponents.month    = [self.componenets[kMonthIndex]  integerValue];
    dateComponents.day      = [self.componenets[kDayIndex]    integerValue];
    dateComponents.hour     = [self.componenets[kHourIndex]   integerValue];
    dateComponents.minute   = [self.componenets[kMinuteIndex] integerValue];
    
    return [dateComponents date];
}

@end
