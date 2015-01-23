//
//  APCLog.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "APCLog.h"
#import "Flurry.h"
#import "APCConstants.h"


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

static NSString *TEST_FLURRY_API_KEY = @"N6Y52H6HPN6ZJ9DGN2JV";		// App "Test," developer personal account


@implementation APCLog


// ---------------------------------------------------------
#pragma mark - Macro:  converting varArgs into a string
// ---------------------------------------------------------

/**
 This macro converts a bunch of "..." arguments into an NSString.

 Note that this macro requires ARC.  (To use it without ARC,
 edit the macro to call "autorelease" on formattedMessage before
 returning it.)


 To use it: 
 
 First, create a method that ENDS with a "...", like this:
 
		- (void) printMyStuff: (NSString *) messageFormat, ...
		{
		}
 
 Inside that method, call this macro, passing it the string
 you want to use as a formatting string.  Using the above
 example, it might be:
 
		- (void) printMyStuff: (NSString *) messageFormat, ...
		{
			NSString extractedString = stringFromVariadicArgumentsAndFormat(messageFormat);
 
			//
			// now use the extractedString.  For example:
			//
			NSLog (@"That string was: %@", extractedString);
		}

 Behind the scenes, this macro extracts the parameters from
 that "...", takes your formatting string, and passes them
 all to +[NSString stringWithFormat], giving you a normally-
 formatted string as a result.
 
 This is identical to typing the following mess into the
 same method:
 
	va_list arguments;
	va_start (arguments, format);
	NSString *formattedMessage = [[NSString alloc] initWithFormat: format
													    arguments: arguments];
	va_end (arguments);
 
 ...and then using the string "formattedMessage" somewhere.
 
 If you're interested:  this macro "returns" a value by wrapping
 the whole thing in a ({ ... }) and them simply putting the value
 on a line by itself at the end.
 
 References:

 -	Extracting the variadic arguments (the "..." parameter) into an array we pass to NSString:
	http://stackoverflow.com/questions/1420421/how-to-pass-on-a-variable-number-of-arguments-to-nsstrings-stringwithformat

 -	"Returning" a value from a macro:
	http://stackoverflow.com/questions/2679182/have-macro-return-a-value

 -	More ways to get to the variadic arguments arguments:
	https://developer.apple.com/library/mac/qa/qa1405/_index.html
 
 @author Ron
 @date December 10, 2014
 */
#define NSStringFromVariadicArgumentsAndFormat(formatString)				\
	({																		\
		NSString *formattedMessage = nil;									\
		va_list arguments;													\
		va_start (arguments, formatString);									\
		formattedMessage = [[NSString alloc] initWithFormat: formatString	\
												  arguments: arguments];	\
		va_end (arguments);													\
		formattedMessage;													\
	})



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

//		[Flurry setLogLevel: FlurryLogLevelAll];
		[Flurry startSession: _flurryApiKey];
        [Flurry setCrashReportingEnabled:YES];
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
#pragma mark - Logging Methods
// ---------------------------------------------------------

+ (void) log: (NSString *) format, ...
{
	NSDate *now = [NSDate date];
	NSString *dateString = [dateFormatter stringFromDate: now];
	NSString *output = [NSString stringWithFormat: @"%@: %@", dateString, NSStringFromVariadicArgumentsAndFormat (format)];
	NSLog (@"%@", output);
}

+ (void) logException: (NSException *) exception
			   format: (NSString *) messageOrFormattingString, ...
{
	[self log: @"EXCEPTION: %@ Exception text: %@  Stack trace:\n%@",
	 NSStringFromVariadicArgumentsAndFormat (messageOrFormattingString),
	 exception,
	 exception.callStackSymbols];
}

+ (void) logException: (NSException *) exception
{
	[self log: @"EXCEPTION: [%@]. Stack trace:\n%@", exception, exception.callStackSymbols];
}

+ (void) file: (NSString *) fileName
		 line: (NSInteger) lineNumber
	   method: (NSString *) classAndMethodName
	   format: (NSString *) messageFormat, ...
{
	NSLog (@"%@ [%@:%d] %@ %@",
		   [dateFormatter stringFromDate: [NSDate date]],
		   fileName,
		   (int) lineNumber,
		   classAndMethodName,
		   NSStringFromVariadicArgumentsAndFormat (messageFormat));
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

	[self logInternal_tag: @"APC_ERROR"
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
            [Flurry logError: error.domain message: description error: error];
        }

		[self logInternal_tag: @"APC_ERROR"
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
            [Flurry logError: exception.name message: exception.reason exception: exception];
        }

		[self logInternal_tag: @"APC_ERROR"
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

	[self logInternal_tag: @"APC_DEBUG"
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

	[self logInternal_tag: @"APC_EVENT"
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

	[self logInternal_tag: @" APC_DATA"
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

	[self logInternal_tag: @" APC_VIEW"
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
	// Objective-C disables all NSLog() statements in
	// a "release" build.
	NSLog (@"%@ %@ => %@", tag, methodInfo, message);
}

@end









