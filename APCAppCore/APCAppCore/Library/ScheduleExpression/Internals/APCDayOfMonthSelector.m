// 
//  APCDayOfMonthSelector.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCDayOfMonthSelector.h"
#import "APCTimeSelectorEnumerator.h"


@interface APCDayOfMonthSelector ()

@property (nonatomic, strong) APCTimeSelector *underlyingDayOfMonthSelector;
@property (nonatomic, strong) APCTimeSelector *underlyingDayOfWeekSelector;

@property (nonatomic, strong) NSArray *computedDaysToEnumerate;

@property (nonatomic, strong) NSCalendar* calendar;
@property (nonatomic, strong) NSNumber*   month;
@property (nonatomic, strong) NSNumber*   year;

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
		self.underlyingDayOfWeekSelector  = dayOfWeekSelector;

		// We'll get real values at iteration time.  For now,
		// use 31 days.
		[self recomputeDaysBasedOnCalendar: nil month: nil year: nil];
	}

	return self;
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

- (NSNumber*) nextMomentAfter: (NSNumber*) point;
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
	APCTimeSelectorEnumerator* enumerator = [[APCTimeSelectorEnumerator alloc] initWithSelector:self beginningAtMoment:value];

	return enumerator;
}

- (BOOL) isWildcard
{
	return super.isWildcard;
}

- (void) recomputeDaysBasedOnCalendar: (NSCalendar *) calendar
								month: (NSNumber *) month
								 year: (NSNumber *) year
{
	self.calendar = calendar;
	self.month = month;
	self.year = year;

	NSMutableArray *computedDays = nil;
	BOOL monthdaySelectorIsWildcard = self.underlyingDayOfMonthSelector.isWildcard;
	BOOL weekdaySelectorIsWildcard = self.underlyingDayOfWeekSelector.isWildcard;


	/*
	 TODO:  Hack?  This always happens when this object is initialized:
	 we don't have a year and month, yet.  No problem:  just pretend
	 we'll use all days in this month.  In every (ahem) situation that
	 matters, we'll only get here after getting a month and year.
	 (Um, right?)
	 */
	if (self.calendar == nil || self.month == nil || self.year == nil)
	{
		computedDays = [self allDaysInCurrentMonthAndYear];
	}


	// Both of my underlying selectors are wildcards.
	// Add all days of the month.
	else if (monthdaySelectorIsWildcard && weekdaySelectorIsWildcard)
	{
		computedDays = [self allDaysInCurrentMonthAndYear];
	}


	// Month is fixed, week is wildcard.  Extract the month days.
	else if ( (! monthdaySelectorIsWildcard) && weekdaySelectorIsWildcard)
	{
		computedDays = [self specificMonthDays];
	}


	// Week is fixed, month is wildcard.  Extract the week days.
	else if (monthdaySelectorIsWildcard && ! weekdaySelectorIsWildcard)
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

		[computedDays addObjectsFromArray: monthDaysFromWeekdays];

		[computedDays sortUsingComparator: ^NSComparisonResult (NSNumber *day1, NSNumber *day2) {
			return [day1 compare: day2];
		}];

	}
	
	self.computedDaysToEnumerate = computedDays;
}



// ---------------------------------------------------------
#pragma mark - Internal Calculations
// ---------------------------------------------------------

- (NSMutableArray *) allDaysInCurrentMonthAndYear
{
	NSMutableArray *computedDays = [NSMutableArray new];
	NSCalendar *calendar = nil;
	NSInteger year = -1;
	NSInteger month = -1;

	if (self.calendar == nil || self.month == nil || self.year == nil)
	{
		/*
		 This only happens during initialization.  It'll be
		 overwritten the first time we actually iterate through
		 a month.  For now, pick an arbitrary 31-day month.
		 */
		calendar	= [NSCalendar currentCalendar];
		year		= 2001;
		month		= 1;
	}
	else
	{
		calendar	= self.calendar;
		year		= self.year.integerValue;
		month		= self.month.integerValue;
	}

	NSDateComponents *components	= [NSDateComponents new];
	components.calendar				= calendar;
	components.year					= year;
	components.month				= month;
	NSDate *theDate					= components.date;

	NSRange legalDaysInMonth		= [calendar rangeOfUnit: NSCalendarUnitDay
											         inUnit: NSCalendarUnitMonth
													forDate: theDate];

	for (NSInteger thisDay = legalDaysInMonth.location;
		 thisDay < legalDaysInMonth.location + legalDaysInMonth.length;
		 thisDay ++)
	{
		[computedDays addObject: @(thisDay)];
	}

	return computedDays;
}

/**
 Gather all the days-of-month days from the underlying day-of-month
 selector, filtering out the ones that aren't in the current actual
 month and year.
 */
- (NSMutableArray *) specificMonthDays
{
	NSMutableArray *computedDays = [NSMutableArray new];
	NSNumber *day = self.underlyingDayOfMonthSelector.initialValue;
	NSArray *allDaysInMonth = [self allDaysInCurrentMonthAndYear];

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
- (NSMutableArray *) specificWeekdaysForMonth: (NSNumber *) month
									  andYear: (NSNumber *) year
							ignoringTheseDays: (NSArray *) precomputedDaysInMonth
{
	/*
	 Gather all the days of the week we care about --
	 meaning Sunday through Saturday, not the days-of-the-month
	 those weekdays correspond to.  (We'll do that in a moment.)
	 */
	NSMutableArray *legalCronDaysOfWeek = [NSMutableArray new];
	NSNumber *day = self.underlyingDayOfWeekSelector.initialValue;

	while (day != nil)
	{
		[legalCronDaysOfWeek addObject: day];

		day = [self.underlyingDayOfWeekSelector nextMomentAfter: day];
	}


	/*
	 Find every individual day of the month those days-of-the-week
	 correspond to.  If we didn't already generate it when looking
	 at the legal days of the month, include it.
	 */
	NSMutableArray *computedDays = [NSMutableArray new];
	NSArray *allLegalDaysInMonth = [self allDaysInCurrentMonthAndYear];
	NSDateComponents *components = [NSDateComponents new];
	components.calendar = self.calendar;
	components.year = self.year.integerValue;
	components.month = self.month.integerValue;

	for (NSNumber *thisDay in allLegalDaysInMonth)
	{
		if (! [precomputedDaysInMonth containsObject: thisDay])
		{
			/*
			 Generate a date, and then generate a weekday from
			 that date.  I can't just read the weekday from the
			 existing Components object -- it's undefined
			 (actually NSDateComponentUndefined).
			 */
			components.day = thisDay.integerValue;
			NSDate *thisDate = components.date;
			NSInteger nsdateOneBasedDayOfWeek = [self.calendar component: NSCalendarUnitWeekday
																fromDate: thisDate];


			/*
			 TODO:  decide where to translate between our 1-based days
			 and cron's zero-based days.  (This is NOT the test-harness
			 problem; this is one of the underlying real problems.)
			 Ideas:

			 -	Translate them in the existing PointSelector.  This means
				adding "if" statements and translations in a bunch of
				places, but it's "cleaner" than putting it here.

			 -	Translate them here, where we're using them.  This really
				means:  translate them EVERY time we use them.  If this
				is the only place we EVER do that, no problem.  If not,
				it becomes much harder to remember, and thus maintain.

			 -	Write a PointSelector subclass for every UnitType, instead
				of using UnitType.  This would mean we could encapsulate
				the cron-to-NSDate translation in a DayOfWeekPointSelector.
				Cleanest object-oriented implementation, but it means we
				have to maintain another two-to-ten source-code files.
			 
			 For the moment, I'm doing it here:  3 lines of code, in the
			 only place I'm consuming those numbers, which means I don't
			 have to change any of the existing, working logic anywhere else.
			 */
			NSInteger cronZeroBasedDayOfWeek = nsdateOneBasedDayOfWeek - 1;
			if (cronZeroBasedDayOfWeek < 1) cronZeroBasedDayOfWeek += 7;

			if ([legalCronDaysOfWeek containsObject: @(cronZeroBasedDayOfWeek)])
			{
				[computedDays addObject: thisDay];
			}
			
		}  // if (this day hasn't already been computed)
	}  // for (all days in month)

	return computedDays;
}

@end






