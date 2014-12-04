//
//  APCScheduleExpressionEnumeratorTests.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APCScheduleExpression.h"


/**
 The test cases in this file print errors (and fail the test)
 if our test-harness-generated dates do not match the
 ScheduleExpression-generated dates.  This #define says:
 in addition, print every case where the dates DO match.
 Very helpful for debugging.
 */
#define DEBUG__PRINT_HAPPY_TEST_CASES  NO


@interface APCScheduleExpressionEnumeratorTests : XCTestCase

@property (nonatomic, strong) NSDateFormatter*  dateFormatter;
@property (nonatomic, strong) NSCalendar*       calendar;

@property (nonatomic, strong) NSArray*   everyYear;
@property (nonatomic, strong) NSArray*   everyMonth;
@property (nonatomic, strong) NSArray*   everyDay;
@property (nonatomic, strong) NSArray*   everyHour;
@property (nonatomic, strong) NSArray*   everyMinute;

@end

NSArray*    NumericSequence(NSInteger begin, NSInteger end)
{
	NSMutableArray* data = [NSMutableArray arrayWithCapacity:end - begin + 1];

	for (NSInteger ndx = begin; ndx <= end; ++ndx)
	{
		[data addObject:@(ndx)];
	}
	return [data copy];
}

@implementation APCScheduleExpressionEnumeratorTests



// ---------------------------------------------------------
#pragma mark - Setup
// ---------------------------------------------------------

- (void)setUp
{
	[super setUp];

	self.dateFormatter = [[NSDateFormatter alloc] init];
	[self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];

	[self.dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-8 * 60 * 60]];
//	[NSTimeZone setDefaultTimeZone: [NSTimeZone timeZoneForSecondsFromGMT:-8 * 60 * 60]];

	self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

	self.everyYear   = NumericSequence(2014, 2017);
	self.everyMonth  = NumericSequence(1, 12);
	self.everyDay    = NumericSequence(1, 31);
	self.everyHour   = NumericSequence(0, 23);
	self.everyMinute = NumericSequence(0, 59);
}

- (void)tearDown
{
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}




// ---------------------------------------------------------
#pragma mark - Core of the test harness
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

	NSDateComponents *testHarnessDateComponents = [[NSDateComponents alloc] init];
	testHarnessDateComponents.calendar = self.calendar;
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

						// Meaning:                        testHarnessDate    >     endDate
						BOOL tooLate = (endDate != nil && [testHarnessDate compare: endDate] == NSOrderedDescending);


						if (! tooEarly && ! tooLate)
						{
							enumeratorDate = [enumerator nextObject];

							NSDateComponents *enumeratorDateComponents = [self.calendar components: (NSCalendarUnitYear |
																									 NSCalendarUnitMonth |
																									 NSCalendarUnitDay |
																									 NSCalendarUnitHour |
																									 NSCalendarUnitMinute)
																						  fromDate: enumeratorDate];

							if ([testHarnessDate isEqualToDate: enumeratorDate])
							{
								if (DEBUG__PRINT_HAPPY_TEST_CASES)
								{
									NSLog (@"MATCH:     testHarness %02d.%02d.%02d %02d:%02d == enumerator %02d.%02d.%02d %02d:%02d",
										   aYear.intValue, aMonth.intValue, aDay.intValue, aHour.intValue, aMinute.intValue,
										   (int) enumeratorDateComponents.year,
										   (int) enumeratorDateComponents.month,
										   (int) enumeratorDateComponents.day,
										   (int) enumeratorDateComponents.hour,
										   (int) enumeratorDateComponents.minute);
								}
							}
							else
							{
								NSLog (@"NO MATCH:  testHarness %02d.%02d.%02d %02d:%02d != enumerator %02d.%02d.%02d %02d:%02d",
									   aYear.intValue, aMonth.intValue, aDay.intValue, aHour.intValue, aMinute.intValue,
									   (int) enumeratorDateComponents.year,
									   (int) enumeratorDateComponents.month,
									   (int) enumeratorDateComponents.day,
									   (int) enumeratorDateComponents.hour,
									   (int) enumeratorDateComponents.minute);
							}

							XCTAssertEqualObjects (testHarnessDate, enumeratorDate);
						}
					}
				}
			}
		}
	}
}

/**
 TODO:  Figure out where to put the test-harness logic which
 translates days of the week to dates-in-a-month, and which
 optionally translates cron's zero-based days to NSDate's
 one-based days.

 Issues:
 1)	The logic to convert weekdays (like "Tuesday") to
	days in a month (like "March 7, 14, 21, and 28")
	is potentially complex.

 2) cron's weekdays are zero-based, while NSDate's weekdays
	are one-based.  We have to translate between those.
	That's complex enough to be worth thinking about --
	not fundamentally difficult, but easy to make mistakes
	with.

 3)	Given all that:  do we put that logic in the code being
	tested, and use it from here?  Or duplicate it in the
	test harness, and run the risk of inducing bugs in both
	places, having to maintain that, and having to test
	our test-harness code?


 Some solutions and problems with them all:
 a)	If we specify cron's zero-based days as input to the test
	harness, we have to translate from zero-based to one-
	based.  This is an easy source of bugs in BOTH places --
	the harness and the code we're trying to test.

 b)	If we specify NSDate's one-based days into the test harness,
	it's much harder to verify that that logic is indeed the same
	in both places -- to verify that we're testing the right thing.

 c)	The code we're testing already HAS all this logic, here:

		-[APCDayOfMonthSelector recomputeDaysForCalendar:]
		-[APCDayOfMonthSelector specificWeekdaysForMonth:]

	So we could just expose that.  But that means using
	the code-being-tested as the stuff we're testing
	AGAINST -- which seems like it invalidates the test;
	we'd just be proving that 1 == 1.

 Ideas?

 For now, I'm doing option (a):  recreating the logic from
 (c), using cron's zero-based days.

 --ron
 */
- (NSArray *) calculateRealDaysInMonth: (NSNumber *) month
							   andYear: (NSNumber *) year
					   givenTheseDates: (NSArray *) daysInMonth
					andTheseDaysOfWeek: (NSArray *) zeroBasedDaysOfWeek
{
	NSMutableArray *computedDaysInMonth	= [NSMutableArray new];

	NSDateComponents* dateComponents	= [NSDateComponents new];
	dateComponents.calendar				= self.calendar;
	dateComponents.year					= year.integerValue;
	dateComponents.month				= month.integerValue;


	//
	// Figure out what days are actually in this month (1..31, 1..28, etc.).
	//
	NSRange rangeOfLegalDaysInMonth = [self.calendar rangeOfUnit: NSCalendarUnitDay
														  inUnit: NSCalendarUnitMonth
														 forDate: dateComponents.date];

	NSMutableArray *legalDaysInMonth = [NSMutableArray new];

	for (NSInteger day = rangeOfLegalDaysInMonth.location;
		 day < rangeOfLegalDaysInMonth.location + rangeOfLegalDaysInMonth.length;
		 day ++)
	{
		[legalDaysInMonth addObject: @(day)];
	}


	//
	// Normalize the zero-based days-of-the-week:  in the "cron"
	// rules, Sunday is both "0" and "7".  Convert all "7"s to
	// "0"s, so we only have to check for "0".
	//
	NSMutableArray *normalizedZeroBasedDaysOfWeek = [NSMutableArray new];

	for (NSNumber *dayOfWeek in zeroBasedDaysOfWeek)
		if (dayOfWeek.integerValue == 7)
			[normalizedZeroBasedDaysOfWeek addObject: @0];
		else
			[normalizedZeroBasedDaysOfWeek addObject: dayOfWeek];


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

		 This same logic (or verrrrrrry similar) is in the ScheduleEnumerator.
		 */
		if (normalizedZeroBasedDaysOfWeek.count)
		{
			for (NSNumber* legalDayInMonth in legalDaysInMonth)
			{
				// Don't waste computing effort if the day-of-month list
				// already specified this date.
				if (! [computedDaysInMonth containsObject: legalDayInMonth])
				{
					dateComponents.day = legalDayInMonth.integerValue;
					NSDate *thisDate = dateComponents.date;
					NSInteger oneBasedDayOfWeek = [self.calendar component: NSCalendarUnitWeekday
																	  fromDate: thisDate];

					NSInteger zeroBasedDayOfWeek = oneBasedDayOfWeek - 1;

					if (zeroBasedDayOfWeek < 0)
						zeroBasedDayOfWeek += 7;

					if ([normalizedZeroBasedDaysOfWeek containsObject: @(zeroBasedDayOfWeek)])
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

- (void) test_Dhanush2014nov26_jiraApple491
{
	NSString* cronExpression = @"0 5 * * *";			// Every day at 5am.
//	NSString* cronExpression = @"0 5,10 * * *";			// Every day at 5 and 10am.
//	NSString* cronExpression = @"0/5 5,10 * * *";		// Every day at 5 and 10am, every 5 mins within those hours.

	NSString *startDateString = @"2014-11-26 00:00";	// Dhanush's original start date
//	NSString *startDateString = @"2015-11-26 00:00";	// testing rolling over a leap year

//	NSString *endDateString = @"2014-11-26 06:00";		//
	NSString *endDateString = @"2014-11-27 00:00";		// Dhanush's original end date
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
	NSDate *startDate				= [self.dateFormatter dateFromString: startDateString];
	NSDate *endDate					= [self.dateFormatter dateFromString: endDateString];
	NSEnumerator* enumerator		= [schedule enumeratorBeginningAtTime: startDate  endingAtTime: endDate];


	/*
	 This is Dhanush's original test.  It should print out exactly
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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];

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
	NSEnumerator*			boundedEnumerator = [schedule enumeratorBeginningAtTime: [self.dateFormatter dateFromString: @"2014-01-01 00:00"]
											                           endingAtTime: [self.dateFormatter dateFromString: @"2014-01-01 23:59"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:nil
					   hours:nil
					 minutes:NumericSequence(15, 30)
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingMinuteStep
{
	NSString*				cronExpression = @"*/15 * * * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 08:00"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 08:00"]];

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
	NSEnumerator*			enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 08:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:nil
					   hours:NumericSequence(8, 17)
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingHourStep
{
	NSString*				cronExpression = @"* 8/4 * * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 08:00"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:NumericSequence(1, 14)
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingDayOfMonthStep
{
	NSString*				cronExpression = @"* * 10/5 * *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

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
	NSEnumerator*			enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:NumericSequence(6, 9)
				 daysOfMonth:nil
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingMonthStep
{
	NSString*				cronExpression = @"* * * 4/2 *";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:@[@4, @6, @8, @10, @12]
				 daysOfMonth:nil
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime: [self.dateFormatter dateFromString: @"2014-01-01 00:00"]];

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
	NSString*				cronExpression = @"* * * * 2,4,6,7";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression: cronExpression timeZero: 0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime: [self.dateFormatter dateFromString: @"2014-01-01 00:00"]];

	[self enumerateOverYears: nil
				  daysOfWeek: @[@2, @4, @6, @7]
					  months: nil
				 daysOfMonth: nil
					   hours: nil
					 minutes: nil
		 comparingEnumerator: enumerator];
}

- (void)testEnumeratingDayOfWeekRange
{
	NSString*				cronExpression = @"* * * * 3-6";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression: cronExpression timeZero: 0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime: [self.dateFormatter dateFromString: @"2014-01-01 00:00"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

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
	NSString*				cronExpression = @"* * * * 2/2";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:@[@2, @4, @6]
					  months:nil
				 daysOfMonth:nil
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingDayOfWeekIsStepPlusOne
{
	NSString*				cronExpression = @"* * * * 3/2";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:@[@3, @5]
					  months:nil
				 daysOfMonth:nil
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingLateDayOfWeekStep
{
	NSString*				cronExpression = @"* * * * 4/2";
	APCScheduleExpression*	schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];

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
	NSEnumerator*			enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];

	[self enumerateOverYears:nil
				  daysOfWeek:@[@4]
					  months:@[@9]
				 daysOfMonth:@[@20]
					   hours:@[@10]
					 minutes:@[@5]
		 comparingEnumerator:enumerator];
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
