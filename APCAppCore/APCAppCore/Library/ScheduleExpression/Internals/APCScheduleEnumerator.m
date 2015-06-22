// 
//  APCScheduleEnumerator.m
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCScheduleEnumerator.h"
#import "APCDayOfMonthSelector.h"
#import "NSDateComponents+Helper.h"
#import "NSDate+Helper.h"


/**
 This enum gives names to the order of items in the -selectors
 -calendarComponents arrays.
 
 I made this an enum instead of simple integers
 for ease of debugging -- so the enum name appears
 in Xcode's "Variables" window.
 */
typedef enum : NSUInteger {
	DateFieldMinute = 0,
	DateFieldHour   = 1,
	DateFieldDay    = 2,
	DateFieldMonth  = 3,
	DateFieldYear   = 4,
}	DateField;


@interface APCScheduleEnumerator ()

@property (nonatomic, strong) NSDate*					beginningMoment;
@property (nonatomic, strong) NSDate*					endingMoment;
@property (nonatomic, strong) NSString*					originalCronExpression;     // For debugging only, but very helpful.

@property (nonatomic, strong) APCListSelector*			minuteSelector;
@property (nonatomic, strong) APCListSelector*			hourSelector;
@property (nonatomic, strong) APCDayOfMonthSelector*	daySelector;
@property (nonatomic, strong) APCListSelector*			monthSelector;
@property (nonatomic, strong) APCListSelector*			yearSelector;

/**
 These two arrays are in the same sequence, which is the sequence
 listed in the enum values of APCScheduleEnumeratorDateComponent.
 */
@property (nonatomic, strong) NSArray* selectors;
@property (nonatomic, strong) NSMutableArray* dateComponents;

@property (nonatomic, strong) NSArray* dateComponentFieldsWeCareAbout;
@property (nonatomic, assign) BOOL hasStartedYet;

@end


@implementation APCScheduleEnumerator

- (instancetype)initWithBeginningTime: (NSDate *) begin
                       minuteSelector: (APCTimeSelector *) minuteSelector
                         hourSelector: (APCTimeSelector *) hourSelector
                   dayOfMonthSelector: (APCTimeSelector *) dayOfMonthSelector
                        monthSelector: (APCTimeSelector *) monthSelector
                         yearSelector: (APCTimeSelector *) yearSelector
               originalCronExpression: (NSString *) originalExpression
{
    return [self initWithBeginningTime: begin
                            endingTime: nil
                        minuteSelector: minuteSelector
                          hourSelector: hourSelector
                    dayOfMonthSelector: dayOfMonthSelector
                         monthSelector: monthSelector
                          yearSelector: yearSelector
                originalCronExpression: originalExpression];
}

- (instancetype)initWithBeginningTime: (NSDate *) begin
                           endingTime: (NSDate *) end
                       minuteSelector: (APCTimeSelector *) minuteSelector
                         hourSelector: (APCTimeSelector *) hourSelector
                   dayOfMonthSelector: (APCTimeSelector *) dayOfMonthSelector
                        monthSelector: (APCTimeSelector *) monthSelector
                         yearSelector: (APCTimeSelector *) yearSelector
               originalCronExpression: (NSString *) originalExpression
{
	self = [super init];

	if (self)
	{
        _originalCronExpression = originalExpression;

		_minuteSelector		= (APCListSelector*) minuteSelector;
		_hourSelector		= (APCListSelector*) hourSelector;
		_daySelector		= (APCDayOfMonthSelector*) dayOfMonthSelector;
		_monthSelector		= (APCListSelector*) monthSelector;
		_yearSelector		= (APCListSelector*) yearSelector;

		_hasStartedYet		= NO;
		_beginningMoment	= begin;
		_endingMoment		= end;

		/*
		 These arrays are in the same sequence as
		 the enum values in APCScheduleEnumeratorDateComponent.
		 */
		_selectors = @[ minuteSelector,
					    hourSelector,
					    dayOfMonthSelector,
					    monthSelector,
					    yearSelector];

		// Will be filled in the first time -nextObject is called.
		_dateComponents = nil;
	}

	return self;
}

- (id) nextObject
{
    return self.nextScheduledDate;
}

- (NSDate *) nextScheduledDate
{
	NSDate* result = nil;

	if (self.hasStartedYet == NO)
	{
		self.hasStartedYet = YES;

		result = [self firstDate];
	}
	else
	{
		result = [self nextDate];
	}

	return result;
}

/**
 Sets the dateComponents to the first possible values
 specified by the rules embodied by this enumerator.
 Then calls -nextDate until it passes -beginningMoment.
 If it passes -endingMoment, there are simply no legal
 dates in the range we've got, and returns nil.
 */
- (NSDate*) firstDate
{
	NSDate* result		= nil;

	NSNumber* minute	= self.minuteSelector.initialValue;
	NSNumber* hour		= self.hourSelector.initialValue;
	NSNumber* month		= self.monthSelector.initialValue;
	NSNumber* year		= self.yearSelector.initialValue;

	[self.daySelector recomputeDaysBasedOnMonth:month year:year];
	NSNumber* day		= self.daySelector.initialValue;

	// These components form a date value.  Note that every
	// call to -nextDate increments one or more of these values.
	self.dateComponents = @[minute, hour, day, month, year].mutableCopy;

	// What's that first date?
	result = [self componentsAsDate];

	if ([result isLaterThanDate: self.endingMoment])
	{
		// The initialValues from the enumerator rules
		// are past the last legal date.  Say so.
		result = nil;
	}
	else if ([result isLaterThanOrEqualToDate: self.beginningMoment])
	{
		// The initialValues from the enumerator rules
		// are within the legal range of dates.  Done!
	}
	else
	{
		// Keep calling nextDate until we reach or pass the
		// beginningMoment.  If we pass the endingMoment,
		// we'll get nil.
		while (result != nil && [result isEarlierThanDate: self.beginningMoment])
		{
			result = self.nextDate;
		}
	}

	return result;
}

/**
 This method is the core of how iteration happens.  Each
 time we hit this method, increment the "minutes" field to
 the next legal minute.  If that rolls over (say, from 59
 to 0), increment the "hours" field.  If "hours" rolls over,
 increment "days."  And so on, up through "years."

 There's one "catch":  when we roll over a month or year,
 we have to recompute all the days-of-the-month in the new
 month-and-year combination, so that the day-of-the-week
 rules are applied correctly (e.g., getting the right date
 for "the first Friday of the month") and so that we have
 the right number of days per month (28, 31, etc.).  We thus
 also have to check whether the new month has ANY legal days
 in it at all, and move to the next month if not.
 
 This method is also used when determining the first legal
 date for this enumerator.  See -firstDate.
 
 --- Example ---
 Let's say our legal date components are:
		minutes:	0,    30	(on the hour, and on the half-hour)
		hours:		0,    12	(noon and midnight)
		days:		1,    15	(the 1st and 15th of every month)
		months:		1,    7		(January and July)
		years:		2015, 2016	(calendar years 2015 and 2016)
 
 Here's what happens each time this method gets called.

 First time:  all fields have been set to their initial values:
		minutes:	[0],    30
		hours:		[0],    12
		days:		[1],    15
		months:		[1],    7
		years:		[2015], 2016
 
 That value is the date 2015-01-01-00-00:  January 1, 2015, at midnight.
 That value would have been returned by -firstDate.
 
 So in this method, our first job will be to increment the
 "minutes" field, to "30":
		minutes:	 0,    [30]
		hours:		[0],    12
		days:		[1],    15
		months:		[1],    7
		years:		[2015], 2016
 
 We'll return the date 1/1/2015 at 12:30am.
 
 Next time:  increment minutes again.  Minutes returns nil:
		minutes:	 0,     30,    [  ]
		hours:		[0],    12
		days:		[1],    15
		months:		[1],    7
		years:		[2015], 2016
 
 So we'll reset minutes to the beginning, and increment hours:
		minutes:	[0],    30
		hours:		 0,    [12]
		days:		[1],    15
		months:		[1],    7
		years:		[2015], 2016

 Now we return noon on January 1.
 
 Repeat until we've run off the end of the "years" list.
 When that happens, we'll return nil, and the enumerator
 is done.
 
 The "catch" happens when we've incremented months or years.
 For example, if our daySelector contained these rules:

		days:		1, 15, first Friday, third Thursday
 
 then each time we change the "month" and "year" fields,
 we have to recalculate the list of legal days, so that
 we know what "first Friday" and "third Thursday" mean
 in the new month and year.  The iteration happens identically;
 we just have an extra step.
 */
- (NSDate*) nextDate
{
	NSDate* result = nil;
	BOOL shouldInspectNextField = YES;
	DateField dateFieldIndex = DateFieldMinute;

    while (dateFieldIndex <= DateFieldYear && shouldInspectNextField)
	{
		APCTimeSelector* dateFieldSelector = self.selectors [dateFieldIndex];
		NSNumber* prevFieldValue = self.dateComponents [dateFieldIndex];
		NSNumber* newFieldValue = [dateFieldSelector nextMomentAfter: prevFieldValue];

		if (newFieldValue == nil)
		{
            NSNumber *firstFieldValue = dateFieldSelector.initialValue;
            self.dateComponents [dateFieldIndex] = firstFieldValue;
			shouldInspectNextField = YES;
		}
        else if (dateFieldIndex < DateFieldMonth)
		{
            self.dateComponents [dateFieldIndex] = newFieldValue;
			shouldInspectNextField = NO;
		}

        else  // dateFieldIndex == Month or Year
        {
            // Record the fact that we looked at this month or year.
            self.dateComponents [dateFieldIndex] = newFieldValue;

            // Recompute the days in this new month.
            NSNumber* month = self.dateComponents [DateFieldMonth];
            NSNumber* year  = self.dateComponents [DateFieldYear];

            [self.daySelector recomputeDaysBasedOnMonth: month
                                                   year: year];

            if (self.daySelector.hasAnyLegalDays)
            {
                NSNumber *firstDayValue = self.daySelector.initialValue;
                self.dateComponents [DateFieldDay] = firstDayValue;
                shouldInspectNextField = NO;
            }
            else
		{
                // Go to the next month.  I.e., keep cycling on the current "date field."
                dateFieldIndex = DateFieldMonth - (DateField) 1;
                shouldInspectNextField = YES;
            }
		}

        // Move to the next field.
        dateFieldIndex ++;
	}

	if (dateFieldIndex > DateFieldYear)
	{
		result = nil;
	}
	else
	{
		result = [self componentsAsDate];

		if ([result isLaterThanDate: self.endingMoment])
		{
			result = nil;
		}
	}

	return result;
}

- (NSDate*) componentsAsDate
{
	NSDateComponents *components = [NSDateComponents componentsInGregorianLocal];
	
	components.year     = [self.dateComponents [DateFieldYear]   integerValue];
    components.month    = [self.dateComponents [DateFieldMonth]  integerValue];
    components.day      = [self.dateComponents [DateFieldDay]    integerValue];
    components.hour     = [self.dateComponents [DateFieldHour]   integerValue];
    components.minute   = [self.dateComponents [DateFieldMinute] integerValue];
    
    return [components date];
}

@end
