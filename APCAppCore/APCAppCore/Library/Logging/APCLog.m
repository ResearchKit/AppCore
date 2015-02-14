//
//  APCLog.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "APCLog.h"
#import "Flurry.h"
#import "APCConstants.h"
#import "APCUtilities.h"


static NSDateFormatter *dateFormatter = nil;


/**
 Apple says they use these formatting codes:
 http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
 */
static NSString *LOG_DATE_FORMAT = @"yyyy-MM-dd HH:mm:ss.SSS ZZZZ";

/**
 Set by each application when it starts up.
 */
static BOOL _isFlurryOn = NO;

/**
 Set (or not) by each application when it starts up.
 */
static NSString *_flurryApiKey = nil;

/**
 A test key, to make sure logging works.
 This is from a developer's personal, free account with Flurry.
 */
static NSString *TEST_FLURRY_API_KEY = @"N6Y52H6HPN6ZJ9DGN2JV";



// ---------------------------------------------------------
#pragma mark - "Tags" - introductory strings in print statements
// ---------------------------------------------------------

/*
 "Tags" that appear at the left edge of the debugging
 statements we print with this logging facility.
 */

static NSString * const APCLogTagError = @"APC_ERROR";
static NSString * const APCLogTagDebug = @"APC_DEBUG";
static NSString * const APCLogTagEvent = @"APC_EVENT";
static NSString * const APCLogTagData  = @" APC_DATA";
static NSString * const APCLogTagView  = @" APC_VIEW";



@implementation APCLog



// ---------------------------------------------------------
#pragma mark - Setup
// ---------------------------------------------------------

+ (void) initialize
{
	if (dateFormatter == nil)
	{
		dateFormatter = [NSDateFormatter new];
		dateFormatter.dateFormat = LOG_DATE_FORMAT;
	}
}

/**
 Called by -[APCAppDelegate application:didFinishLaunchingWithOptions:],
 in AppCore.
 */
+ (void) setupTurningFlurryOn: (BOOL) shouldTurnFlurryOn
				 flurryApiKey: (NSString *) flurryApiKey
{
	_isFlurryOn = shouldTurnFlurryOn;
	_flurryApiKey = flurryApiKey;

	if (_isFlurryOn)
	{
		APCLogDebug (@"Starting Flurry session.");

		// Please don't delete this line of code, so that
		// we remember it's possible.
//		[Flurry setLogLevel: FlurryLogLevelAll];

        [Flurry setCrashReportingEnabled:YES];
		[Flurry startSession: _flurryApiKey];
	}

	else
	{
		APCLogDebug (@"Flurry integration is disabled (using +setupTurningFlurryOn:flurryApiKey:).  Not connecting to Flurry.");
	}
}



// ---------------------------------------------------------
#pragma mark - Status
// ---------------------------------------------------------

+ (BOOL) isFlurryEnabled
{
	return (_isFlurryOn);
}

+ (NSString *) flurryApiKey
{
	return _flurryApiKey;
}



// ---------------------------------------------------------
#pragma mark - New Logging Methods.  No, really.
// ---------------------------------------------------------

+ (void) methodInfo: (NSString *) apcLogMethodInfo
	   errorMessage: (NSString *) formatString, ...
{
	if (formatString == nil)
	{
		formatString = @"(no message)";
	}

	NSString *formattedMessage = NSStringFromVariadicArgumentsAndFormat(formatString);

	[self logInternal_tag: APCLogTagError
				   method: apcLogMethodInfo
				  message: formattedMessage];
}

+ (void) methodInfo: (NSString *) apcLogMethodData
			  error: (NSError *) error
{
	if (error != nil)
	{
		NSString *description = (error.localizedDescription ?:
								 error.description ?:
								 [NSString stringWithFormat: @"%@", error]);
        
        if (self.isFlurryEnabled)
        {
            [Flurry logEvent: kErrorEvent withParameters: @{
                                                            @"error_description" : description,
                                                            @"full_error_description": [NSString stringWithFormat: @"%@", error]
                                                            }];

            /*
			 Makes the app slow. Revisit with next version of Flurry SDK.

			 Please don't delete this line of code.  We want this; it's
			 just broken-ish.
			 */
//            [Flurry logError: error.domain message: description error: error];
        }

		[self logInternal_tag: APCLogTagError
					   method: apcLogMethodData
					  message: description];
	}
}

+ (void) methodInfo: (NSString *) apcLogMethodData
		  exception: (NSException *) exception
{
	if (exception != nil)
	{
		NSString *description = (exception.name ?:
								 [NSString stringWithFormat: @"%@", exception]);

		NSString *printout = [NSString stringWithFormat: @"EXCEPTION: [%@]. Stack trace:\n%@", exception, exception.callStackSymbols];


        if (self.isFlurryEnabled)
        {
            [Flurry logEvent: kErrorEvent withParameters: @{
                                                            @"exception_name" : description,
                                                            @"exception_reason" : exception.reason,
                                                            @"exception_stacktrace": printout
                                                            }];
			/*
			 Makes the app slow. Revisit with next version of Flurry SDK.

			 Please don't delete this line of code.  We want this; it's
			 just broken-ish.
			 */
//            [Flurry logError: exception.name message: exception.reason exception: exception];
        }

		[self logInternal_tag: APCLogTagError
					   method: apcLogMethodData
					  message: printout];
	}
}

+ (void) methodInfo: (NSString *) apcLogMethodData
			  debug: (NSString *) formatString, ...
{
	if (formatString == nil)
	{
		formatString = @"(no message)";
	}

	NSString *formattedMessage = NSStringFromVariadicArgumentsAndFormat(formatString);

	[self logInternal_tag: APCLogTagDebug
				   method: apcLogMethodData
				  message: formattedMessage];
}

+ (void) methodInfo: (NSString *) apcLogMethodData
			  event: (NSString *) formatString, ...
{
	if (formatString == nil)
	{
		formatString = @"(no message)";
	}

	NSString *formattedMessage = NSStringFromVariadicArgumentsAndFormat(formatString);

	if (self.isFlurryEnabled)
	{
		[Flurry logEvent: formattedMessage];
	}

	[self logInternal_tag: APCLogTagEvent
				   method: apcLogMethodData
				  message: formattedMessage];
}

+ (void) methodInfo: (NSString *) apcLogMethodData
		  eventName: (NSString *) eventName
			   data: (NSDictionary *) eventDictionary
{
	NSString *message = [NSString stringWithFormat: @"%@: %@", eventName, eventDictionary];

	if (self.isFlurryEnabled)
	{
		[Flurry logEvent: eventName withParameters: eventDictionary];
	}

	[self logInternal_tag: APCLogTagData
				   method: apcLogMethodData
				  message: message];
}

+ (void)        methodInfo: (NSString *) apcLogMethodData
	viewControllerAppeared: (NSObject *) viewController
{
	NSString *message = [NSString stringWithFormat: @"%@ appeared.", NSStringFromClass (viewController.class)];
    
    if (self.isFlurryEnabled)
    {
        [Flurry logEvent: kPageViewEvent withParameters: @{@"viewcontroller_viewed" : NSStringFromClass(viewController.class)}];
    }

	[self logInternal_tag: APCLogTagView
				   method: apcLogMethodData
				  message: message];
}



// ---------------------------------------------------------
#pragma mark - The centralized, internal logging method
// ---------------------------------------------------------

+ (void) logInternal_tag: (NSString *) tag
				  method: (NSString *) methodInfo
				 message: (NSString *) message
{
	/*
	 Objective-C disables all NSLog() statements in
	 a "release" build, so this is safe to leave as-is.
	 */
	NSLog (@"%@ %@ => %@", tag, methodInfo, message);
}

@end









