//
//  APCLogTests2.m
//  APCAppCore
//
//  Created by Ron Conescu on 12/7/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <APCAppCore/APCLog.h>

@interface APCLogTests : XCTestCase

@end

@implementation APCLogTests

- (void)setUp {
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

- (void) testBasicLog
{
	[APCLog log: @"Hello, Apple!"];

	[APCLog log: @"Hello, Apple!  My name is: %@.  My age is: %d years.", @"Fred", 47];
}

- (void) testFunctionCallStackExceptionTrace
{
	@try
	{
		[self functionStackItem2];
	}

	@catch (NSException *exception)
	{
		[APCLog log:
		 @"\n\n"
		 "-------------------------------------------------------------------------\n"
		 "------------- THIS EXCEPTION PRINTOUT IS PART OF THE TEST. --------------\n"
		 "-------------------------------------------------------------------------"];

		[APCLog logException: exception];

		[APCLog logException: exception format: @"Additional message with the exception. Age = %d.", 47];

		[APCLog log:
		 @"\n"
		 "-------------------------------------------------------------------------\n"
		 "----------------- done with the purposeful exceptions. ------------------\n"
		 "-------------------------------------------------------------------------\n\n"];
	}
	@finally
	{
	}
}

- (void) functionStackItem2
{
	[self functionStackItem3];
}

- (void) functionStackItem3
{
	NSException *testException = [NSException exceptionWithName: @"Test Exception" reason: @"Just seeing if I can log exceptions correctly" userInfo: nil];

	@throw testException;
}

@end
