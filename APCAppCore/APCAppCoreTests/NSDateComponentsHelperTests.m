//
//  NSDateComponentsHelperTests.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSDateComponents+Helper.h"


@interface NSDateComponentsHelperTests : XCTestCase
@property (nonatomic, strong) NSCalendar *calendar;
@end


@implementation NSDateComponentsHelperTests

/** Put setup code here. This method is called before the invocation of each test method in the class. */
- (void) setUp
{
	[super setUp];

	self.calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
}

/** Put teardown code here. This method is called after the invocation of each test method in the class. */
- (void) tearDown
{
    [super tearDown];
}

- (void) testLengthOfMonth
{
	// Using February in a non-leap year.
//	NSDateComponents *components = [NSDateComponents componentsInGregorianUTCWithMonth: @(2) year: @(2015)];
	NSDateComponents *components = [NSDateComponents componentsInGregorianLocalWithMonth: @(2) year: @(2015)];

	XCTAssertEqual(28, components.lastDayOfMonth);
}

- (void) testArrayOfDaysInMonth
{
	// Using February in a non-leap year.
//	NSDateComponents *components = [NSDateComponents componentsInGregorianUTCWithMonth: @(2) year: @(2015)];
	NSDateComponents *components = [NSDateComponents componentsInGregorianLocalWithMonth: @(2) year: @(2015)];

	XCTAssertEqual(28, components.allDaysInMonth.count);
}

@end












