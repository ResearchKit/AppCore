//
//  APCScheduleExpressionParserTests.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APCScheduleExpressionParser.h"

@interface APCScheduleExpressionParserTests : XCTestCase

@end

@implementation APCScheduleExpressionParserTests

- (void)testNumberParsing
{
	NSString*           cronExpression = @"10";
	APCScheduleExpressionParser*  parser         = [[APCScheduleExpressionParser alloc] initWithExpression:cronExpression];
	
	APCListSelector*  listSelector = [parser listProduction];
	[parser coerceSelector: listSelector intoType: kMinutes];
	
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
	APCScheduleExpressionParser*  parser         = [[APCScheduleExpressionParser alloc] initWithExpression:cronExpression];
	
	APCListSelector* listSelector = [parser listProduction];
	[parser coerceSelector: listSelector intoType: kMinutes];
	
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
	APCScheduleExpressionParser*  parser         = [[APCScheduleExpressionParser alloc] initWithExpression:cronExpression];
	
	APCListSelector* listSelector = [parser listProduction];
	[parser coerceSelector: listSelector intoType: kMinutes];
	
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
	APCScheduleExpressionParser*  parser         = [[APCScheduleExpressionParser alloc] initWithExpression:cronExpression];
	
	APCListSelector* selector = [parser listProduction];
	[parser coerceSelector: selector intoType: kMinutes];
	
	XCTAssertTrue(parser.isValidParse);
	XCTAssertNotNil(selector);
	XCTAssertEqual(selector.subSelectors.count, 3);
	
	APCPointSelector*   pointSelector = nil;
	
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
	APCScheduleExpressionParser*  parser         = [[APCScheduleExpressionParser alloc] initWithExpression:cronExpression];
	
	APCListSelector* selector = [parser listProduction];
	[parser coerceSelector: selector intoType: kMinutes];
	
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
	APCScheduleExpressionParser*  parser         = [[APCScheduleExpressionParser alloc] initWithExpression:cronExpression];
	
	APCListSelector* selector = [parser listProduction];
	[parser coerceSelector: selector intoType: kMinutes];
	
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
	APCScheduleExpressionParser*  parser         = [[APCScheduleExpressionParser alloc] initWithExpression:cronExpression];
	
	APCListSelector* selector = [parser listProduction];
	[parser coerceSelector: selector intoType: kMinutes];
	
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
	NSString*           cronExpression = @"* * * * *";
	APCScheduleExpressionParser*  parser         = [[APCScheduleExpressionParser alloc] initWithExpression:cronExpression];
	BOOL                validParse     = [parser parse];
	
	XCTAssertTrue(validParse);
	XCTAssertNotNil(parser.minuteSelector);
	XCTAssertNotNil(parser.hourSelector);
	XCTAssertNotNil(parser.dayOfMonthSelector);
	XCTAssertNotNil(parser.monthSelector);
}

- (void)testParsingExpressionWithNumbers
{
	NSString*           cronExpression = @"1 2 3 4 5";
	APCScheduleExpressionParser*  parser         = [[APCScheduleExpressionParser alloc] initWithExpression:cronExpression];
	BOOL                validParse     = [parser parse];
	
	XCTAssertTrue(validParse);
	XCTAssertNotNil(parser.minuteSelector);
	XCTAssertNotNil(parser.hourSelector);
	XCTAssertNotNil(parser.dayOfMonthSelector);
	XCTAssertNotNil(parser.monthSelector);
}

- (void)testParsingExpressionsWithSteps
{
	NSString*           cronExpression = @"1/5 2/5 3/5 4/5 5/5";
	APCScheduleExpressionParser*  parser         = [[APCScheduleExpressionParser alloc] initWithExpression:cronExpression];
	BOOL                validParse     = [parser parse];
	
	XCTAssertTrue(validParse);
	XCTAssertNotNil(parser.minuteSelector);
	XCTAssertNotNil(parser.hourSelector);
	XCTAssertNotNil(parser.dayOfMonthSelector);
	XCTAssertNotNil(parser.monthSelector);
}

- (void)testParsingExpressionsWithRangesAndSteps
{
	NSString*           cronExpression = @"1-10/5 2-20/5 3-31/2 4-12/2 2-6/2";
	APCScheduleExpressionParser*  parser         = [[APCScheduleExpressionParser alloc] initWithExpression:cronExpression];
	BOOL                validParse     = [parser parse];
	
	XCTAssertTrue(validParse);
	XCTAssertNotNil(parser.minuteSelector);
	XCTAssertNotNil(parser.hourSelector);
	XCTAssertNotNil(parser.dayOfMonthSelector);
	XCTAssertNotNil(parser.monthSelector);
}

- (void)testParsingLongFieldSeparator
{
	NSString*           cronExpression = @"1  2   3    4     5";
	APCScheduleExpressionParser*  parser         = [[APCScheduleExpressionParser alloc] initWithExpression:cronExpression];
	BOOL                validParse     = [parser parse];
	
	XCTAssertTrue(validParse);
	XCTAssertNotNil(parser.minuteSelector);
	XCTAssertNotNil(parser.hourSelector);
	XCTAssertNotNil(parser.dayOfMonthSelector);
	XCTAssertNotNil(parser.monthSelector);
}

@end
