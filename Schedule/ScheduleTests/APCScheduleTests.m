//
//  APCScheduleTests.m
//  Schedule
//
//  Created by Edward Cessna on 10/8/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APCScheduleExpression.h"


// Ron:  I wrote code to use the correct number of days per month, but haven't yet made the Enumerators do that.  So:
#define DEBUG__SHOULD_USE_CORRECT_DAYS_PER_MONTH  NO


@interface APCScheduleTests : XCTestCase

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

@implementation APCScheduleTests



// ---------------------------------------------------------
#pragma mark - Setup
// ---------------------------------------------------------

- (void)setUp
{
    [super setUp];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-8 * 60 * 60]];

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
 @param cronExpression
	A bunch of complex things that we're testing.  :-)
	For starters, a string in this format:  @"A * * * * *"
	Then replace the "*"s with the various types of legal
	values.  See Ed, Dhanush, or Ron for options.

 @param startDateString  nil, or a string in this format:  @"2014-01-01 00:00"
 @param endDateString    nil, or a string in this format:  @"2014-01-01 00:00"
 */
- (void) performTestWithCronExpression: (NSString *) cronExpression
					  betweenStartDate: (NSString *) startDateString
							andEndDate: (NSString *) endDateString
						overTheseYears: (NSArray *) years
							daysOfWeek: (NSArray *) zeroBasedDaysOfWeek
								months: (NSArray *) months
						   daysOfMonth: (NSArray *) daysOfMonth
								 hours: (NSArray *) hours
							   minutes: (NSArray *) minutes
{
	APCScheduleExpression* schedule = [[APCScheduleExpression alloc] initWithExpression: cronExpression
														   timeZero: 0];

	NSDate *startDate = startDateString == nil ? nil : [self.dateFormatter dateFromString: startDateString];
	NSDate *endDate   = endDateString   == nil ? nil : [self.dateFormatter dateFromString: endDateString];

	NSEnumerator* enumerator = [schedule enumeratorBeginningAtTime: startDate
													  endingAtTime: endDate];

	[self enumerateOverYears: years
				  daysOfWeek: zeroBasedDaysOfWeek
					  months: months
				 daysOfMonth: daysOfMonth
					   hours: hours
					 minutes: minutes
		 comparingEnumerator: enumerator];
}

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
    NSDate* enumeratorDate = nil;

	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	dateComponents.calendar = self.calendar;
	NSDate* testHarnessDate = nil;


	// We'll calculate the real days-in-each-month shortly.
	// In the meantime:
	years	= years.count	? years	  : self.everyYear;
    months	= months.count	? months  : self.everyMonth;
    hours	= hours.count	? hours	  : self.everyHour;
    minutes	= minutes.count	? minutes : self.everyMinute;

    for (NSNumber* aYear in years)
    {
		dateComponents.year = aYear.integerValue;

        for (NSNumber* aMonth in months)
        {
			dateComponents.month = aMonth.integerValue;

			NSArray *realDaysInMonth = [self calculateRealDaysInMonth: aMonth
															  andYear: aYear
													  givenTheseDates: daysOfMonth
												   andTheseDaysOfWeek: zeroBasedDaysOfWeek];

            for (NSNumber* aDay in realDaysInMonth)
            {
				dateComponents.day = aDay.integerValue;

                for (NSNumber* aHour in hours)
                {
					dateComponents.hour = aHour.integerValue;

                    for (NSNumber* aMinute in minutes)
                    {
                        dateComponents.minute = aMinute.integerValue;
                        testHarnessDate = [dateComponents date];

                        enumeratorDate = [enumerator nextObject];

//						//
//						// Ed's original printout:
//						//
//                        if ([date isEqualToDate:nextMoment] == NO)
//                        {
//							NSLog(@"Year: %@, Month: %@, Day: %@, Hour: %@, Minute: %@", aYear, aMonth, aDay, aHour, aMinute);
//                        }


						// Ron's debugging version:
						NSDateComponents *nextMomentComponents = [self.calendar components: (NSCalendarUnitYear |
																							 NSCalendarUnitMonth |
																							 NSCalendarUnitDay |
																							 NSCalendarUnitHour |
																							 NSCalendarUnitMinute)
																				  fromDate: enumeratorDate];

						if ([testHarnessDate isEqualToDate: enumeratorDate])
						{
//							NSLog (@"MATCH:     local %02d.%02d.%02d %02d:%02d == enumerator %02d.%02d.%02d %02d:%02d",
//								   aYear.intValue, aMonth.intValue, aDay.intValue, aHour.intValue, aMinute.intValue,
//								   (int) nextMomentComponents.year,
//								   (int) nextMomentComponents.month,
//								   (int) nextMomentComponents.day,
//								   (int) nextMomentComponents.hour,
//								   (int) nextMomentComponents.minute);
						}
						else
						{
							NSLog (@"NO MATCH:  local %02d.%02d.%02d %02d:%02d != enumerator %02d.%02d.%02d %02d:%02d",
								   aYear.intValue, aMonth.intValue, aDay.intValue, aHour.intValue, aMinute.intValue,
								   (int) nextMomentComponents.year,
								   (int) nextMomentComponents.month,
								   (int) nextMomentComponents.day,
								   (int) nextMomentComponents.hour,
								   (int) nextMomentComponents.minute);
						}

                        XCTAssertEqualObjects(enumeratorDate, testHarnessDate);
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
	That's complex enough to be worth thinking about.
 
 3)	At some point, we'll have to/want to account for the
	correct number of days in a given month.  For now, we're
	always using "31".
 
 4)	Given all that:  do we put that logic in the code being
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
					andTheseDaysOfWeek: (NSArray *) cronZeroBasedDaysOfWeek
{
    NSMutableArray *computedDaysInMonth = nil;

    NSDateComponents* dayOfMonthDetector	= [NSDateComponents new];
    dayOfMonthDetector.calendar				= self.calendar;
    dayOfMonthDetector.year					= year.integerValue;
    dayOfMonthDetector.month				= month.integerValue;
    NSDate *firstDateInMonth				= dayOfMonthDetector.date;
    
    NSRange legalDaysInMonth = [self.calendar rangeOfUnit: NSCalendarUnitDay
                                                   inUnit: NSCalendarUnitMonth
                                                  forDate: firstDateInMonth];
    
    if (daysInMonth.count == 0 && cronZeroBasedDaysOfWeek.count == 0)
    {
        computedDaysInMonth = self.everyDay.mutableCopy;

		if (DEBUG__SHOULD_USE_CORRECT_DAYS_PER_MONTH)
		{
			/*
			 A slightly *faster* operation would be:
			 - calculate the number of days to remove
			 - create an NSRange representing those indices
			 - tell the array to remove that range of objects

			 But:
			 -	I think the below is much more readable, and
			 -	this loop will only happen three times at most
				(for the 29th, 30th, and 31st of the month).
			 */
			while (computedDaysInMonth.count > legalDaysInMonth.length)
			{
				[computedDaysInMonth removeLastObject];
			}
		}
    }

    else
    {
		computedDaysInMonth = [NSMutableArray new];

		if (daysInMonth.count > 0)
		{
			[computedDaysInMonth addObjectsFromArray: daysInMonth];
		}

		if (cronZeroBasedDaysOfWeek.count > 0)
		{
			for (NSInteger thisDayOfMonth = legalDaysInMonth.location;
				 thisDayOfMonth < legalDaysInMonth.location + legalDaysInMonth.length;
				 thisDayOfMonth ++)
			{
				NSNumber *thisDayOfMonthObject = @(thisDayOfMonth);

				if (! [computedDaysInMonth containsObject: thisDayOfMonthObject])
				{
					// Ask our Calendar object to determine the day of week for this date.
					dayOfMonthDetector.day = thisDayOfMonth;
					NSDate *thisDate = dayOfMonthDetector.date;
					NSInteger nsdateOneBasedDayOfWeek = [self.calendar component: NSCalendarUnitWeekday
																		fromDate: thisDate];

					// Convert it to the cron-based days we were fed.
					NSInteger cronZeroBasedDayOfWeek = nsdateOneBasedDayOfWeek - 1;
					if (cronZeroBasedDayOfWeek < 1) cronZeroBasedDayOfWeek += 7;

					NSNumber *thisCronDayOfWeekObj = @(cronZeroBasedDayOfWeek);

					// Add the date if this cron-based day is in the list.
					if ([cronZeroBasedDaysOfWeek containsObject: thisCronDayOfWeekObj])
					{
						[computedDaysInMonth addObject: thisDayOfMonthObject];
					}
				}
			}

			// What'd we get?
			if (computedDaysInMonth.count)
			{
				[computedDaysInMonth sortUsingComparator:^NSComparisonResult (NSNumber *day1, NSNumber *day2) {
					return [day1 compare: day2];
				}];
			}
		}
    }

    return computedDaysInMonth;
}



// =========================================================
#pragma mark - Individual testing methods -
// =========================================================


// ---------------------------------------------------------
#pragma mark - Minutes
// ---------------------------------------------------------

- (void)testEnumerationOfConstantMinutes
{
    NSString*       cronExpression = @"A 5 * * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
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
    NSString*       cronExpression    = @"A 5 * * * *";
    APCScheduleExpression*    schedule          = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   boundedEnumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]
                                                               endingAtTime:[self.dateFormatter dateFromString:@"2014-01-01 23:59"]];

	[self enumerateOverYears:@[@2014]
				  daysOfWeek:nil
					  months:@[@1]
				 daysOfMonth:@[@1]
					   hours:nil
					 minutes:@[@5]
		 comparingEnumerator:boundedEnumerator];
    XCTAssertNil([boundedEnumerator nextObject]);
}

- (void)testEnumeratingMinuteList
{
    NSString*       cronExpression = @"A 15,30,45 * * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];

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
    NSString*       cronExpression = @"A 15-30 * * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
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
    NSString*       cronExpression = @"A */15 * * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
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
    NSString*       cronExpression = @"A 15-30/5 * * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
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
    NSString*       cronExpression = @"A 10-12,20-22 * * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
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
    NSString*       cronExpression = @"A * 10 * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 08:00"]];
    
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
    NSString*       cronExpression = @"A * 8,12,16 * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 08:00"]];
    
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
    NSString*       cronExpression = @"A * 8-17 * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 08:00"]];
    
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
    NSString*       cronExpression = @"A * 8/4 * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 08:00"]];
    
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
    NSString*       cronExpression = @"A * * 15 * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:@[@15]
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingDayOfMonthList
{
    NSString*       cronExpression = @"A * * 15,30 * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
	[self enumerateOverYears:nil
				  daysOfWeek:nil
					  months:nil
				 daysOfMonth:@[@15, @30]
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}

- (void)testEnumeratingDayOfMonthRange
{
    NSString*       cronExpression = @"A * * 1-14 * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
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
	NSString*       cronExpression = @"A * * 10/5 * *";
	APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

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
//		NSString*       cronExpression = @"A * * 1-5/5 * *";
//		APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
//		NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
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
//		NSString*       cronExpression = @"A * * 10-15/5 * *";
//		APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
//		NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
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
    NSString*       cronExpression = @"A * * * 4 *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
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
    NSString*       cronExpression = @"A * * * 2,4,6,8 *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

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
    NSString*       cronExpression = @"A * * * 6-9 *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
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
    NSString*       cronExpression = @"A * * * 4/2 *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
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
	[self performTestWithCronExpression: @"A * * * * 2"
					   betweenStartDate: @"2014-01-01 00:00"
							 andEndDate: nil
						 overTheseYears: nil
							 daysOfWeek: @[@2]
								 months: nil
							daysOfMonth: nil
								  hours: nil
								minutes: nil];
}

- (void)testEnumeratingDayOfWeekList
{
	[self performTestWithCronExpression: @"A * * * * 2,4,6,7"
					   betweenStartDate: @"2014-01-01 00:00"
							 andEndDate: nil
						 overTheseYears: nil
							 daysOfWeek: @[@2, @4, @6, @7]
								 months: nil
							daysOfMonth: nil
								  hours: nil
								minutes: nil];
}

- (void)testEnumeratingDayOfWeekRange
{
	[self performTestWithCronExpression: @"A * * * * 3-6"
					   betweenStartDate: @"2014-01-01 00:00"
							 andEndDate: nil
						 overTheseYears: nil
							 daysOfWeek: @[@3, @4, @5, @6]
								 months: nil
							daysOfMonth: nil
								  hours: nil
								minutes: nil];
}

- (void)testEnumeratingEarlyDayOfWeekStep
{
	NSString*       cronExpression = @"A * * * * 1/2";
	APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

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
	NSString*       cronExpression = @"A * * * * 2/2";
	APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

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
	NSString*       cronExpression = @"A * * * * 3/2";
	APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

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
	NSString*       cronExpression = @"A * * * * 4/2";
	APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

	[self enumerateOverYears:nil
				  daysOfWeek:@[@4, @6]
					  months:nil
				 daysOfMonth:nil
					   hours:nil
					 minutes:nil
		 comparingEnumerator:enumerator];
}

/**
 This fails.
 */
- (void)testEnumeratingDayOfWeekRangeAndStep
{
	NSString*       cronExpression = @"A * * * * 1-4/2";
	APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

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
    NSString*       cronExpression = @"A 5 10 * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
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
    NSString*       cronExpression = @"A 5 10 20 * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
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
    NSString*       cronExpression = @"A 5 10 20 9 *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
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
	NSString*       cronExpression = @"A 5 10 20 9 4";
	APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
	NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];

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
