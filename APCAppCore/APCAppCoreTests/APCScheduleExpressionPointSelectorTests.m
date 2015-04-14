//
//  APCScheduleExpressionPointSelectorTests.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APCPointSelector.h"


@interface APCScheduleExpressionPointSelectorTests : XCTestCase

@end

@implementation APCScheduleExpressionPointSelectorTests

- (void)testMinuteSelectorCreation
{
	NSNumber*           expectedBegin = @0;
	NSNumber*           expectedEnd   = @59;
	APCPointSelector*   selector      = [[APCPointSelector alloc] initWithRangeStart: expectedBegin
																			rangeEnd: expectedEnd
																				step: nil];

	selector.unitType = kMinutes;
	
	XCTAssertEqual(selector.defaultBeginPeriod, expectedBegin);
	XCTAssertEqual(selector.defaultEndPeriod, expectedEnd);
	XCTAssertEqual(selector.begin, expectedBegin);
	XCTAssertEqual(selector.end, expectedEnd);
}

- (void)testHourSelectorCreation
{
	NSNumber*           expectedBegin = @0;
	NSNumber*           expectedEnd   = @23;
	APCPointSelector*   selector      = [[APCPointSelector alloc] initWithRangeStart: expectedBegin
																			rangeEnd: expectedEnd
																				step: nil];
	selector.unitType = kHours;
	
	XCTAssertEqual(selector.defaultBeginPeriod, expectedBegin);
	XCTAssertEqual(selector.defaultEndPeriod, expectedEnd);
	XCTAssertEqual(selector.begin, expectedBegin);
	XCTAssertEqual(selector.end, expectedEnd);
}

- (void)testDayOfMonthSelectorCreation
{
	NSNumber*           expectedBegin = @1;
	NSNumber*           expectedEnd   = @31;
	APCPointSelector*   selector      = [[APCPointSelector alloc] initWithRangeStart: expectedBegin
																			rangeEnd: expectedEnd
																				step: nil];
	selector.unitType = kDayOfMonth;
	
	XCTAssertEqual(selector.defaultBeginPeriod, expectedBegin);
	XCTAssertEqual(selector.defaultEndPeriod, expectedEnd);
	XCTAssertEqual(selector.begin, expectedBegin);
	XCTAssertEqual(selector.end, expectedEnd);
}

- (void)testMonthSelectorCreation
{
	NSNumber*           expectedBegin = @1;
	NSNumber*           expectedEnd   = @12;
	APCPointSelector*   selector      = [[APCPointSelector alloc] initWithRangeStart: expectedBegin
																			rangeEnd: expectedEnd
																				step: nil];
	selector.unitType = kMonth;
	
	XCTAssertEqual(selector.defaultBeginPeriod, expectedBegin);
	XCTAssertEqual(selector.defaultEndPeriod, expectedEnd);
	XCTAssertEqual(selector.begin, expectedBegin);
	XCTAssertEqual(selector.end, expectedEnd);
}

- (void)testDayOfWeekSelectorCreation
{
	NSNumber*           expectedBegin = @0;
	NSNumber*           expectedEnd   = @6;
	APCPointSelector*   selector      = [[APCPointSelector alloc] initWithRangeStart: expectedBegin
																			rangeEnd: expectedEnd
																				step: nil];
	selector.unitType = kDayOfWeek;
	
	XCTAssertEqual(selector.defaultBeginPeriod, expectedBegin);
	XCTAssertEqual(selector.defaultEndPeriod, expectedEnd);
	XCTAssertEqual(selector.begin, expectedBegin);
	XCTAssertEqual(selector.end, expectedEnd);
}


- (void)testPointSelector
{
	APCPointSelector* selector = [[APCPointSelector alloc] initWithRangeStart: @0
																	 rangeEnd: nil
																		 step: nil];
	selector.unitType = kMinutes;
	
	XCTAssertTrue([selector matches:@0]);
	XCTAssertFalse([selector matches:@1]);
}

- (void)testRangeSelector
{
	NSNumber*           testBegin = @5;
	NSNumber*           testEnd   = @10;
	APCPointSelector*   selector  = [[APCPointSelector alloc] initWithRangeStart: testBegin
																		rangeEnd: testEnd
																			step: nil];
	selector.unitType = kMinutes;
	
	for (NSInteger ndx = testBegin.integerValue; ndx <= testEnd.integerValue; ++ndx)
	{
		XCTAssertTrue([selector matches:@(ndx)]);
	}
	XCTAssertFalse([selector matches:@0]);
	XCTAssertFalse([selector matches:@(testBegin.integerValue - 1)]);
	XCTAssertFalse([selector matches:@(testEnd.integerValue + 1)]);
}

- (void)testStepSelector
{
	NSNumber*           testBegin = @5;
	NSNumber*           testEnd   = @59;
	NSNumber*           testStep  = @5;
	APCPointSelector*   selector  = [[APCPointSelector alloc] initWithRangeStart: testBegin
																		rangeEnd: testEnd
																			step: testStep];
	selector.unitType = kMinutes;
	
	for (NSInteger ndx = testBegin.integerValue; ndx < testEnd.integerValue; ++ndx)
	{
		if (ndx % testStep.integerValue == 0)
		{
			XCTAssertTrue([selector matches:@(ndx)]);
		}
		else
		{
			XCTAssertFalse([selector matches:@(ndx)]);
		}
	}
	
	XCTAssertFalse([selector matches:@0]);
	XCTAssertFalse([selector matches:@(testBegin.integerValue - 1)]);
}

- (void)testRangeStepSelector
{
	NSNumber*           testBegin = @5;
	NSNumber*           testEnd   = @20;
	NSNumber*           testStep  = @5;
	APCPointSelector*   selector  = [[APCPointSelector alloc] initWithRangeStart: testBegin
																		rangeEnd: testEnd
																			step: testStep];
	selector.unitType = kMinutes;
	
	for (NSInteger ndx = testBegin.integerValue; ndx <= 20; ++ndx)
	{
		if (ndx % testStep.integerValue == 0)
		{
			XCTAssertTrue([selector matches:@(ndx)]);
		}
		else
		{
			XCTAssertFalse([selector matches:@(ndx)]);
		}
	}
	
	XCTAssertFalse([selector matches:@0]);
	XCTAssertFalse([selector matches:@(testBegin.integerValue - 1)]);
}

- (void)testPointAfterPoint
{
	NSNumber*           point    = @10;
	APCPointSelector*   selector = [[APCPointSelector alloc] initWithRangeStart: point
																		rangeEnd: nil
																			step: nil];
	selector.unitType = kMinutes;
	
	XCTAssertEqualObjects([selector nextMomentAfter:@0],  point);
	XCTAssertEqualObjects([selector nextMomentAfter:@9],  point);
	XCTAssertNil([selector nextMomentAfter:@11]);
}

- (void)testPointAfterPointWithStep
{
	NSNumber*           point    = @10;
	NSNumber*           step     = @5;
	APCPointSelector*   selector = [[APCPointSelector alloc] initWithRangeStart: point
																	   rangeEnd: nil
																		   step: step];
	selector.unitType = kMinutes;
	NSNumber*           end      = selector.end;
	
	XCTAssertEqualObjects([selector nextMomentAfter:@0], point);
	
	for (NSInteger movingPoint = point.integerValue; movingPoint < end.integerValue; movingPoint += step.integerValue)
	{
		NSInteger expected = movingPoint + step.integerValue;
		NSNumber *nextPoint = [selector nextMomentAfter: @(movingPoint)];

		if (expected > end.integerValue)
		{
			XCTAssertNil (nextPoint);
		}
		else
		{
			XCTAssertEqualObjects (nextPoint, @(expected));
		}
	}
	
	XCTAssertNil([selector nextMomentAfter:end]);
}

- (void)testPointAfterRange
{
	NSNumber*           begin    = @10;
	NSNumber*           end      = @50;
	APCPointSelector*   selector = [[APCPointSelector alloc] initWithRangeStart: begin
																	   rangeEnd: end
																		   step: nil];
	selector.unitType = kMinutes;
	
	XCTAssertEqualObjects([selector nextMomentAfter:@0], begin);
	
	for (NSInteger ndx = begin.integerValue; ndx < end.integerValue; ++ndx)
	{
		XCTAssertEqualObjects([selector nextMomentAfter:@(ndx)], @(ndx + 1));
	}
	
	XCTAssertNil([selector nextMomentAfter:end]);
}

- (void)testPointAfterRangeWithStep
{
	NSNumber*           begin    = @10;
	NSNumber*           end      = @50;
	NSNumber*           step     = @5;
	APCPointSelector*   selector = [[APCPointSelector alloc] initWithRangeStart: begin
																	   rangeEnd: end
																		   step: step];
	selector.unitType = kMinutes;
	
	XCTAssertEqualObjects([selector nextMomentAfter:@0], begin);
	
	for (NSInteger ndx = begin.integerValue; ndx < end.integerValue; ndx += step.integerValue)
	{
		XCTAssertEqualObjects([selector nextMomentAfter:@(ndx)], @(ndx + step.integerValue));
	}
	
	XCTAssertNil([selector nextMomentAfter:end]);
}

@end
