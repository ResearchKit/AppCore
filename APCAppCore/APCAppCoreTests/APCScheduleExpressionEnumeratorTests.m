//
//  APCScheduleExpressionEnumeratorTests.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APCScheduleExpression.h"
#import "NSDateComponents+Helper.h"
#import "NSDate+Helper.h"


/**
 The test cases in this file print errors (and fail the test)
 if our test-harness-generated dates do NOT match the
 ScheduleExpression-generated dates.  This #define says:
 in addition, print every case where the dates DO match.
 Helpful for debugging.
 */
#define DEBUG__PRINT_HAPPY_TEST_CASES  NO


@interface APCScheduleExpressionEnumeratorTests : XCTestCase

@property (nonatomic, strong) NSDateFormatter*  dateFormatterInGregorianUTC;
@property (nonatomic, strong) NSDateFormatter*  dayOfWeekFormatterInGregorianUTC;
@property (nonatomic, strong) NSArray*			everyYear;
@property (nonatomic, strong) NSArray*			everyMonth;
@property (nonatomic, strong) NSArray*			everyDay;
@property (nonatomic, strong) NSArray*			everyHour;
@property (nonatomic, strong) NSArray*			everyMinute;

@end


@implementation APCScheduleExpressionEnumeratorTests



// ---------------------------------------------------------
#pragma mark - Setup
// ---------------------------------------------------------

- (void) setUp
{
	[super setUp];

	// All my calculations are based on Universal Coordinated Time
	// (er, for now, I mean the user's local time zone; this is evolving)
	// in the Gregorian calendar.  Since I do a lot of those calculations
	// using a DateComponents object, I have this convenience method,
	// which also lets me make sure I'm using the same timeZone and
	// calendar objects everywhere:
//	NSDateComponents* components = [NSDateComponents componentsInGregorianUTC];
	NSDateComponents* components = [NSDateComponents componentsInGregorianLocal];

	self.dateFormatterInGregorianUTC = [NSDateFormatter new];
	self.dateFormatterInGregorianUTC.dateFormat = @"yyyy-MM-dd HH:mm";
	self.dateFormatterInGregorianUTC.calendar = components.calendar;
	self.dateFormatterInGregorianUTC.timeZone = components.timeZone;

	self.dayOfWeekFormatterInGregorianUTC = [NSDateFormatter new];
	self.dayOfWeekFormatterInGregorianUTC.dateFormat = @"EEE yyyy-MM-dd HH:mm";
	self.dayOfWeekFormatterInGregorianUTC.calendar = components.calendar;
	self.dayOfWeekFormatterInGregorianUTC.timeZone = components.timeZone;

	self.everyYear   = [self numericSequenceFrom: 2014	to: 2017];
	self.everyMonth  = [self numericSequenceFrom: 1		to: 12];
	self.everyDay    = [self numericSequenceFrom: 1		to: 31];
	self.everyHour   = [self numericSequenceFrom: 0		to: 23];
	self.everyMinute = [self numericSequenceFrom: 0		to: 59];
}

- (void) tearDown
{
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

/**
 Returns an NSArray of integers, from "begin" to "end."
 */
- (NSArray *) numericSequenceFrom: (NSInteger) begin
							   to: (NSInteger) end
{
	NSMutableArray* data = [NSMutableArray arrayWithCapacity:end - begin + 1];

	for (NSInteger index = begin; index <= end; ++index)
	{
		[data addObject: @(index)];
	}

	return [NSArray arrayWithArray: data];
}



// ---------------------------------------------------------
#pragma mark - Core of the test harness -
// ---------------------------------------------------------

/**
 TODO:  figure out where to put the logic for testing
 and enumerating through days of the week, and converting
 them to days of the month.

 Problem/issue:  (thinking out loud, here.)

 This method is designed to test the ENUMERATOR, and to make it
 EASY to test that enumerator.  The point is kinda:  generate a
 list of minutes/hours/days/etc. to walk through, and see if
 the enumerator is generating the same list.  The problem:
 generating that list requires programming logic.  I have to
 write that code, therefore, in 2 places -- in the enumerator
 (or elsewhere in the code being tested) and here, in the test
 harness. But that's a source of bugs -- which seems like it
 invalidates the test.  So where's the best place to put it?

 Even worse (as I debug this):  I'm POTENTIALLY tuning the test
 harness to be testing the code I wrote.  I'm not testing
 whether or not it's generating the correct days of the month.
 As I'm writing this, I am in fact checking with a real,
 physical calendar (Apple's Calendar program).  But once I
 stop that debugging process -- ?

 I could "cheat":  make separate methods for testing
 days-of-the-month and days-of-the-week.  But part of
 the point of the scheduler is to merge those.  Therefore
 we need to be able to test that merge.

 Ideas?
 */
- (void)enumerateOverYears:(NSArray*)years
				daysOfWeek:(NSArray*)zeroBasedDaysOfWeek
					months:(NSArray*)months
			   daysOfMonth:(NSArray*)daysOfMonth
					 hours:(NSArray*)hours
				   minutes:(NSArray*)minutes
	   comparingEnumerator:(NSEnumerator*)enumerator
{
	[self enumerateOverYears:years
				  daysOfWeek:zeroBasedDaysOfWeek
					  months:months
				 daysOfMonth:daysOfMonth
					   hours:hours
					 minutes:minutes
			  startingOnDate:nil
				endingOnDate:nil
		 comparingEnumerator:enumerator];
}

/**
 TODO:  Convert all test cases to call this method, not the above,
 so that we're making sure the test harness uses the same start
 and end dates as the enumerator itself.  (Expect bugs.)
 */
- (void)enumerateOverYears:(NSArray*)years
				daysOfWeek:(NSArray*)zeroBasedDaysOfWeek
					months:(NSArray*)months
			   daysOfMonth:(NSArray*)daysOfMonth
					 hours:(NSArray*)hours
				   minutes:(NSArray*)minutes
			startingOnDate:(NSDate*)startDate
			  endingOnDate:(NSDate*)endDate
	   comparingEnumerator:(NSEnumerator*)enumerator
{
	NSDate* enumeratorDate = nil;

	// Please leave these lines here, as a reminder of this implementation decision.
//	NSDateComponents *testHarnessDateComponents = [NSDateComponents componentsInGregorianUTC];
	NSDateComponents *testHarnessDateComponents = [NSDateComponents componentsInGregorianLocal];
	NSDate* testHarnessDate = nil;

	// We'll calculate the real days-in-each-month shortly.
	// In the meantime:
	years	= years.count	? years	  : self.everyYear;
	months	= months.count	? months  : self.everyMonth;
	hours	= hours.count	? hours	  : self.everyHour;
	minutes	= minutes.count	? minutes : self.everyMinute;

	for (NSNumber* aYear in years)
	{
		testHarnessDateComponents.year = aYear.integerValue;

		for (NSNumber* aMonth in months)
		{
			testHarnessDateComponents.month = aMonth.integerValue;

			NSArray *realDaysInMonth = [self calculateRealDaysInMonth: aMonth
															  andYear: aYear
													  givenTheseDates: daysOfMonth
												   andTheseDaysOfWeek: zeroBasedDaysOfWeek];

			for (NSNumber* aDay in realDaysInMonth)
			{
				testHarnessDateComponents.day = aDay.integerValue;

				for (NSNumber* aHour in hours)
				{
					testHarnessDateComponents.hour = aHour.integerValue;

					for (NSNumber* aMinute in minutes)
					{
						testHarnessDateComponents.minute = aMinute.integerValue;
						testHarnessDate = [testHarnessDateComponents date];

						// Meaning:                           testHarnessDate    <     startDate
						BOOL tooEarly = (startDate != nil && [testHarnessDate compare: startDate] == NSOrderedAscending);

						// Meaning:                           testHarnessDate    >     endDate
						BOOL tooLate  = (endDate != nil   && [testHarnessDate compare: endDate  ] == NSOrderedDescending);


						if (! tooEarly && ! tooLate)
						{
							enumeratorDate = [enumerator nextObject];

							if (! [testHarnessDate isEqualToDate: enumeratorDate])
							{
								NSLog (@"NO MATCH:  testHarness %@ != enumerator %@",
									   [self.dayOfWeekFormatterInGregorianUTC stringFromDate: testHarnessDate],
									   [self.dayOfWeekFormatterInGregorianUTC stringFromDate: enumeratorDate]);
							}

							else if (DEBUG__PRINT_HAPPY_TEST_CASES)
							{
								NSLog (@"MATCH:     testHarness %@ == enumerator %@",
									   [self.dayOfWeekFormatterInGregorianUTC stringFromDate: testHarnessDate],
									   [self.dayOfWeekFormatterInGregorianUTC stringFromDate: enumeratorDate]);
							}

							XCTAssertEqualObjects (testHarnessDate, enumeratorDate);
						}
					}
				}
			}
		}
	}
}

- (NSArray *) calculateRealDaysInMonth: (NSNumber *) month
							   andYear: (NSNumber *) year
					   givenTheseDates: (NSArray *) daysInMonth
					andTheseDaysOfWeek: (NSArray *) zeroBasedDaysOfWeek
{
	NSMutableArray *computedDaysInMonth	= [NSMutableArray new];

	// Please leave these lines here, as a reminder of this implementation decision.
//	NSDateComponents* dateComponents	= [NSDateComponents componentsInGregorianUTC];
	NSDateComponents* dateComponents	= [NSDateComponents componentsInGregorianLocal];
	dateComponents.year					= year.integerValue;
	dateComponents.month				= month.integerValue;
	NSArray *legalDaysInMonth			= dateComponents.allDaysInMonth;


	//
	// Normalize the zero-based days-of-the-week:  in the "cron"
	// rules, Sunday is both "0" and "7".  Convert all "7"s to
	// "0"s, so we only have to check for "0".
	//
	NSMutableArray *normalizedZeroBasedDaysOfWeek = [NSMutableArray new];

	for (NSNumber *dayOfWeek in zeroBasedDaysOfWeek)
	{
		if (dayOfWeek.integerValue == 7)
		{
			[normalizedZeroBasedDaysOfWeek addObject: @0];
		}
		else
		{
			[normalizedZeroBasedDaysOfWeek addObject: dayOfWeek];
		}
	}

	if (daysInMonth.count == 0 && normalizedZeroBasedDaysOfWeek.count == 0)
	{
		/*
		 Simplest case:  no restrictions on days.  Just use all the
		 legal days in this month.
		 */
		[computedDaysInMonth addObjectsFromArray: legalDaysInMonth];
	}

	else
	{
		if (daysInMonth.count)
		{
			for (NSNumber *userSpecifiedDayInMonth in daysInMonth)
			{
				if ([legalDaysInMonth containsObject: userSpecifiedDayInMonth])
				{
					[computedDaysInMonth addObject: userSpecifiedDayInMonth];
				}
			}
		}

		/*
		 Extract all month-days which are on the specified days of the week.
		 E.g., if the days of the week == @[@1] ("Monday"), extract all
		 days of this month that fall on a Monday.

		 Similar logic is in the ScheduleEnumerator.
		 */
		if (normalizedZeroBasedDaysOfWeek.count)
		{
			for (NSNumber* legalDayInMonth in legalDaysInMonth)
			{
				if (! [computedDaysInMonth containsObject: legalDayInMonth])
				{
					NSNumber *cronDayOfWeek = [dateComponents cronDayOfWeekAsNSNumberForDay: legalDayInMonth];

					if ([normalizedZeroBasedDaysOfWeek containsObject: cronDayOfWeek])
					{
						[computedDaysInMonth addObject: legalDayInMonth];
					}
				}
			}
		}

		// Merge the list of userDaysOfTheMonth with the user-days-of-the-week.
		[computedDaysInMonth sortUsingComparator: ^NSComparisonResult (NSNumber *day1, NSNumber *day2) {
			return [day1 compare: day2];
		}];
	}

	return computedDaysInMonth;
}



// =========================================================
#pragma mark - Testing specific bugs we found
// =========================================================

- (void) test_2014nov26_jiraApple491
{
	NSString* cronExpression = @"0 5 * * *";			// Every day at 5am.
//	NSString* cronExpression = @"0 5,10 * * *";			// Every day at 5 and 10am.
//	NSString* cronExpression = @"0/5 5,10 * * *";		// Every day at 5 and 10am, every 5 mins within those hours.

	NSString *startDateString = @"2014-11-26 00:00";	// original bug start date
//	NSString *startDateString = @"2015-11-26 00:00";	// testing rolling over a leap year

//	NSString *endDateString = @"2014-11-26 06:00";		//
	NSString *endDateString = @"2014-11-27 00:00";		// original bug end date
//	NSString *endDateString = @"2014-11-27 06:00";		//
//	NSString *endDateString = @"2014-11-28 00:00";		//
//	NSString *endDateString = @"2014-11-30 00:00";		//
//	NSString *endDateString = @"2014-12-01 06:00";		//
//	NSString *endDateString = @"2014-12-02 00:00";		//
//	NSString *endDateString = @"2014-12-03 00:00";		//
//	NSString *endDateString = @"2014-12-04 00:00";		//
//	NSString *endDateString = @"2014-12-29 00:00";		//
//	NSString *endDateString = @"2014-12-31 00:00";		//
//	NSString *endDateString = @"2014-12-31 05:00";		//
//	NSString *endDateString = @"2014-12-31 06:00";		//
//	NSString *endDateString = @"2015-01-01 00:00";		//
//	NSString *endDateString = @"2015-01-02 00:00";		//
//	NSString *endDateString = @"2015-01-03 00:00";		//
//	NSString *endDateString = @"2015-01-04 00:00";		//
//	NSString *endDateString = @"2015-06-02 00:00";		// Found and fixed several bugs regarding
//	NSString *endDateString = @"2015-07-05 00:00";		// rolling over FROM a less-than-31-day month.
//	NSString *endDateString = @"2015-12-02 00:00";		//
//	NSString *endDateString = @"2016-07-02 00:00";		//

	APCScheduleExpression* schedule	= [[APCScheduleExpression alloc] initWithExpression: cronExpression timeZero: 0];
	NSDate *startDate				= [self.dateFormatterInGregorianUTC dateFromString: startDateString];
	NSDate *endDate					= [self.dateFormatterInGregorianUTC dateFromString: endDateString];
	NSEnumerator* enumerator		= [schedule enumeratorBeginningAtTime: startDate  endingAtTime: endDate];


	/*
	 This is the test from the original bug.  It should print out exactly
	 the dates you expect to see.  Make sure you use the formatter
	 to print the dates, or it'll look wrong (it'll be in GMT, not PST).
	 */
//	NSDate* date = nil;
//
//	while ((date = enumerator.nextObject) != nil)
//	{
//		NSLog (@"Date: %@", [self.dateFormatter stringFromDate: date]);
//	}

	[self enumerateOverYears: nil
				  daysOfWeek: nil
					  months: nil
				 daysOfMonth: nil
					   hours: @[@5]
					 minutes: @[@0]
			  startingOnDate: startDate
				endingOnDate: endDate
		 comparingEnumerator: enumerator];
}

- (void) testDayOfWeekPlusSmallDateRangeYieldsNoDates_jiraApple577_Dhanush2014Dec04
{
	NSString*				cronExpression	= @"0 5 * * 1";		// Every day at 5am, only on Mondays.

	NSDate*					startDate		= [self.dateFormatterInGregorianUTC dateFromString: @"2014-12-04 00:00"];		// a Thursday, at midnight
	NSDate*					endDate			= [self.dateFormatterInGregorianUTC dateFromString: @"2014-12-05 00:00"];		// a Friday, at midnight

	APCScheduleExpression*	schedule		= [[APCScheduleExpression alloc] initWithExpression: cronExpression timeZero: 0];
	NSEnumerator*			enumerator		= [schedule enumeratorBeginningAtTime: startDate  endingAtTime: endDate];



	/*
	 This loop should print out the exact dates and times you expect.
	 
	 Note:  either run this loop or run the later stuff in
	 this method.  Once this runs, we've advanced the enumerator,
	 so any future tests will fail.
	 */

//	NSDate * enumeratedDate = nil;
//	while ((enumeratedDate = enumerator.nextObject) != nil)
//	{
//		NSLog (@"Date: %@", [self.dayOfWeekFormatter stringFromDate: enumeratedDate]);
//	}


	/*
	 This particular test is:  the enumerator should have no objects,
	 because there are no Mondays in the specified date range.
	 */
	XCTAssertNil (enumerator.nextObject);


	// This enumeration method doesn't handle enumerators with no values.
//	[self enumerateOverYears: nil
//				  daysOfWeek: nil
//					  months: nil
//				 daysOfMonth: nil
//					   hours: @[@5]
//					 minutes: @[@0]
//			  startingOnDate: startDate
//				endingOnDate: endDate
//		 comparingEnumerator: enumerator];
}



// =========================================================
#pragma mark - Individual testing methods -
// =========================================================


// ---------------------------------------------------------
#pragma mark - Minutes
// ---------------------------------------------------------

- (void)testEnumerationOfConstantMinutes
{
	NSString*				cronExpression = @"5 * * * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:01"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:nil
					   hours:nil
					 minutes:@[@5]
		 comparingEnumerator:enumerator];
}

- (void)testBoundedEnumerationOfConstantMinutes
{
	NSString*				cronExpression    = @"5 * * * *";
	APCScheduleExpression*	schedule          = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			boundedEnumerator = [schedule enumeratorBeginningAtTime: [self.dateFormatterInGregorianUTC dateFromString: @"2014-01-01 00:00"]
											                           endingAtTime: [self.dateFormatterInGregorianUTC dateFromString: @"2014-01-01 23:59"]];

	[self enumerateOverYears: @[@2014]
				  daysOfWeek: nil
					  months: @[@1]
				 daysOfMonth: @[@1]
					   hours: nil
					 minutes: @[@5]
		 comparingEnumerator: boundedEnumerator];

	XCTAssertNil([boundedEnumerator nextObject]);
}

- (void)testEnumeratingMinuteList
{
	NSString*				cronExpression = @"15,30,45 * * * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:01"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:nil
					   hours:nil
					 minutes:@[@15, @30, @45]
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingMinuteRange
{
	NSString*				cronExpression = @"15-30 * * * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:01"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:nil
					   hours:nil
					 minutes:[self numericSequenceFrom:15 to:30]
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingMinuteStep
{
	NSString*				cronExpression = @"*/15 * * * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:nil
					   hours:nil
					 minutes:@[@0, @15, @30, @45]
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingMinuteRangeAndStep
{
	NSString*				cronExpression = @"15-30/5 * * * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:01"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:nil
					   hours:nil
					 minutes:@[@15, @20,@25, @30]
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingMinuteListedRange
{
	NSString*				cronExpression = @"10-12,20-22 * * * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:01"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:nil
					   hours:nil
					 minutes:@[@10, @11, @12, @20, @21, @22]
		 comparingEnumerator:enumerator];
}



// ---------------------------------------------------------
#pragma mark - Hours
// ---------------------------------------------------------

- (void)testEnumeratingConstantHour
{
	NSString*				cronExpression = @"* 10 * * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 08:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:nil
					   hours:@[@10]
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingHourList
{
	NSString*				cronExpression = @"* 8,12,16 * * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 08:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:nil
					   hours:@[@8, @12, @16]
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingHourRange
{
	NSString*				cronExpression = @"* 8-17 * * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 08:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:nil
					   hours:[self numericSequenceFrom:8 to:17]
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingHourStep
{
	NSString*				cronExpression = @"* 8/4 * * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 08:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:nil
					   hours:@[@8, @12, @16, @20]
					 minutes:nil
		 comparingEnumerator:enumerator];
}



// ---------------------------------------------------------
#pragma mark - Days of month
// ---------------------------------------------------------

- (void)testEnumeratingConstantDayOfMonth
{
	NSString*				cronExpression = @"* * 15 * *";		// this is the real test.
//	NSString*				cronExpression = @"0 1,13 15 * *";	// so I don't have to iterate so much in the debugger.

	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:@[@15]
					   hours:nil			// this is the real test.
					 minutes:nil			// this is the real test.
//					   hours:@[@1, @13]
//					 minutes:@[@0]
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingDayOfMonthList
{
	NSString*				cronExpression = @"* * 15,30 * *";		// this is the real test.
//	NSString*				cronExpression = @"5 10 15,30 * *";		// so I don't have to iterate so much in the debugger.

	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:@[@15, @30]
					   hours:nil			// this is the real test.
					 minutes:nil			// this is the real test.
//					   hours:@[@10]
//					 minutes:@[@5]
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingDayOfMonthRange
{
	NSString*				cronExpression = @"* * 1-14 * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:[self numericSequenceFrom:1 to:14]
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingDayOfMonthStep
{
	NSString*				cronExpression = @"* * 10/5 * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:@[@10, @15, @20, @25, @30]
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}

//	/**
//	 This fails.
//	 */
//	- (void)testEnumeratingDayOfMonthEarlyRangeAndStep
//	{
//		NSString*				cronExpression = @"* * 1-5/5 * *";
//		APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
//		NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
//
//		[self enumerateOverYears:nil
//					  daysOfWeek:nil
//						  months:nil
//					 daysOfMonth:@[@1, @2, @3, @4, @10, @15, @20, @25, @30]
//						   hours:nil
//						 minutes:nil
//			 comparingEnumerator:enumerator];
//	}
//
//	/**
//	 This fails.
//	 */
//	- (void)testEnumeratingDayOfMonthLateRangeAndStep
//	{
//		NSString*				cronExpression = @"* * 10-15/5 * *";
//		APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
//		NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
//
//		[self enumerateOverYears:nil
//					  daysOfWeek:nil
//						  months:nil
//					 daysOfMonth:@[@10, @11, @12, @13, @14, @15, @20, @25, @30]
//						   hours:nil
//						 minutes:nil
//			 comparingEnumerator:enumerator];
//	}



// ---------------------------------------------------------
#pragma mark - Months
// ---------------------------------------------------------

- (void)testEnumeratingConstantMonth
{
	NSString*				cronExpression = @"* * * 4 *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:@[@4]
				 daysOfMonth:nil
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingMonthList
{
	NSString*				cronExpression = @"* * * 2,4,6,8 *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:@[@2, @4, @6, @8]
				 daysOfMonth:nil
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingMonthRange
{
	NSString*				cronExpression = @"* * * 6-9 *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:[self numericSequenceFrom:6 to:9]
				 daysOfMonth:nil
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingMonthStep
{
	NSString*				cronExpression = @"* * * 4/2 *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:@[@4, @6, @8, @10, @12]
				 daysOfMonth:nil
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}



// ---------------------------------------------------------
#pragma mark - Extended Features
// ---------------------------------------------------------

/**
 In Jira: part of APPLE-424
 */
- (void) testQuestionMarkAsWildcard
{
	NSString* cronExpression	= @"0 5 ? ? *";			// Every day at 5am.  "?" == "*".
	NSString *startDateString	= @"2014-11-26 00:00";	//
	NSString *endDateString		= @"2014-11-27 00:00";	//

	NSDate *startDate				= [self.dateFormatterInGregorianUTC dateFromString: startDateString];
	NSDate *endDate					= [self.dateFormatterInGregorianUTC dateFromString: endDateString];
	APCScheduleExpression* schedule	= [[APCScheduleExpression alloc] initWithExpression: cronExpression timeZero: 0];
	NSEnumerator* enumerator		= [schedule enumeratorBeginningAtTime: startDate  endingAtTime: endDate];

	[self enumerateOverYears: nil
				  daysOfWeek: nil
					  months: nil
				 daysOfMonth: nil
					   hours: @[@5]
					 minutes: @[@0]
			  startingOnDate: startDate
				endingOnDate: endDate
		 comparingEnumerator: enumerator];
}


// ---------------------------------------------------------
#pragma mark - The "#" sign:  "5th Monday in a month", etc.
// ---------------------------------------------------------

/*
 Some known dates for testing:

	sun	mon	tue	wed	thu	fri	sat

 November, 2014
							1
	2	3	4	5	6	7	8
	9	10	11	12	13	14	15
	16	17	18	19	20	21	22
	23	24	25	26	27	28	29
	30

 December, 2014
 
		1	2	3	4	5	6
	7	8	9	10	11	12	13
	14	15	16	17	18	19	20
	21	22	23	24	25	26	27
	28	29	30	31
 
 January, 2015
					1	2	3
	4	5	6	7	8	9	10
	11	12	13	14	15	16	17
	18	19	20	21	22	23	24
	25	26	27	28	29	30	31
 */

/**
 Returns Monday, December 1, 2014, at midnight.
 */
- (NSDate *) wellKnownMonday
{
	// Please leave these lines here, as a reminder of this implementation decision.
//	NSDateComponents *components = [NSDateComponents componentsInGregorianUTC];
	NSDateComponents *components = [NSDateComponents componentsInGregorianLocal];
	components.year		= 2014;
	components.month	= 12;
	components.day		= 1;

	return components.date;
}

/**
 In Jira: part of APPLE-424, APPLE-598

 Using dates from the visual calendar above.
 */
- (void) testEnumerateFirstMondays
{
	NSString* cronExpression		= @"0 0 * * 1#1";		// Every day at midnight.  "1#1" means "the 1st Monday of the month."
	NSString* startDateString		= @"2014-11-01 00:00";	// Saturday
	NSString* endDateString			= @"2015-01-31 00:00";	// Saturday

	NSDate *startDate				= [self.dateFormatterInGregorianUTC dateFromString: startDateString];
	NSDate *endDate					= [self.dateFormatterInGregorianUTC dateFromString: endDateString];
	
	APCScheduleExpression* schedule	= [[APCScheduleExpression alloc] initWithExpression: cronExpression timeZero: 0];
	NSEnumerator* enumerator		= [schedule enumeratorBeginningAtTime: startDate  endingAtTime: endDate];

	XCTAssertEqualObjects (enumerator.nextObject, [self.dateFormatterInGregorianUTC dateFromString: @"2014-11-03 00:00"]);
	XCTAssertEqualObjects (enumerator.nextObject, [self.dateFormatterInGregorianUTC dateFromString: @"2014-12-01 00:00"]);
	XCTAssertEqualObjects (enumerator.nextObject, [self.dateFormatterInGregorianUTC dateFromString: @"2015-01-05 00:00"]);
	XCTAssertNil		  (enumerator.nextObject);
}

/**
 In Jira: part of APPLE-424, APPLE-598

 Using dates from the visual calendar above.
 */
- (void) testEnumerateFirstAndThirdMondays
{
	NSString* cronExpression	= @"0 0 * * 1#1,1#3";	// Every day at midnight.  "1#3" means "the 3rd Monday of the month."
	NSString* startDateString	= @"2014-11-01 00:00";	// Saturday
	NSString* endDateString		= @"2015-01-31 00:00";	// Saturday

	NSDate *startDate				= [self.dateFormatterInGregorianUTC dateFromString: startDateString];
	NSDate *endDate					= [self.dateFormatterInGregorianUTC dateFromString: endDateString];
	APCScheduleExpression* schedule	= [[APCScheduleExpression alloc] initWithExpression: cronExpression timeZero: 0];
	NSEnumerator* enumerator		= [schedule enumeratorBeginningAtTime: startDate  endingAtTime: endDate];

	XCTAssertEqualObjects ( enumerator.nextObject, [self.dateFormatterInGregorianUTC dateFromString: @"2014-11-03 00:00"] );
	XCTAssertEqualObjects ( enumerator.nextObject, [self.dateFormatterInGregorianUTC dateFromString: @"2014-11-17 00:00"] );
	XCTAssertEqualObjects ( enumerator.nextObject, [self.dateFormatterInGregorianUTC dateFromString: @"2014-12-01 00:00"] );
	XCTAssertEqualObjects ( enumerator.nextObject, [self.dateFormatterInGregorianUTC dateFromString: @"2014-12-15 00:00"] );
	XCTAssertEqualObjects ( enumerator.nextObject, [self.dateFormatterInGregorianUTC dateFromString: @"2015-01-05 00:00"] );
	XCTAssertEqualObjects ( enumerator.nextObject, [self.dateFormatterInGregorianUTC dateFromString: @"2015-01-19 00:00"] );
	XCTAssertNil          ( enumerator.nextObject );
}

/**
 In Jira: part of APPLE-424, APPLE-598

 Using dates from the visual calendar above.
 */
- (void) testEnumerateSpecificMonthDaysAndWeekDays
{
	// All Sundays, the third Monday, and the 1st and 15th of the month, at midnight.
	NSString* cronExpression	= @"0 0 1,15 * 0,1#3";
	NSString* startDateString	= @"2014-11-01 00:00";
	NSString* endDateString		= @"2015-01-31 00:00";

	NSDate *startDate				= [self.dateFormatterInGregorianUTC dateFromString: startDateString];
	NSDate *endDate					= [self.dateFormatterInGregorianUTC dateFromString: endDateString];
	APCScheduleExpression* schedule	= [[APCScheduleExpression alloc] initWithExpression: cronExpression timeZero: 0];
	NSEnumerator* enumerator		= [schedule enumeratorBeginningAtTime: startDate  endingAtTime: endDate];

	NSArray *expectedDates = @[
							   @"2014-11-01 00:00",
							   @"2014-11-02 00:00",
							   @"2014-11-09 00:00",
							   @"2014-11-15 00:00",
							   @"2014-11-16 00:00",
							   @"2014-11-17 00:00",
							   @"2014-11-23 00:00",
							   @"2014-11-30 00:00",

							   @"2014-12-01 00:00",
							   @"2014-12-07 00:00",
							   @"2014-12-14 00:00",
							   @"2014-12-15 00:00",
							   @"2014-12-21 00:00",
							   @"2014-12-28 00:00",

							   @"2015-01-01 00:00",
							   @"2015-01-04 00:00",
							   @"2015-01-11 00:00",
							   @"2015-01-15 00:00",
							   @"2015-01-18 00:00",
							   @"2015-01-19 00:00",
							   @"2015-01-25 00:00",
							   ];

	for (NSString *dateString in expectedDates)
	{
		NSDate *enumeratorDate = enumerator.nextObject;
		NSDate *testHarnessDate = [self.dateFormatterInGregorianUTC dateFromString: dateString];
		XCTAssertEqualObjects (enumeratorDate, testHarnessDate);
	}

	XCTAssertNil ( enumerator.nextObject );
}



// ---------------------------------------------------------
#pragma mark - Days of the week (see note)
// ---------------------------------------------------------

/*
 Note (er, WARNING, maybe):  specify zero-based days of the
 week, not one-based, for both the cron input (the string)
 and the test-harness input (the NSArray).  Example:

 #		NSString* cronExpression = "* * * * 0,2"	// means:  Sunday and Tuesday
 #
 #		[self enumeratorOverYears: nil
 #		               daysOfWeek: @[@0,@2]			// also Sunday and Tuesday
 #		                           ...
 #		];

 */

- (void)testEnumeratingConstantDayOfWeek
{
	NSString*				cronExpression = @"* * * * 2";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression: cronExpression timeZero: 0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime: [self.dateFormatterInGregorianUTC dateFromString: @"2014-01-01 00:00"]];

	[self enumerateOverYears: nil
				  daysOfWeek: @[@2]
					  months: nil
				 daysOfMonth: nil
					   hours: nil
					 minutes: nil
		 comparingEnumerator: enumerator];
}

- (void)testEnumeratingDayOfWeekList
{
//	NSString*				cronExpression = @"* * * * 2,4,6,7";
	NSString*				cronExpression = @"0 0 * * 2,4,6";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression: cronExpression timeZero: 0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime: [self.dateFormatterInGregorianUTC dateFromString: @"2014-01-01 00:00"]];

	[self enumerateOverYears: nil
//				  daysOfWeek: @[@2, @4, @6, @7]			// the real test
				  daysOfWeek: @[@2, @4, @6]
					  months: nil
				 daysOfMonth: nil
//					   hours: nil   minutes: nil		// the real test
					   hours: @[@0] minutes: @[@0]
		 comparingEnumerator: enumerator];
}

- (void)testEnumeratingDayOfWeekRange
{
	NSString*				cronExpression = @"* * * * 3-6";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression: cronExpression timeZero: 0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime: [self.dateFormatterInGregorianUTC dateFromString: @"2014-01-01 00:00"]];

	[self enumerateOverYears: nil
				  daysOfWeek: @[@3, @4, @5, @6]
					  months: nil
				 daysOfMonth: nil
					   hours: nil
					 minutes: nil
		 comparingEnumerator: enumerator];
}

- (void)testEnumeratingEarlyDayOfWeekStep
{
	NSString*				cronExpression = @"* * * * 1/2";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:@[@1, @3, @5]
					  months:nil
				 daysOfMonth:nil
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingDayOfWeekEqualsStep
{
//	NSString*				cronExpression = @"* * * * 2/2";		// the real test
	NSString*				cronExpression = @"0 0 * * 2/2";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:@[@2, @4, @6]
					  months:nil
				 daysOfMonth:nil
//					   hours:nil		// the real test
//					 minutes:nil		// the real test
					   hours:@[@0]
					 minutes:@[@0]
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingDayOfWeekIsStepPlusOne
{
//	NSString*				cronExpression = @"* * * * 3/2";		// the real test
	NSString*				cronExpression = @"0 0 * * 3/2";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:@[@3, @5]
					  months:nil
				 daysOfMonth:nil
//					   hours:nil   minutes:nil		// the real test
					   hours:@[@0] minutes:@[@0]
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingLateDayOfWeekStep
{
	NSString*				cronExpression = @"* * * * 4/2";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:@[@4, @6]
					  months:nil
				 daysOfMonth:nil
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingDayOfWeekRangeAndStep
{
	NSString*				cronExpression = @"* * * * 1-4/2";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:@[@1, @3]
					  months:nil
				 daysOfMonth:nil
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}



// ---------------------------------------------------------
#pragma mark - Combinations
// ---------------------------------------------------------

- (void)testEnumeratingMinutesAndHours
{
	NSString*				cronExpression = @"5 10 * * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:01"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:nil
					   hours:@[@10]
					 minutes:@[@5]
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingMinutesHoursAndDay
{
	NSString*				cronExpression = @"5 10 20 * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:01"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:@[@20]
					   hours:@[@10]
					 minutes:@[@5]
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingMinutesHoursDayAndMonth
{
	NSString*				cronExpression = @"5 10 20 9 *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:01"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:@[@9]
				 daysOfMonth:@[@20]
					   hours:@[@10]
					 minutes:@[@5]
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingMinutesHourDayMonthsAndDayOfWeek
{
	NSString*				cronExpression = @"5 10 20 9 4";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatterInGregorianUTC dateFromString:@"2014-01-01 00:01"]];

	[self enumerateOverYears:nil
				  daysOfWeek:@[@4]
					  months:@[@9]
				 daysOfMonth:@[@20]
					   hours:@[@10]
					 minutes:@[@5]
		 comparingEnumerator:enumerator];
}



// ---------------------------------------------------------
#pragma mark - Realistic tests
// ---------------------------------------------------------

/**
 In Jira: part of APPLE-424, APPLE-598

 Goal: make sure the dates that come out of the enumerator
 are in the user's time zone.
 
 This is used by
	-[APCScheduler generateScheduledTasksForSchedule],
 which calls
	-[APCScheduler createScheduleTask:task:starOn:].

 The real-life situation this test represents:  The user
 is looking at a list of stuff to do.  The list contains
 exactly one, two, or three days:
 - today only (whatever "today" is)
 - today and tomorrow
 - yesterday, today, and tomorrow
 
 The point is that the user needs to know what the doctors
 need him or her to do on those days:  check blood
 pressure, do jumping jacks, etc.  The user isn't looking
 a week into the future or the past -- that makes no
 real-life sense.
 
 However:  since that 3-day span can be any 3 days, we need
 to make sure that the dates and times coming out of the
 enumerator are correct days, even if
 - the 3 days span a daylight-savings boundary
 - the user is in different time zones on different days
 - the days are in different months
 
 So this test will check those various time ranges, and
 ensure that the times coming out of the enumerator
 are indeed the expected times on each day.
 
 In addition, all our internal calculations are done in
 UTC (Greenwich Mean Time, without daylight-savings added).
 The cron expressions, though, are phrased in the user's
 local time zone.  Let's make sure that's what we're
 delivering.
 */
- (void) testCorrectTimeZone
{
	NSString* cronExpression		= @"0 12,17 * * 1";		// noon and 5pm every Monday
	NSString* startDateString		= @"2014-11-01 00:00";
	NSString* endDateString			= @"2014-12-01 00:00";

	NSTimeInterval userWakeupTimeOffset	= 0;

	NSDateFormatter *dateFormatterInGregorianPacificTime = [NSDateFormatter new];
	dateFormatterInGregorianPacificTime.dateFormat = @"yyyy-MM-dd HH:mm";
	dateFormatterInGregorianPacificTime.calendar = [NSCalendar currentCalendar];

	NSTimeZone *zoneWhereRunningThisTest = [NSTimeZone localTimeZone];
	dateFormatterInGregorianPacificTime.timeZone = zoneWhereRunningThisTest;

	NSDate *startDateInPacificTime = [dateFormatterInGregorianPacificTime dateFromString: startDateString];
	NSDate *endDateInPacificTime   = [dateFormatterInGregorianPacificTime dateFromString: endDateString];

	APCScheduleExpression* schedule	= [[APCScheduleExpression alloc] initWithExpression: cronExpression
																			   timeZero: userWakeupTimeOffset];

	NSEnumerator* enumerator = [schedule enumeratorBeginningAtTime: startDateInPacificTime
													  endingAtTime: endDateInPacificTime];

	NSArray *expectedDates = @[
							   @"2014-11-03 12:00",
							   @"2014-11-03 17:00",
							   @"2014-11-10 12:00",
							   @"2014-11-10 17:00",
							   @"2014-11-17 12:00",
							   @"2014-11-17 17:00",
							   @"2014-11-24 12:00",
							   @"2014-11-24 17:00",
							   ];


	// This is part of the realistic test:  loop through, extract every value, create something useful from it.

	NSDate *testHarnessDate = nil;
	NSDate *enumeratorDate = nil;

	for (NSString *testHarnessDateString in expectedDates)
	{
		testHarnessDate = [dateFormatterInGregorianPacificTime dateFromString: testHarnessDateString];
		NSTimeInterval offset = [zoneWhereRunningThisTest secondsFromGMTForDate: testHarnessDate];
		testHarnessDate = [testHarnessDate dateByAddingTimeInterval: offset];

		enumeratorDate = enumerator.nextObject;

		XCTAssertEqualObjects (enumeratorDate, testHarnessDate);
	}

	XCTAssertNil (enumerator.nextObject);
}

- (void) testRealTestCase
{
	NSString* cronExpression = @"0 5 * * *";		// noon and 5pm every Monday

	NSDateFormatter * dateFormatterInGregorianPacificTime = [NSDateFormatter new];
	dateFormatterInGregorianPacificTime.dateFormat = @"yyyy-MM-dd HH:mm";
	dateFormatterInGregorianPacificTime.calendar = [NSCalendar currentCalendar];
	dateFormatterInGregorianPacificTime.timeZone = [NSTimeZone localTimeZone];

	NSTimeInterval userWakeupTimeOffset	= 0;
	APCScheduleExpression* schedule	= [[APCScheduleExpression alloc] initWithExpression: cronExpression
																			   timeZero: userWakeupTimeOffset];

	NSDate *todayAtMidnight = [NSDate todayAtMidnight];
	NSDate *tomorrowAtMidnight = [NSDate tomorrowAtMidnight];

	NSLog (@"Today    at midnight : %@", [dateFormatterInGregorianPacificTime stringFromDate: todayAtMidnight]);
	NSLog (@"Tomorrow at midnight : %@", [dateFormatterInGregorianPacificTime stringFromDate: tomorrowAtMidnight]);

	NSEnumerator* enumerator = [schedule enumeratorBeginningAtTime: todayAtMidnight
													  endingAtTime: tomorrowAtMidnight];

	NSDate *date = nil;
	while ((date = enumerator.nextObject) != nil)
	{
		NSLog (@"Enumerator date      : %@", [dateFormatterInGregorianPacificTime stringFromDate:date]);
	}
}

- (void) testRealTestCase2
{
	NSString* cronExpression = @"0 5 * * 1";		// noon and 5pm every Monday

	NSDateFormatter * dateFormatterInGregorianPacificTime = [NSDateFormatter new];
	dateFormatterInGregorianPacificTime.dateFormat = @"yyyy-MM-dd HH:mm";
	dateFormatterInGregorianPacificTime.calendar = [NSCalendar currentCalendar];
	dateFormatterInGregorianPacificTime.timeZone = [NSTimeZone localTimeZone];

	NSTimeInterval userWakeupTimeOffset	= 0;
	APCScheduleExpression* schedule	= [[APCScheduleExpression alloc] initWithExpression: cronExpression
																			   timeZero: userWakeupTimeOffset];

	NSDate *lastWeekAtMidnight = [NSDate weekAgoAtMidnight];
	NSDate *tomorrowAtMidnight = [NSDate tomorrowAtMidnight];

	NSLog (@"Week ago at midnight : %@", [dateFormatterInGregorianPacificTime stringFromDate: lastWeekAtMidnight]);
	NSLog (@"Tomorrow at midnight : %@", [dateFormatterInGregorianPacificTime stringFromDate: tomorrowAtMidnight]);

	NSEnumerator* enumerator = [schedule enumeratorBeginningAtTime: lastWeekAtMidnight
													  endingAtTime: tomorrowAtMidnight];

	NSDate * date = nil;
	while ((date = enumerator.nextObject) != nil)
	{
		NSLog (@"Enumerator date      : %@", [dateFormatterInGregorianPacificTime stringFromDate: date]);
	}
}



// ---------------------------------------------------------
#pragma mark - Purposeful failures
// ---------------------------------------------------------

- (void) testNilString
{
	//	[self performTestWithCronExpression: nil
	//					   betweenStartDate: @"2014-01-01 00:00"
	//							 andEndDate: nil
	//						 overTheseYears: nil
	//							 daysOfWeek: nil
	//								 months: nil
	//							daysOfMonth: nil
	//								  hours: nil
	//								minutes: nil];
}

@end
