//
//  APCScheduleExpressionRealLifeTests.m
//  APCAppCore
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APCScheduleExpression.h"
#import "NSDate+Helper.h"

@interface APCScheduleExpressionRealLifeTests : XCTestCase
@property (nonatomic, strong) NSDateFormatter *dateFormatterInGregorianUTC;
@property (nonatomic, strong) NSDateFormatter *dateFormatterInGregorianPacificTime;
@end

@implementation APCScheduleExpressionRealLifeTests

/**
 Put setup code here. This method is called before the invocation of each test method in the class.
 */
- (void) setUp
{
	[super setUp];

	self.dateFormatterInGregorianUTC = [NSDateFormatter new];
	self.dateFormatterInGregorianUTC.dateFormat = @"EEE yyyy-MM-dd HH:mm";
	self.dateFormatterInGregorianUTC.calendar = [NSCalendar currentCalendar];
	self.dateFormatterInGregorianUTC.timeZone = [NSTimeZone timeZoneWithAbbreviation: @"UTC"];

	self.dateFormatterInGregorianPacificTime = [NSDateFormatter new];
	self.dateFormatterInGregorianPacificTime.dateFormat = @"EEE yyyy-MM-dd HH:mm";
	self.dateFormatterInGregorianPacificTime.calendar = [NSCalendar currentCalendar];
	self.dateFormatterInGregorianPacificTime.timeZone = [NSTimeZone localTimeZone];
}

/**
 Put teardown code here. This method is called after the invocation of each test method in the class.
 */
- (void) tearDown
{
	[super tearDown];
}


/*
 Some known dates for testing:

 -		sun	mon	tue	wed	thu	fri	sat
 -
 -	November, 2014
 -								1
 -		2	3	4	5	6	7	8
 -		9	10	11	12	13	14	15
 -		16	17	18	19	20	21	22
 -		23	24	25	26	27	28	29
 -		30
 -
 -	December, 2014
 -			1	2	3	4	5	6
 -		7	8	9	10	11	12	13
 -		14	15	16	17	18	19	20
 -		21	22	23	24	25	26	27
 -		28	29	30	31
 -
 -	January, 2015
 -						1	2	3
 -		4	5	6	7	8	9	10
 -		11	12	13	14	15	16	17
 -		18	19	20	21	22	23	24
 -		25	26	27	28	29	30	31
 -
 -	February, 2015
 -		1	2	3	4	5	6	7
 -		8	9	10	11	12	13	14
 -		15	16	17	18	19	20	21
 -		22	23	24	25	26	27	28
 -
 -	March, 2015
 -		1	2	3	4	5	6	7
 -		8	9	10	11	12	13	14
 -		15	16	17	18	19	20	21
 -		22	23	24	25	26	27	28
 -		29	30	31
 */



- (void) testRealisticTests
{
	/*
	 All of these should work with every combination of start
	 and end dates, below.
	 */

//	NSString* cronExpression = @"0 5 * * *";											// 5am every day
//	NSString* cronExpression = @"0 5 * * 1";											// 5am every Monday
//	NSString* cronExpression = @"0 5 * * 1#1";											// 5am, only first Monday
//	NSString* cronExpression = @"0 5 * * wed#3";										// 5am, only third Wednesday
//	NSString* cronExpression = @"0 5 * * 1#2";											// 5am, only second Monday
//	NSString* cronExpression = @"0 5,10,12,17,20 * * *";								// several every day
//	NSString* cronExpression = @"0 5,10,12,17,20 * * 1";								// several only on Mondays
//	NSString* cronExpression = @"0 0 5 * * * *";										// 7 fields:  5am every day
//	NSString* cronExpression = @"0 0 5 * * 1 *";										// 7 fields:  5am every Monday
//	NSString* cronExpression = @"0 0 6 ? 1/1 THU#1 *";									// from Sage
//	NSString* cronExpression = @"0 0 6 ? * FRI *";										// from Sage
//	NSString* cronExpression = @"0 5 * DEC,NOV,JUL THU,FRI,MON#1,TUE#2";				// Replacing strings with numbers
//	NSString* cronExpression = @"   0  5  *  DEC,NOV,JUL   THU,FRI,MON#1,TUE#2   ";		// replacing lots of whitespace
//	NSString* cronExpression = @"  0	\n 5  *   * \r  *		  ";					// 5am every day, with spaces, tabs, hidden tabs, and newlines


	// Ron:  testing new versions
//	NSString* cronExpression = @"0 5 * SEP,JUL,OCT/2,JAN-MAR THU,FRI,MON#1,TUE#2";
//	NSString* cronExpression = @"0 5 * SEP,JUL,OCT/2,jAn-MAr THU,FRI,MON#1,TUE#2";
//	NSString* cronExpression = @"0 5 * SEP,JUL,OCT/2,jAn-MAr THU,duuuude,MON#1,TUE#2";
	NSString* cronExpression = @"   0    5    *    SEP,JUL,OCT/2,JAN-MAR     THU,FRI,MON#1,TUE#2    ";



	NSTimeInterval userWakeupTimeOffset	= 0;
	APCScheduleExpression* schedule	= [[APCScheduleExpression alloc] initWithExpression: cronExpression
																			   timeZero: userWakeupTimeOffset];
 
	NSDate *start = [NSDate todayAtMidnight];
//	NSDate *start = [[NSDate tomorrowAtMidnight] dateByAddingDays: 2];
//	NSDate *end   = [NSDate tomorrowAtMidnight];
	NSDate *end   = [[NSDate tomorrowAtMidnight] dateByAddingDays: 3];
//	NSDate *end   = [[NSDate tomorrowAtMidnight] dateByAddingDays: 14];
//	NSDate *end   = [[NSDate tomorrowAtMidnight] dateByAddingDays: 32];
//	NSDate *end   = [[NSDate tomorrowAtMidnight] dateByAddingDays: 60];

	NSEnumerator* enumerator = [schedule enumeratorBeginningAtTime: start
													  endingAtTime: end];

	NSDateFormatter *formatter = self.dateFormatterInGregorianPacificTime;
//	NSDateFormatter *formatter = self.dateFormatterInGregorianUTC;			// please leave this here.


	NSLog (@"------------------------ look here -------------------------");
	NSLog (@"           the expression :  %@", cronExpression);
	NSLog (@"               start date :  %@", [formatter stringFromDate: start]);
	NSLog (@" ");

	NSDate *date = nil;
	while ((date = enumerator.nextObject) != nil)
	{
		NSLog (@"LOOK HERE ENUMERATOR DATE :  %@", [formatter stringFromDate:date]);
	}

	NSLog (@" ");
	NSLog (@"                 end date :  %@", [formatter stringFromDate: end]);
	NSLog (@"---------------------- ok, we're done ----------------------");
}

- (void) testAllRealisticTestsTogether
{
	/*
	 All of these should work with every combination of start
	 and end dates, below.
	 */
	NSArray* expressionsToTest =
	@[
		@"0 5 * * *",											// 5am every day
		@"0 5 * * 1",											// 5am every Monday
		@"0 5 * * 1#1",											// 5am, only first Monday
		@"0 5 * * wed#3",										// 5am, only third Wednesday
		@"0 5 * * 1#2",											// 5am, only second Monday
		@"0 5,10,12,17,20 * * *",								// several every day
		@"0 5,10,12,17,20 * * 1",								// several only on Mondays
		@"0 0 5 * * * *",										// 7 fields:  5am every day
		@"0 0 5 * * 1 *",										// 7 fields:  5am every Monday
		@"0 0 6 ? 1/1 THU#1 *",									// from Sage
		@"0 0 6 ? * FRI *",										// from Sage
		@"0 5 * DEC,NOV,JUL THU,FRI,MON#1,TUE#2",				// Replacing strings with numbers
		@"   0  5  *  DEC,NOV,JUL   THU,FRI,MON#1,TUE#2   ",	// replacing lots of whitespace
		@"  0	\n 5  *   * \r  *		  ",					// 5am every day, with spaces, tabs, hidden tabs, and newlines
		@"0 5 * SEP,JUL,OCT/2,JAN-MAR THU,FRI,MON#1,TUE#2",
		@"0 5 * SEP,JUL,OCT/2,jAn-MAr THU,FRI,MON#1,TUE#2",
//		@"0 5 * SEP,JUL,OCT/2,jAn-MAr THU,duuuude,MON#1,TUE#2",
		@"   0    5    *    SEP,JUL,OCT/2,JAN-MAR     THU,FRI,MON#1,TUE#2    ",
		];

	NSArray* startDates = @[
							[NSDate todayAtMidnight],
							[[NSDate tomorrowAtMidnight] dateByAddingDays: 2],
							[[NSDate todayAtMidnight] dateByAddingDays: -7],
							];

	NSArray *endDates = @[
						  [[NSDate tomorrowAtMidnight] dateByAddingDays: 3],
						  [[NSDate tomorrowAtMidnight] dateByAddingDays: 14],
						  [[NSDate tomorrowAtMidnight] dateByAddingDays: 32],
						  [[NSDate tomorrowAtMidnight] dateByAddingDays: 60],
						  ];

	NSDateFormatter *formatter = self.dateFormatterInGregorianPacificTime;
	//	NSDateFormatter *formatter = self.dateFormatterInGregorianUTC;			// please leave this here.

	NSDate *thisDate = nil;
	NSTimeInterval userWakeupTimeOffset	= 0;

	for (NSDate* startDate in startDates)
	{
		NSLog (@"++++++++++++++++++++ change start date +++++++++++++++++++++");

		for (NSDate* endDate in endDates)
		{
			NSLog (@"===================== change end date ======================");

			for (NSString* cronExpression in expressionsToTest)
			{
				NSLog (@"------------------ change cron expression ------------------");
				NSLog (@"           the expression :  [%@]", cronExpression);
				NSLog (@"               start date :  %@", [formatter stringFromDate: startDate]);
				NSLog (@" ");

				APCScheduleExpression* schedule	= [[APCScheduleExpression alloc] initWithExpression: cronExpression
																						   timeZero: userWakeupTimeOffset];

				NSEnumerator* enumerator = [schedule enumeratorBeginningAtTime: startDate
																  endingAtTime: endDate];

				while ((thisDate = enumerator.nextObject) != nil)
				{
					NSLog (@"LOOK HERE ENUMERATOR DATE :  %@", [formatter stringFromDate:thisDate]);
				}

				NSLog (@" ");
				NSLog (@"                 end date :  %@", [formatter stringFromDate: endDate]);
				NSLog (@"---------------------- ok, we're done ----------------------");
			}

			NSLog (@"================== end of that end date ====================");
			NSLog (@" ");
		}

		NSLog (@"+++++++++++++++++ end of that start date +++++++++++++++++++");
		NSLog (@" ");
	}
}

- (void) test_originalTestWorkingOnDeveloperMachine
{
	NSString* cronExpression = @"0 5 * * 1";	//5am every Monday
	//    NSString* cronExpression = @"0 5 * * *";	//5am every day
	//    NSString* cronExpression = @"0 5,10,12,17,20 * * *";	//several every day
	//    NSString* cronExpression = @"0 0 6 ? 1/1 THU#1 *"
	//    NSString* cronExpression = @"0 0 6 ? * FRI *"

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
		NSLog (@"LOOK HERE ENUMERATOR DATE     : %@", [dateFormatterInGregorianPacificTime stringFromDate:date]);
	}
}

@end









