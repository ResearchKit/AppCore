//
//  APCLog.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCLog.h"
#import "Flurry.h"
#import "APCConstants.h"
#import "APCUtilities.h"


static NSDateFormatter *dateFormatter = nil;
static NSString * const kErrorIndentationString = @"    ";


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

static NSString * const APCLogTagError   = @"APC_ERROR  ";
static NSString * const APCLogTagDebug   = @"APC_DEBUG  ";
static NSString * const APCLogTagEvent   = @"APC_EVENT  ";
static NSString * const APCLogTagData    = @"APC_DATA   ";
static NSString * const APCLogTagView    = @"APC_VIEW   ";
static NSString * const APCLogTagArchive = @"APC_ARCHIVE";
static NSString * const APCLogTagUpload  = @"APC_UPLOAD ";



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

// ---------------------------------------------------------
#pragma mark - New Logging Methods.  No, really.
// ---------------------------------------------------------

+ (NSString *) comprehensiveErrorMessageFromError: (NSError *) error
{
    /*
     We're going to print the domain, code, and user-info dictionary.
     This will also (by definition) print out the following "normal"
     error stuff:

     - error.description.  This is composed from the domain, code, localized description, and userInfo dictionary.
     - error.localizedDescription:  This is from the userInfo dictionary.
     - error.localizedFailureReason:  This is also from the userInfo dictionary.
     */

    NSString *comprehensiveString = [NSString stringWithFormat:
                                     @"An error occurred. Available info:\n"
                                     "----- ERROR INFO -----\n"
                                     "Domain: %@\n"
                                     "Code:   %@\n"
                                     "User-info dictionary: %@\n"
                                     "----------------------",

                                     error.domain.length == 0 ? @"(none)" : error.domain,
                                     @(error.code),
                                     error.userInfo.count == 0 ? @"(empty)" : error.userInfo
                                     ];

    /*
     When we print underlying dictionaries, they come out
     with escaped newlines.  Make 'em real newlines, so we
     can read them on the console.
     */
    comprehensiveString = [comprehensiveString stringByReplacingOccurrencesOfString: @"\\n" withString: @"\n"];

    /*
     Ditto for escaped quotation marks.  (Is this safe?)
     */
    comprehensiveString = [comprehensiveString stringByReplacingOccurrencesOfString: @"\\\"" withString: @"\""];

    /*
     Ship it.
     */
    return comprehensiveString;
}

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
        NSString *description = [self comprehensiveErrorMessageFromError: error];

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

+ (void)       methodInfo: (NSString *) apcLogMethodInfo
    filenameBeingArchived: (NSString *) filenameOrPath
{
    NSString *message = [NSString stringWithFormat: @"Adding filename to .zip archive for uploading: [%@]", filenameOrPath];

    [self logInternal_tag: APCLogTagArchive
                   method: apcLogMethodInfo
                  message: message];
}

+ (void)       methodInfo: (NSString *) apcLogMethodInfo
    filenameBeingUploaded: (NSString *) filenameOrPath
{
    NSString *message = [NSString stringWithFormat: @"Uploading filename to Sage: [%@]", filenameOrPath];

    [self logInternal_tag: APCLogTagUpload
                   method: apcLogMethodInfo
                  message: message];
}

+ (void) methodInfo: (NSString *) apcLogMethodData
			  event: (NSString *) formatString, ...
{
	if (formatString == nil)
	{
		formatString = @"(no message)";
	}

	NSString *formattedMessage = NSStringFromVariadicArgumentsAndFormat(formatString);

	[self logInternal_tag: APCLogTagEvent
				   method: apcLogMethodData
				  message: formattedMessage];
}

+ (void) methodInfo: (NSString *) apcLogMethodData
		  eventName: (NSString *) eventName
			   data: (NSDictionary *) eventDictionary
{
	NSString *message = [NSString stringWithFormat: @"%@: %@", eventName, eventDictionary];

	[self logInternal_tag: APCLogTagData
				   method: apcLogMethodData
				  message: message];
}

+ (void)        methodInfo: (NSString *) apcLogMethodData
	viewControllerAppeared: (NSObject *) viewController
{
	NSString *message = [NSString stringWithFormat: @"%@ appeared.", NSStringFromClass (viewController.class)];

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









