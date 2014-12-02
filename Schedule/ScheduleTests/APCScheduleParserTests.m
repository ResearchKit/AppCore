//
//  APCScheduleParserTests.m
//  Schedule
//
//  Created by Edward Cessna on 10/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APCScheduleParser.h"

@interface APCScheduleParserTests : XCTestCase

@end

@implementation APCScheduleParserTests

- (void)testNumberParsing
{
    NSString*           cronExpression = @"10";
    APCScheduleParser*  parser         = [[APCScheduleParser alloc] initWithExpression:cronExpression];
    
    APCListSelector*  listSelector = [parser listProductionForType:kMinutes];
    
    XCTAssertTrue(parser.isValidParse);
    XCTAssertNotNil(listSelector);
    XCTAssertEqual(listSelector.subSelectors.count, 1);
    
    APCPointSelector*   pointSelector = listSelector.subSelectors[0];
    
    XCTAssertEqualObjects(pointSelector.begin, @10);
    XCTAssertNil(pointSelector.end);
    XCTAssertNil(pointSelector.step);
}

- (void)testWildcardParsing
{
    NSString*           cronExpression = @"*";
    APCScheduleParser*  parser         = [[APCScheduleParser alloc] initWithExpression:cronExpression];
    
    APCListSelector* listSelector = [parser listProductionForType:kMinutes];
    
    XCTAssertTrue(parser.isValidParse);
    XCTAssertNotNil(listSelector);
    XCTAssertEqual(listSelector.subSelectors.count, 1);
    
    APCPointSelector*   pointSelector = listSelector.subSelectors[0];
    
    XCTAssertEqualObjects(pointSelector.begin, @0);
    XCTAssertEqualObjects(pointSelector.end, @59);
    XCTAssertEqualObjects(pointSelector.step, @1);
}

- (void)testRangeParsing
{
    NSString*           cronExpression = @"25-50";
    APCScheduleParser*  parser         = [[APCScheduleParser alloc] initWithExpression:cronExpression];
    
    APCListSelector* listSelector = [parser listProductionForType:kMinutes];
    
    XCTAssertTrue(parser.isValidParse);
    XCTAssertNotNil(listSelector);
    XCTAssertEqual(listSelector.subSelectors.count, 1);
    
    APCPointSelector*   pointSelector = listSelector.subSelectors[0];
    
    XCTAssertEqualObjects(pointSelector.begin, @25);
    XCTAssertEqualObjects(pointSelector.end, @50);
    XCTAssertEqualObjects(pointSelector.step, @1);
}

- (void)testListParsing
{
    NSString*           cronExpression = @"10,20,30";
    APCScheduleParser*  parser         = [[APCScheduleParser alloc] initWithExpression:cronExpression];
    
    APCListSelector* selector = [parser listProductionForType:kMinutes];
    
    XCTAssertTrue(parser.isValidParse);
    XCTAssertNotNil(selector);
    XCTAssertEqual(selector.subSelectors.count, 3);
    
    APCPointSelector*   pointSelector;
    
    pointSelector = selector.subSelectors[0];
    
    XCTAssertEqualObjects(pointSelector.begin, @10);
    XCTAssertNil(pointSelector.end);
    XCTAssertNil(pointSelector.step);
    
    pointSelector = selector.subSelectors[1];
    
    XCTAssertEqualObjects(pointSelector.begin, @20);
    XCTAssertNil(pointSelector.end);
    XCTAssertNil(pointSelector.step);
    
    pointSelector = selector.subSelectors[2];
    
    XCTAssertEqualObjects(pointSelector.begin, @30);
    XCTAssertNil(pointSelector.end);
    XCTAssertNil(pointSelector.step);
}

- (void)testNumberWithStepParsing
{
    NSString*           cronExpression = @"0/5";
    APCScheduleParser*  parser         = [[APCScheduleParser alloc] initWithExpression:cronExpression];
    
    APCListSelector* selector = [parser listProductionForType:kMinutes];
    
    XCTAssertTrue(parser.isValidParse);
    XCTAssertNotNil(selector);
    XCTAssertEqual(selector.subSelectors.count, 1);
    
    APCPointSelector*   pointSelector = selector.subSelectors[0];
    
    XCTAssertEqualObjects(pointSelector.begin, @0);
    XCTAssertEqualObjects(pointSelector.end,   @59);
    XCTAssertEqualObjects(pointSelector.step,  @5);
}

- (void)testWildcardWithStepParsing
{
    NSString*           cronExpression = @"*/5";
    APCScheduleParser*  parser         = [[APCScheduleParser alloc] initWithExpression:cronExpression];
    
    APCListSelector* selector = [parser listProductionForType:kMinutes];
    
    XCTAssertTrue(parser.isValidParse);
    XCTAssertNotNil(selector);
    XCTAssertEqual(selector.subSelectors.count, 1);
    
    APCPointSelector*   pointSelector = selector.subSelectors[0];
    
    XCTAssertEqualObjects(pointSelector.begin, @0);
    XCTAssertEqualObjects(pointSelector.end,   @59);
    XCTAssertEqualObjects(pointSelector.step,  @5);
}

- (void)testRangeWithStepParsing
{
    NSString*           cronExpression = @"25-50/5";
    APCScheduleParser*  parser         = [[APCScheduleParser alloc] initWithExpression:cronExpression];
    
    APCListSelector* selector = [parser listProductionForType:kMinutes];
    
    XCTAssertTrue(parser.isValidParse);
    XCTAssertNotNil(selector);
    XCTAssertEqual(selector.subSelectors.count, 1);
    
    APCPointSelector*   pointSelector = selector.subSelectors[0];
    
    XCTAssertEqualObjects(pointSelector.begin, @25);
    XCTAssertEqualObjects(pointSelector.end,   @50);
    XCTAssertEqualObjects(pointSelector.step,  @5);
}

- (void)testParsingExpressionWithWildcards
{
    NSString*           cronExpression = @"A * * * * *";
    APCScheduleParser*  parser         = [[APCScheduleParser alloc] initWithExpression:cronExpression];
    BOOL                validParse     = [parser parse];
    
    XCTAssertTrue(validParse);
    XCTAssertNotNil(parser.minuteSelector);
    XCTAssertNotNil(parser.hourSelector);
    XCTAssertNotNil(parser.dayOfMonthSelector);
    XCTAssertNotNil(parser.monthSelector);
}

- (void)testParsingExpressionWithNumbers
{
    NSString*           cronExpression = @"A 1 2 3 4 5";
    APCScheduleParser*  parser         = [[APCScheduleParser alloc] initWithExpression:cronExpression];
    BOOL                validParse     = [parser parse];
    
    XCTAssertTrue(validParse);
    XCTAssertNotNil(parser.minuteSelector);
    XCTAssertNotNil(parser.hourSelector);
    XCTAssertNotNil(parser.dayOfMonthSelector);
    XCTAssertNotNil(parser.monthSelector);
}

- (void)testParsingExpressionsWithSteps
{
    NSString*           cronExpression = @"A 1/5 2/5 3/5 4/5 5/5";
    APCScheduleParser*  parser         = [[APCScheduleParser alloc] initWithExpression:cronExpression];
    BOOL                validParse     = [parser parse];
    
    XCTAssertTrue(validParse);
    XCTAssertNotNil(parser.minuteSelector);
    XCTAssertNotNil(parser.hourSelector);
    XCTAssertNotNil(parser.dayOfMonthSelector);
    XCTAssertNotNil(parser.monthSelector);
}

- (void)testParsingExpressionsWithRangesAndSteps
{
    NSString*           cronExpression = @"A 1-10/5 2-20/5 3-31/2 4-12/2 2-6/2";
    APCScheduleParser*  parser         = [[APCScheduleParser alloc] initWithExpression:cronExpression];
    BOOL                validParse     = [parser parse];
    
    XCTAssertTrue(validParse);
    XCTAssertNotNil(parser.minuteSelector);
    XCTAssertNotNil(parser.hourSelector);
    XCTAssertNotNil(parser.dayOfMonthSelector);
    XCTAssertNotNil(parser.monthSelector);
}

- (void)testParsingLongFieldSeparator
{
    NSString*           cronExpression = @"A 1  2   3    4     5";
    APCScheduleParser*  parser         = [[APCScheduleParser alloc] initWithExpression:cronExpression];
    BOOL                validParse     = [parser parse];
    
    XCTAssertTrue(validParse);
    XCTAssertNotNil(parser.minuteSelector);
    XCTAssertNotNil(parser.hourSelector);
    XCTAssertNotNil(parser.dayOfMonthSelector);
    XCTAssertNotNil(parser.monthSelector);
}

@end
