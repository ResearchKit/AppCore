//
//  APCScheduleExpressionRealLifeTests.m
//  APCAppCore
//
//  Created by Ron Conescu on 12/6/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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

//	- (void)testExample {
//		// This is an example of a functional test case.
//		XCTAssert(YES, @"Pass");
//	}
//
//	- (void)testPerformanceExample {
//		// This is an example of a performance test case.
//		[self measureBlock:^{
//			// Put the code you want to measure the time of here.
//		}];
//	}




- (void) testRealisticTests
{
	NSString* cronExpression = @"0 5 * * *";				// 5am every day
//	NSString* cronExpression = @"0 5 * * 1";				// 5am every Monday
//	NSString* cronExpression = @"0 5,10,12,17,20 * * *";	// several every day
//	NSString* cronExpression = @"0 0 6 ? 1/1 THU#1 *";		// from Sage
//	NSString* cronExpression = @"0 0 6 ? * FRI *";			// from Sage

	NSTimeInterval userWakeupTimeOffset	= 0;
	APCScheduleExpression* schedule	= [[APCScheduleExpression alloc] initWithExpression: cronExpression
																			   timeZero: userWakeupTimeOffset];

	NSDate *start = [NSDate todayAtMidnight];
	NSDate *end   = [NSDate tomorrowAtMidnight];
//	NSDate *end   = [[NSDate tomorrowAtMidnight] dateByAddingDays: 3];
//	NSDate *end   = [[NSDate tomorrowAtMidnight] dateByAddingDays: 14];

	NSEnumerator* enumerator = [schedule enumeratorBeginningAtTime: start
													  endingAtTime: end];

	NSDateFormatter *formatter = self.dateFormatterInGregorianPacificTime;
//	NSDateFormatter *formatter = self.dateFormatterInGregorianUTC;


	NSLog (@"------------------------ look here -------------------------");
	NSLog (@"               start date :  %@", [formatter stringFromDate: start]);
	NSLog (@"                 end date :  %@", [formatter stringFromDate: end]);
	NSLog (@" ");

	NSDate *date = nil;
	while ((date = enumerator.nextObject) != nil)
	{
		NSLog (@"LOOK HERE ENUMERATOR DATE :  %@", [formatter stringFromDate:date]);
	}

	NSLog (@"---------------------- ok, we're done ----------------------");
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









