//
//  APCEPointSelectorTests.m
//  Schedule
//
//  Created by Edward Cessna on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APCPointSelector.h"


@interface APCPointSelectorTests : XCTestCase

@end

@implementation APCPointSelectorTests

- (void)testMinuteSelectorCreation
{
    NSNumber*           expectedBegin = @0;
    NSNumber*           expectedEnd   = @59;
    APCPointSelector*   selector      = [[APCPointSelector alloc] initWithUnit:kMinutes
                                                                    beginRange:expectedBegin
                                                                      endRange:expectedEnd
                                                                          step:nil];
    
    XCTAssertEqual(selector.defaultBeginPeriod, expectedBegin);
    XCTAssertEqual(selector.defaultEndPeriod, expectedEnd);
    XCTAssertEqual(selector.begin, expectedBegin);
    XCTAssertEqual(selector.end, expectedEnd);
}

- (void)testHourSelectorCreation
{
    NSNumber*           expectedBegin = @0;
    NSNumber*           expectedEnd   = @23;
    APCPointSelector*   selector      = [[APCPointSelector alloc] initWithUnit:kHours
                                                                    beginRange:expectedBegin
                                                                      endRange:expectedEnd
                                                                          step:nil];
    
    XCTAssertEqual(selector.defaultBeginPeriod, expectedBegin);
    XCTAssertEqual(selector.defaultEndPeriod, expectedEnd);
    XCTAssertEqual(selector.begin, expectedBegin);
    XCTAssertEqual(selector.end, expectedEnd);
}

- (void)testDayOfMonthSelectorCreation
{
    NSNumber*           expectedBegin = @1;
    NSNumber*           expectedEnd   = @31;
    APCPointSelector*   selector      = [[APCPointSelector alloc] initWithUnit:kDayOfMonth
                                                                    beginRange:expectedBegin
                                                                      endRange:expectedEnd
                                                                          step:nil];
    
    XCTAssertEqual(selector.defaultBeginPeriod, expectedBegin);
    XCTAssertEqual(selector.defaultEndPeriod, expectedEnd);
    XCTAssertEqual(selector.begin, expectedBegin);
    XCTAssertEqual(selector.end, expectedEnd);
}

- (void)testMonthSelectorCreation
{
    NSNumber*           expectedBegin = @1;
    NSNumber*           expectedEnd   = @12;
    APCPointSelector*   selector      = [[APCPointSelector alloc] initWithUnit:kMonth
                                                                    beginRange:expectedBegin
                                                                      endRange:expectedEnd
                                                                          step:nil];
    
    XCTAssertEqual(selector.defaultBeginPeriod, expectedBegin);
    XCTAssertEqual(selector.defaultEndPeriod, expectedEnd);
    XCTAssertEqual(selector.begin, expectedBegin);
    XCTAssertEqual(selector.end, expectedEnd);
}

- (void)testDayOfWeekSelectorCreation
{
    NSNumber*           expectedBegin = @0;
    NSNumber*           expectedEnd   = @6;
    APCPointSelector*   selector      = [[APCPointSelector alloc] initWithUnit:kDayOfWeek
                                                                    beginRange:expectedBegin
                                                                      endRange:expectedEnd
                                                                          step:nil];
    
    XCTAssertEqual(selector.defaultBeginPeriod, expectedBegin);
    XCTAssertEqual(selector.defaultEndPeriod, expectedEnd);
    XCTAssertEqual(selector.begin, expectedBegin);
    XCTAssertEqual(selector.end, expectedEnd);
}


- (void)testPointSelector
{
    APCPointSelector*  selector = [[APCPointSelector alloc] initWithUnit:kMinutes
                                                              beginRange:@0
                                                                endRange:nil
                                                                    step:nil];
    
    XCTAssertTrue([selector matches:@0]);
    XCTAssertFalse([selector matches:@1]);
}

- (void)testRangeSelector
{
    NSNumber*           testBegin = @5;
    NSNumber*           testEnd   = @10;
    APCPointSelector*   selector  = [[APCPointSelector alloc] initWithUnit:kMinutes
                                                                beginRange:testBegin
                                                                  endRange:testEnd
                                                                      step:nil];
    
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
    APCPointSelector*   selector  = [[APCPointSelector alloc] initWithUnit:kMinutes
                                                                beginRange:testBegin
                                                                  endRange:testEnd
                                                                      step:testStep];
    
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
    APCPointSelector*   selector  = [[APCPointSelector alloc] initWithUnit:kMinutes
                                                                beginRange:testBegin
                                                                  endRange:testEnd
                                                                      step:testStep];
    
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
    APCPointSelector*   selector = [[APCPointSelector alloc] initWithUnit:kMinutes beginRange:point endRange:nil step:nil];
    
    XCTAssertEqualObjects([selector nextMomentAfter:@0],  point);
    XCTAssertEqualObjects([selector nextMomentAfter:@9],  point);
    XCTAssertNil([selector nextMomentAfter:@11]);
}

- (void)testPointAfterPointWithStep
{
    NSNumber*           point    = @10;
    NSNumber*           step     = @5;
    APCPointSelector*   selector = [[APCPointSelector alloc] initWithUnit:kMinutes beginRange:point endRange:nil step:step];
    NSNumber*           end      = selector.end;
    
    XCTAssertEqualObjects([selector nextMomentAfter:@0],    point);
    
    for (NSInteger ndx = point.integerValue; ndx < end.integerValue; ndx += step.integerValue)
    {
        NSInteger   expected = ndx + step.integerValue;
        if (expected > end.integerValue)
            XCTAssertNil([selector nextMomentAfter:@(ndx)]);
        else
            XCTAssertEqualObjects([selector nextMomentAfter:@(ndx)], @(expected));
    }
    
    XCTAssertNil([selector nextMomentAfter:end]);
}

- (void)testPointAfterRange
{
    NSNumber*           begin    = @10;
    NSNumber*           end      = @50;
    APCPointSelector*   selector = [[APCPointSelector alloc] initWithUnit:kMinutes beginRange:begin endRange:end step:nil];
    
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
    APCPointSelector*   selector = [[APCPointSelector alloc] initWithUnit:kMinutes beginRange:begin endRange:end step:step];
    
    XCTAssertEqualObjects([selector nextMomentAfter:@0], begin);
    
    for (NSInteger ndx = begin.integerValue; ndx < end.integerValue; ndx += step.integerValue)
    {
        XCTAssertEqualObjects([selector nextMomentAfter:@(ndx)], @(ndx + step.integerValue));
    }
    
    XCTAssertNil([selector nextMomentAfter:end]);
}

@end
