//
//  APCLogTests2.m
//  APCAppCore
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APCLog.h"

@interface APCLogTests : XCTestCase

@end

@implementation APCLogTests



// ---------------------------------------------------------
#pragma mark - Setup
// ---------------------------------------------------------

/**
 Put setup code here. This method is called before
 the invocation of each test method in the class.
 */
- (void) setUp
{
	[super setUp];

	// Turn on Flurry.
	[APCLog setupTurningFlurryOn: YES
					flurryApiKey: @"N6Y52H6HPN6ZJ9DGN2JV"];		 // App "Test", developer's personal Flurry account
}

/**
 Put teardown code here. This method is called after
 the invocation of each test method in the class.
 */
- (void) tearDown
{
	[super tearDown];
}



// ---------------------------------------------------------
#pragma mark - first-pass ideas
// ---------------------------------------------------------

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

- (void) testRonOriginalMacros
{
	//
	// Objective-C logging
	//

	[APCLog log: @"generic message"];

	[APCLog file: @(__FILE__).lastPathComponent
			line: (NSInteger) __LINE__
		  method: @(__PRETTY_FUNCTION__)
		  format: @"message with manual file and line"];


	//
	// Objective-C logging + macro-based __FILE__, __LINE__,
	// and __PRETTY_FUNCTION__
	//

	[APCLogF format: @"message with magic file and line"];

	[APCLogF format: @"message with magic file, line, and parameters: [%@], [%d]", @"my name", 47];
}



// ---------------------------------------------------------
#pragma mark - Testing the Macros
// ---------------------------------------------------------

- (void) testLogErrorMessage
{
	APCLogError (@"The error message is: %@, age %@", @"Ron", @47);
}

- (void) testLogErrorObject
{
	NSError *error = [NSError errorWithDomain: @"Whatever, dude"
										 code: 15
									 userInfo: @{@"some custom value": @"woo-hoo!"}
					  ];

	APCLogError2 (error);
}

- (void) testLogExceptionObject
{
	@try
	{
		[self sampleExceptionThrowerFunctionStackItem2];
	}

	@catch (NSException *exception)
	{
		APCLogDebug (@"(divider line)\n\n"
					 "-------------------------------------------------------------------------\n"
					 "------------- THIS EXCEPTION PRINTOUT IS PART OF THE TEST. --------------\n"
					 "-------------------------------------------------------------------------"
					 );

		APCLogException (exception);

		APCLogDebug (@"(another divider line)\n"
					 "-------------------------------------------------------------------------\n"
					 "----------------- done with the purposeful exceptions. ------------------\n"
					 "-------------------------------------------------------------------------\n\n"
					 );
	}
	@finally
	{
	}
}

- (void) testFromWithinClassMethod
{
	[[self class] sampleClassMethod];
}

+ (void) sampleClassMethod
{
	APCLogDebug(@"This is a test from some class method or other.");
}

- (void) testLogDebug
{
	APCLogDebug (@"Simple log message");

	APCLogDebug (@"Log message with parameters:  name %@, age %@", @"Ron", @47);

	APCLogDebug (nil);
}

- (void) testLogEvent
{
	APCLogEvent (@"Simple log message");

	APCLogEvent (@"Log message with parameters:  name %@, age %@", @"Ron", @47);

	APCLogEvent (nil);
}

- (void) testLogEventWithData
{
	APCLogEventWithData ( @"RonEventName",
						  (@{
								@"eventName": @"truth",
								@"eventId": @12
							})
						);
}

- (void) testLogViewControllerAppeared
{
	APCLogViewControllerAppeared();
}

- (void) testMacrosFromWithinAFunction
{
	sampleLoggingFunction();
}

void sampleLoggingFunction ()
{
	APCLogDebug(@"Testing the printout from within a C function call.");
}

- (void) sampleExceptionThrowerFunctionStackItem2
{
	[self sampleExceptionThrowerFunctionStackItem3];
}

- (void) sampleExceptionThrowerFunctionStackItem3
{
	NSException *testException = [NSException exceptionWithName: @"Test Exception" reason: @"Just seeing if I can log exceptions correctly" userInfo: nil];

	@throw testException;
}

@end





