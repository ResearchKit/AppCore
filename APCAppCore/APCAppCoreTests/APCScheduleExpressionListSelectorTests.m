//
//  APCScheduleExpressionListSelectorTests.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APCListSelector.h"
#import "APCPointSelector.h"

@interface APCScheduleExpressionListSelectorTests : XCTestCase

@end

@implementation APCScheduleExpressionListSelectorTests

- (void)testListSelectorCreation
{
	APCListSelector*    selector = [[APCListSelector alloc] initWithSubSelectors:@[]];

	XCTAssertNotNil(selector.subSelectors);
	XCTAssertEqual(selector.subSelectors.count, 0);
}

- (void)testListSelectorWithOneSubSelector
{
	APCPointSelector*   pointSelector = [[APCPointSelector alloc] initWithRangeStart: nil rangeEnd: nil step: nil];
	pointSelector.unitType = kMinutes;

	APCListSelector*    listSelector  = [[APCListSelector alloc] initWithSubSelectors:@[ pointSelector ]];
	
	XCTAssertEqual(listSelector.subSelectors.count, 1);
	XCTAssertTrue([listSelector matches:@5]);
}

- (void)testListSelectorWithTwoSubSelectors
{
	APCPointSelector*   pointSelector1 = [[APCPointSelector alloc] initWithRangeStart: @5 rangeEnd: nil step: nil];
	APCPointSelector*	pointSelector2 = [[APCPointSelector alloc] initWithRangeStart: @10 rangeEnd: nil step: nil];
	pointSelector1.unitType = kMinutes;
	pointSelector2.unitType = kMinutes;

	APCListSelector*    listSelector   = [[APCListSelector alloc] initWithSubSelectors:@[ pointSelector1, pointSelector2 ]];
		
	XCTAssertEqual(listSelector.subSelectors.count, 2);
	XCTAssertTrue([listSelector matches:@5]);
	XCTAssertTrue([listSelector matches:@10]);
	XCTAssertFalse([listSelector matches:@0]);
}

- (void)testPointAfter
{
	APCPointSelector*   pointSelector1 = [[APCPointSelector alloc] initWithRangeStart: @5 rangeEnd: nil step: nil];
	APCPointSelector*	pointSelector2 = [[APCPointSelector alloc] initWithRangeStart: @10 rangeEnd: nil step: nil];
	pointSelector1.unitType = kMinutes;
	pointSelector2.unitType = kMinutes;

	APCListSelector*    listSelector   = [[APCListSelector alloc] initWithSubSelectors:@[ pointSelector1, pointSelector2 ]];
	
	XCTAssertEqualObjects([listSelector nextMomentAfter:@0], @5);
	XCTAssertEqualObjects([listSelector nextMomentAfter:@5], @10);
	XCTAssertNil([listSelector nextMomentAfter:@10]);
}

- (void)testPointAfterRange
{
	APCPointSelector*   pointSelector1 = [[APCPointSelector alloc] initWithRangeStart: @5 rangeEnd: @10 step: nil];
	APCPointSelector*	pointSelector2 = [[APCPointSelector alloc] initWithRangeStart: @20 rangeEnd: @30 step: nil];
	pointSelector1.unitType = kMinutes;
	pointSelector2.unitType = kMinutes;

	APCListSelector*    listSelector   = [[APCListSelector alloc] initWithSubSelectors:@[ pointSelector1, pointSelector2 ]];
	
	XCTAssertEqualObjects([listSelector nextMomentAfter:@0], @5);
	XCTAssertEqualObjects([listSelector nextMomentAfter:@5], @6);
	XCTAssertEqualObjects([listSelector nextMomentAfter:@9], @10);
	
	XCTAssertEqualObjects([listSelector nextMomentAfter:@10], @20);
	XCTAssertEqualObjects([listSelector nextMomentAfter:@20], @21);
	XCTAssertEqualObjects([listSelector nextMomentAfter:@29], @30);

	XCTAssertNil([listSelector nextMomentAfter:@30]);
}

- (void)testPointAfterRangeWithStep
{
	APCPointSelector*   pointSelector1 = [[APCPointSelector alloc] initWithRangeStart: @5 rangeEnd: @15 step: @5];
	APCPointSelector*	pointSelector2 = [[APCPointSelector alloc] initWithRangeStart: @20 rangeEnd: @50 step: @10];
	pointSelector1.unitType = kMinutes;
	pointSelector2.unitType = kMinutes;

	APCListSelector*    listSelector   = [[APCListSelector alloc] initWithSubSelectors:@[ pointSelector1, pointSelector2 ]];

	XCTAssertEqualObjects([listSelector nextMomentAfter:@0], @5);
	XCTAssertEqualObjects([listSelector nextMomentAfter:@5], @10);
	XCTAssertEqualObjects([listSelector nextMomentAfter:@6], @10);
	XCTAssertEqualObjects([listSelector nextMomentAfter:@10], @15);

	XCTAssertEqualObjects([listSelector nextMomentAfter:@15], @20);
	XCTAssertEqualObjects([listSelector nextMomentAfter:@20], @30);
	XCTAssertEqualObjects([listSelector nextMomentAfter:@21], @30);
	XCTAssertEqualObjects([listSelector nextMomentAfter:@30], @40);
	XCTAssertEqualObjects([listSelector nextMomentAfter:@31], @40);
	XCTAssertEqualObjects([listSelector nextMomentAfter:@40], @50);
	
	XCTAssertNil([listSelector nextMomentAfter:@50]);
}

@end
