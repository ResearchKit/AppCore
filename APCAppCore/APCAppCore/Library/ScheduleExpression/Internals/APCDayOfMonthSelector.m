// 
//  APCDayOfMonthSelector.m 
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
 
#import "APCDayOfMonthSelector.h"
#import "APCTimeSelectorEnumerator.h"
#import "APCPointSelector.h"
#import "APCListSelector.h"
#import "NSDateComponents+Helper.h"


@interface APCDayOfMonthSelector ()

/** The thing we care about. */
@property (nonatomic, strong) NSArray *computedDaysToEnumerate;

/* Tools for figuring that out. */
@property (nonatomic, strong) APCTimeSelector *underlyingDayOfMonthSelector;
@property (nonatomic, strong) NSArray *dayOfWeekRangeSelectors;
@property (nonatomic, strong) NSArray *dayOfWeekPositionSelectors;
@property (nonatomic, assign) BOOL monthdaySelectorIsWildcard;
@property (nonatomic, assign) BOOL weekdaySelectorIsWildcard;
@property (nonatomic, strong) NSNumber* month;
@property (nonatomic, strong) NSNumber* year;

@end


@implementation APCDayOfMonthSelector


// ---------------------------------------------------------
#pragma mark - Init
// ---------------------------------------------------------

- (id) initWithFreshlyParsedDayOfMonthSelector: (APCTimeSelector *) dayOfMonthSelector
						  andDayOfWeekSelector: (APCTimeSelector *) dayOfWeekSelector
{
	self = [super init];

	if (self)
	{
		self.underlyingDayOfMonthSelector = dayOfMonthSelector;
		self.monthdaySelectorIsWildcard = self.underlyingDayOfMonthSelector.isWildcard;

		[self splitWeekSelectorIntoDaysAndPositions: dayOfWeekSelector];

		// We'll get real values at iteration time.  For now, use 31 days.
		[self recomputeDaysBasedOnMonth: nil year: nil];
	}

	return self;
}

- (void) splitWeekSelectorIntoDaysAndPositions: (APCTimeSelector *) dayOfWeekSelector
{
	APCListSelector *realWeekSelector = (APCListSelector *) dayOfWeekSelector;
	NSMutableArray *rangeSelectors = nil;
	NSMutableArray *positionSelectors = nil;
	self.weekdaySelectorIsWildcard = YES;

	for (APCPointSelector *pointSelector in realWeekSelector.subSelectors)
	{
		if (pointSelector.position != nil)
		{
			if (positionSelectors == nil)
			{
				positionSelectors = [NSMutableArray new];
			}

			[positionSelectors addObject: pointSelector];
		}
		else
		{
			if (rangeSelectors == nil)
			{
				rangeSelectors = [NSMutableArray new];
			}

			[rangeSelectors addObject: pointSelector];
		}

		// And, whichever type it is:
		if (! pointSelector.isWildcard)
		{
			self.weekdaySelectorIsWildcard = NO;
		}
	}

	self.dayOfWeekRangeSelectors = rangeSelectors;
	self.dayOfWeekPositionSelectors = positionSelectors;
}



// ---------------------------------------------------------
#pragma mark - Public API
// ---------------------------------------------------------

- (NSNumber*) initialValue
{
	return self.computedDaysToEnumerate.firstObject;
}

- (BOOL) matches: (NSNumber*) value
{
	return [self.computedDaysToEnumerate containsObject: value];
}

- (NSNumber*) nextMomentAfter: (NSNumber*) point
{
	NSNumber *result = nil;

	/*
	 My values are sorted from smallest to largest.

	 Find the moment just AFTER the specified point.
	 (If we find a moment EQUAL to that point, skip it.)
	 This lets us handle start dates that fall randomly in the
	 range we're handling, as well as points that came from my
	 own enumerator.
	 */
	for (NSNumber *thisMoment in self.computedDaysToEnumerate)
	{
		if ([thisMoment compare: point] == NSOrderedDescending)  // meaning:  if (thisMoment > point) { ... }
		{
			result = thisMoment;
			break;
		}
	}

	return result;
}

- (APCTimeSelectorEnumerator*) enumeratorBeginningAt: (NSNumber*) value
{
	if (value == nil)
	{
		value = self.initialValue;
	}

	APCTimeSelectorEnumerator* enumerator = [[APCTimeSelectorEnumerator alloc] initWithSelector:self beginningAtMoment:value];

	return enumerator;
}

- (BOOL) isWildcard
{
	return self.weekdaySelectorIsWildcard && self.monthdaySelectorIsWildcard;
}

- (void) recomputeDaysBasedOnMonth: (NSNumber *) month
							  year: (NSNumber *) year
{
	self.month = month;
	self.year = year;

	// Please leave this line here, as a reminder of this implementation decision.
//	NSDateComponents *components = [NSDateComponents componentsInGregorianUTCWithMonth: month year: year];
	NSDateComponents *components = [NSDateComponents componentsInGregorianLocalWithMonth: month year: year];
	NSArray *allDaysInMonth = components.allDaysInMonth;
	NSMutableArray *computedDays = nil;


	if (self.month == nil || self.year == nil)
	{
		computedDays = allDaysInMonth.mutableCopy;
	}


	// Both of my underlying selectors are wildcards.
	// Add all days of the month.
	else if (self.monthdaySelectorIsWildcard && self.weekdaySelectorIsWildcard)
	{
		computedDays = allDaysInMonth.mutableCopy;
	}


	// Month is fixed, week is wildcard.  Extract the month days.
	else if ( (! self.monthdaySelectorIsWildcard) && self.weekdaySelectorIsWildcard)
	{
		computedDays = [self specificMonthDays];
	}


	// Week is fixed, month is wildcard.  Extract the week days.
	else if (self.monthdaySelectorIsWildcard && ! self.weekdaySelectorIsWildcard)
	{
		computedDays = [self specificWeekdaysForMonth: month
											  andYear: year
									ignoringTheseDays: nil];
	}


	/*
	 Both weekDays and monthDays are fixed.  Extract both,
	 skip duplicates, and sort.

	 Why sort?  We're generating days of the month that
	 we'll have to iterate through.  We want the iteration
	 to happen in human-friendly order.  If we don't sort,
	 we'll end up with something like this:

	 - if the monthday selector generates:  5 10 15     (the 5th, 10th, 15th of the month)
	 - and the weekday selector generates:  7 14 21 28  (every Tuesday of that particular month)
	 - then this method would generate:     5 10 15 7 14 21 28
	 -                                           ^^^^
  
	 I.e., the 7th of the month appears after the 15th.
	 If we iterate through that, we'd appear to go backwards
	 in time.  Sorting will put the days in the right order:
	 
			5 7 10 14 15 21 28
	 */
	else
	{
		computedDays = [self specificMonthDays];

		NSArray *monthDaysFromWeekdays = [self specificWeekdaysForMonth: month
																andYear: year
													  ignoringTheseDays: computedDays];

		for (NSNumber *monthDayFromWeekday in monthDaysFromWeekdays)
		{
			if (! [computedDays containsObject: monthDayFromWeekday])
			{
				[computedDays addObject: monthDayFromWeekday];
			}
		}
	}

	// They're all NSNumbers, so we can sort them using their own -compare: method.
	[computedDays sortUsingSelector: @selector(compare:)];

	self.computedDaysToEnumerate = computedDays;
}



// ---------------------------------------------------------
#pragma mark - Internal Calculations
// ---------------------------------------------------------

/**
 Gather all the days-of-month days from the underlying day-of-month
 selector, filtering out the ones that aren't in the current actual
 month and year.
 */
- (NSMutableArray *) specificMonthDays
{
	NSMutableArray *computedDays = [NSMutableArray new];
	NSNumber *day = self.underlyingDayOfMonthSelector.initialValue;

	// Please leave this line here, as a reminder of this implementation decision.
//	NSDateComponents *components = [NSDateComponents componentsInGregorianUTCWithMonth: self.month year: self.year];
	NSDateComponents *components = [NSDateComponents componentsInGregorianLocalWithMonth: self.month year: self.year];
	NSArray *allDaysInMonth = components.allDaysInMonth;

	while (day != nil)
	{
		if ([allDaysInMonth containsObject: day])
		{
			[computedDays addObject: day];
		}

		day = [self.underlyingDayOfMonthSelector nextMomentAfter: day];
	}

	return computedDays;
}

/**
 Convert all days-of-the-week from my underlying day-of-the-week
 selector into specific dates (days-in-the-month) during the
 specified month and year.
 */
- (NSMutableArray *) specificWeekdaysForMonth: (NSNumber *) __unused  month
									  andYear: (NSNumber *) __unused  year
							ignoringTheseDays: (NSArray *) precomputedDaysInMonth
{

	NSMutableArray *computedDays = [NSMutableArray new];


	/*
	 Gather all the days of the week we care about --
	 meaning, Sunday through Saturday, not the days-of-the-month
	 those weekdays correspond to.  (We'll do that in a moment.)

	 Note that the selectors might specify overlapping
	 days of the week:  e.g., one might be a range of days (Tuesday
	 through Thursday), while another might be a specific day
	 (like Wednesday).
	 */
	NSMutableArray *userSpecifiedCronDaysOfWeek = [NSMutableArray new];

	for (APCPointSelector *pointSelector in self.dayOfWeekRangeSelectors)
	{
		NSNumber *day = pointSelector.initialValue;

		while (day != nil)
		{
			if (! [userSpecifiedCronDaysOfWeek containsObject: day])
			{
				[userSpecifiedCronDaysOfWeek addObject: day];
			}

			day = [pointSelector nextMomentAfter: day];
		}
	}


	/*
	 Find every individual day of the month those days-of-the-week
	 correspond to.  If we didn't already generate it when looking
	 at the legal days of the month, include it.

	 This also means:  generate a date, and then generate a weekday
	 from that date.  I can't just read the weekday from the existing
	 Components object; it's undefined (NSDateComponentUndefined).
	 As a result, I wrote several helper methods on NSDateComponents
	 and NSDate, which I use here and elsewhere.
	 */
	if (userSpecifiedCronDaysOfWeek.count)
	{
		// Please leave this line here, as a reminder of this implementation decision.
//		NSDateComponents *components = [NSDateComponents componentsInGregorianUTCWithMonth: self.month year: self.year];
		NSDateComponents *components = [NSDateComponents componentsInGregorianLocalWithMonth: self.month year: self.year];

		for (NSNumber *thisDay in components.allDaysInMonth)
		{
			if (! [precomputedDaysInMonth containsObject: thisDay])
			{
				NSNumber *cronDayOfWeek = [components cronDayOfWeekAsNSNumberForDay: thisDay];

				if ([userSpecifiedCronDaysOfWeek containsObject: cronDayOfWeek])
				{
					[computedDays addObject: thisDay];
				}
			}
		}
	}

	for (APCPointSelector *pointSelector in self.dayOfWeekPositionSelectors)
	{
		NSNumber *day = [self dayInCurrentMonthMatchingSelector: pointSelector];

		if (! [computedDays containsObject: day])
		{
			[computedDays addObject: day];
		}
	}

	return computedDays;
}

/**
 Assumes the pointSelector contains exactly ONE day of
 the week, appearing exactly ONCE in the month, like
 this:
 
		5#3			(The third Friday in the current month)
 
 Does NOT accept ranges of either one, such as:
 
		4-5#2-3		(The second and third Thursday, and the second and third Friday, in the current month)
 
 We'll add that, of course, as needed.
 */
- (NSNumber *) dayInCurrentMonthMatchingSelector: (APCPointSelector *) pointSelector
{
	NSNumber* result = nil;

	if (pointSelector.position)
	{
		NSInteger foundDay				= -1;
		NSInteger currentInstanceOfDay	= 1;
		NSInteger requestedDayOfWeek	= pointSelector.initialValue.integerValue;
		NSInteger requestedIntanceOfDay	= pointSelector.position.integerValue;

		// Please leave this line here, as a reminder of this implementation decision.
//		NSDateComponents *components    = [NSDateComponents componentsInGregorianUTCWithMonth: self.month year: self.year];
		NSDateComponents *components    = [NSDateComponents componentsInGregorianLocalWithMonth: self.month year: self.year];

		// Find the first nth day of the month -- e.g., the first
		// Friday, if we're looking for Fridays.  Then we can add
		// 7 until we run out of days in the month or until we
		// find the desired day.

		NSInteger firstRequestedDayInMonth = -1;
		NSInteger lastDayOfMonth = components.lastDayOfMonth;

		for (NSInteger day = 1; day <= lastDayOfMonth; day++)
		{
			NSInteger cronDayOfWeek = [components cronDayOfWeekForDay: day];

			if (cronDayOfWeek == requestedDayOfWeek)
			{
				firstRequestedDayInMonth = day;
				break;
			}
		}

		if (requestedIntanceOfDay <= 1)
		{
			foundDay = firstRequestedDayInMonth;
		}

		else
		{
			for (NSInteger day = firstRequestedDayInMonth + 7; day <= lastDayOfMonth; day += 7)
			{
				currentInstanceOfDay ++;

				if (currentInstanceOfDay == requestedIntanceOfDay)
				{
					foundDay = day;
					break;
				}

				else
				{
					// Continue until we run out of days.
					// If that happens, no problem; we'll
					// return nil.
				}
			}
		}

		result = foundDay == -1 ? nil : @(foundDay);
	}

	return result;
}

- (BOOL) hasAnyLegalDays
{
    return self.computedDaysToEnumerate.count > 0;
}

@end






