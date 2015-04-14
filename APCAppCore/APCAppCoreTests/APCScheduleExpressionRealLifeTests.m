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
	NSArray* expressionsToTest =
	@[
		@"0 5 * * *",											// 5am every day
//		@"0 5 * * 1",											// 5am every Monday
        @"0 5 29 * *",											// 5am on the 29th of every month
        @"0 5 31 * *",											// 5am on the 31st of every month
//		@"0 5 * * 1#1",											// 5am, only first Monday
//		@"0 5 * * wed#3",										// 5am, only third Wednesday
//		@"0 5 * * 1#2",											// 5am, only second Monday
//		@"0 5,10,12,17,20 * * *",								// several every day
//		@"0 5,10,12,17,20 * * 1",								// several only on Mondays
//		@"0 0 5 * * * *",										// 7 fields:  5am every day
//		@"0 0 5 * * 1 *",										// 7 fields:  5am every Monday
//		@"0 0 6 ? 1/1 THU#1 *",									// from Sage
//		@"0 0 6 ? * FRI *",										// from Sage
//		@"0 5 * DEC,NOV,JUL THU,FRI,MON#1,TUE#2",				// Replacing strings with numbers
//		@"   0  5  *  DEC,NOV,JUL   THU,FRI,MON#1,TUE#2   ",	// replacing lots of whitespace
//		@"  0	\n 5  *   * \r  *		  ",					// 5am every day, with spaces, tabs, hidden tabs, and newlines
//		@"0 5 * SEP,JUL,OCT/2,JAN-MAR THU,FRI,MON#1,TUE#2",
//		@"0 5 * SEP,JUL,OCT/2,jAn-MAr THU,FRI,MON#1,TUE#2",
//		@"   0    5    *    SEP,JUL,OCT/2,JAN-MAR     THU,FRI,MON#1,TUE#2    ",
//
//		/* Things that break: */
//		@"0 5 * whatever dude",										// 5 fields, 2 with garbage
//		@"0 5 * SEP,JUL,OCT/2,jAn-MAr THU,duuuude,MON#1,TUE#2",		// 5 fields, 1 with garbage
//		@"0 0 * *",					// 4 fields, not 5 or 7
//		@"whatever",				// 1 field (with garbage in it)
//		@"0 5, 6, 7 * * *",			// spaces after commas
//		@"0 6, 12, 18, * * *",		// spaces after commas, generating illegal month number
//		@"0 5 - 7 * * *",			// spaces around hyphen
		];

	NSArray* startDates = @[
//                           [NSDate todayAtMidnight],
//							[[NSDate tomorrowAtMidnight] dateByAddingDays: 2],
//							[[NSDate todayAtMidnight]    dateByAddingDays: -7],
                            [[NSDate todayAtMidnight]    dateByAddingDays: -60],
//                          [[NSDate todayAtMidnight]    dateByAddingDays: -120],   // currently fails: the year always starts on "current year"
							];

	NSArray *endDates = @[
//						   [NSDate tomorrowAtMidnight],
//						  [[NSDate tomorrowAtMidnight] dateByAddingDays: 3],
//						  [[NSDate tomorrowAtMidnight] dateByAddingDays: 14],
//						  [[NSDate tomorrowAtMidnight] dateByAddingDays: 32],
						  [[NSDate tomorrowAtMidnight] dateByAddingDays: 60],
						  ];

	NSDateFormatter *formatter = self.dateFormatterInGregorianPacificTime;
//	NSDateFormatter *formatter = self.dateFormatterInGregorianUTC;			// please leave this here, to remind us of this implementation decision.

	NSDate *thisDate = nil;
	NSTimeInterval userWakeupTimeOffset	= 0;

	for (NSDate* startDate in startDates)
	{
		NSLog (@" ");
		NSLog (@"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		NSLog (@"++++++++++++++++++++ change start date +++++++++++++++++++++");
		NSLog (@"               start date :  %@", [formatter stringFromDate: startDate]);
		NSLog (@"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

		for (NSDate* endDate in endDates)
		{
			NSLog (@" ");
			NSLog (@"============================================================");
			NSLog (@"===================== change end date ======================");
			NSLog (@"                 end date :  %@", [formatter stringFromDate: endDate]);
			NSLog (@"============================================================");

			for (NSString* cronExpression in expressionsToTest)
			{
				NSLog (@" ");
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
		}

		NSLog (@"+++++++++++++++++ end of that start date +++++++++++++++++++");
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









