//
//  APCLog.m
//  APCAppCore
//
//  Created by Ron Conescu on 12/7/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCLog.h"
#import "Flurry.h"



static NSDateFormatter *dateFormatter = nil;



/**
 Enables or disables all logging, according to the 
 global DEBUG setting (i.e., whether we're in a
 "debug" or "release" configuration, as defined
 in the current Xcode "scheme").
 */
#ifdef DEBUG
	#define IS_DEBUG_DEFINED YES
#else
	#define IS_DEBUG_DEFINED NO
#endif

/** Um...  why doesn't this work from the test harness, even with a "release" build defined? */
#define DEBUG_PRINT_LOGGING_STATEMENTS  YES	// IS_DEBUG_DEFINED


/**
 I'm not sure what happens if Flurry is unavailable,
 and, in this branch, my Flurry-start code runs when
 the app launches, from:
 
	-[APCAppDelegate application:didFinishLaunchingWithOptions:]
 
 So this turns it off until I have a chance to test it.
 */
#define DEBUG_USE_FLURRY  NO


/**
 Apple says they use these formatting codes:
 http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
 */
static NSString *LOG_DATE_FORMAT = @"yyyy-MM-dd HH:mm:ss.SSS ZZZZ";

/**
 This is hard-coded to one of the developers' test accounts,
 and an application named "Test".  We'll fix that shortly.
 */
static NSString *FLURRY_API_KEY = @"N6Y52H6HPN6ZJ9DGN2JV";


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

/**
 Called by -[APCAppDelegate application:didFinishLaunchingWithOptions:],
 in AppCore.
 */
+ (void) start
{
	if (DEBUG_USE_FLURRY)
	{
		APCLogDebug (@"Starting Flurry session.");

		[Flurry startSession: FLURRY_API_KEY];
	}

	else
	{
		APCLogDebug (@"Flurry integration is disabled (macro DEBUG_USE_FLURRY).  Not connecting to Flurry.");
	}
}

+ (void) initialize
{
	if (dateFormatter == nil)
	{
		dateFormatter = [NSDateFormatter new];
		dateFormatter.dateFormat = LOG_DATE_FORMAT;
	}
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

		[self logInternal_tag: @"APC_ERROR"
					   method: apcLogMethodData
					  message: description];
	}
}

+ (void) methodInfo: (NSString *) apcLogMethodData
				log: (NSString *) formatString, ...
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

	[self logInternal_tag: @"APC_EVENT"
				   method: apcLogMethodData
				  message: formattedMessage];
}

+ (void) methodInfo: (NSString *) apcLogMethodData
		  eventName: (NSString *) eventName
			   data: (NSDictionary *) eventDictionary
{
	NSString *message = [NSString stringWithFormat: @"%@: %@", eventName, eventDictionary];

	[self logInternal_tag: @" APC_DATA"
				   method: apcLogMethodData
				  message: message];
}

+ (void)        methodInfo: (NSString *) apcLogMethodData
	viewControllerAppeared: (NSObject *) viewController
{
	NSString *message = [NSString stringWithFormat: @"%@ appeared.", NSStringFromClass (viewController.class)];

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
	// Um...  why isn't this "if" statement doing anything
	// in the test harness?  (It works fine in Diabetes.)
	if (DEBUG_PRINT_LOGGING_STATEMENTS == YES)
	{
		NSLog (@"%@ %@ => %@", tag, methodInfo, message);
	}
}

@end









