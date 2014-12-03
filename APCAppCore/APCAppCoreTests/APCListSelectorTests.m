//
//  APCListSelectorTests.m
//  Schedule
//
//  Created by Edward Cessna on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APCListSelector.h"
#import "APCPointSelector.h"

@interface APCListSelectorTests : XCTestCase

@end

@implementation APCListSelectorTests

- (void)testListSelectorCreation
{
    APCListSelector*    selector = [[APCListSelector alloc] initWithSubSelectors:@[]];

    XCTAssertNotNil(selector.subSelectors);
    XCTAssertEqual(selector.subSelectors.count, 0);
}

- (void)testListSelectorWithOneSubSelector
{
    APCPointSelector*   pointSelector = [[APCPointSelector alloc] initWithUnit:kMinutes beginRange:nil endRange:nil step:nil];
    APCListSelector*    listSelector  = [[APCListSelector alloc] initWithSubSelectors:@[ pointSelector ]];
    
    XCTAssertEqual(listSelector.subSelectors.count, 1);
    XCTAssertTrue([listSelector matches:@5]);
}

- (void)testListSelectorWithTwoSubSelectors
{
    APCPointSelector*   pointSelector1 = [[APCPointSelector alloc] initWithUnit:kMinutes beginRange:@5 endRange:nil step:nil];
    APCPointSelector*   pointSelector2 = [[APCPointSelector alloc] initWithUnit:kMinutes beginRange:@10 endRange:nil step:nil];
    APCListSelector*    listSelector   = [[APCListSelector alloc] initWithSubSelectors:@[ pointSelector1, pointSelector2 ]];
        
    XCTAssertEqual(listSelector.subSelectors.count, 2);
    XCTAssertTrue([listSelector matches:@5]);
    XCTAssertTrue([listSelector matches:@10]);
    XCTAssertFalse([listSelector matches:@0]);
}

- (void)testPointAfter
{
    APCPointSelector*   pointSelector1 = [[APCPointSelector alloc] initWithUnit:kMinutes beginRange:@5 endRange:nil step:nil];
    APCPointSelector*   pointSelector2 = [[APCPointSelector alloc] initWithUnit:kMinutes beginRange:@10 endRange:nil step:nil];
    APCListSelector*    listSelector   = [[APCListSelector alloc] initWithSubSelectors:@[ pointSelector1, pointSelector2 ]];
    
    XCTAssertEqualObjects([listSelector nextMomentAfter:@0], @5);
    XCTAssertEqualObjects([listSelector nextMomentAfter:@5], @10);
    XCTAssertNil([listSelector nextMomentAfter:@10]);
}

- (void)testPointAfterRange
{
    APCPointSelector*   pointSelector1 = [[APCPointSelector alloc] initWithUnit:kMinutes beginRange:@5 endRange:@10 step:nil];
    APCPointSelector*   pointSelector2 = [[APCPointSelector alloc] initWithUnit:kMinutes beginRange:@20 endRange:@30 step:nil];
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
    APCPointSelector*   pointSelector1 = [[APCPointSelector alloc] initWithUnit:kMinutes beginRange:@5 endRange:@15 step:@5];
    APCPointSelector*   pointSelector2 = [[APCPointSelector alloc] initWithUnit:kMinutes beginRange:@20 endRange:@50 step:@10];
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
