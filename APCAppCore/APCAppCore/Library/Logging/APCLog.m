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
 Apple says they use these formatting codes:
 http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
 */
static NSString *LOG_DATE_FORMAT = @"yyyy-MM-dd HH:mm:ss.SSS ZZZZ";

/**
 TODO:  Remove this comment.  This is just to discuss with Ed and Dhanush.

 From Ron's personal signup key for application "Test"
 */
static NSString *FLURRY_API_KEY = @"N6Y52H6HPN6ZJ9DGN2JV";


@implementation APCLog

+ (void) start
{
	[Flurry startSession: FLURRY_API_KEY];
}

+ (void) initialize
{
	if (dateFormatter == nil)
	{
		dateFormatter = [NSDateFormatter new];
		dateFormatter.dateFormat = LOG_DATE_FORMAT;
	}
}

//	/**
//	 In progress:  learning how to convert the "..." into
//	 an NSString in a portable way.
//	 */
//	#define VARARGS_INTO_FORMATTING_STRING( nameOfFormattingStringVariable )							\
//		va_list dotDotDotArguments;																		\
//		va_start( dotDotDotArguments, nameOfFormattingStringVariable );									\
//		NSString *formattedMessage = [[NSString alloc] initWithFormat: nameOfFormattingStringVariable	\
//															arguments: dotDotDotArguments];				\
//		va_end( dotDotDotArguments );


+ (void) log: (NSString *) format, ...
{
	/*
	 ----- extracting the "..." arguments -----

	 Extract the variadic arguments (the "..." parameter)
	 into an array we can then pass to NSString.  From:
	 http://stackoverflow.com/questions/1420421/how-to-pass-on-a-variable-number-of-arguments-to-nsstrings-stringwithformat

	 More ways to get to those arguments:
	 https://developer.apple.com/library/mac/qa/qa1405/_index.html
	 */
	va_list arguments;
	va_start (arguments, format);
	NSString *formattedMessage = [[NSString alloc] initWithFormat: format
														arguments: arguments];
	va_end (arguments);
	// ----- end extraction -----


	NSDate *now = [NSDate date];
	NSString *dateString = [dateFormatter stringFromDate: now];
	NSString *output = [NSString stringWithFormat: @"%@: %@", dateString, formattedMessage];
	NSLog (@"%@", output);
}

+ (void) logException: (NSException *) exception
			   format: (NSString *) messageOrFormattingString, ...
{
	NSString *formattedMessage = nil;

	/* ----- extracting the "..." arguments -----

	 I haven't yet figured out how to wrap this in a function
	 or macro, since it contains macros that have to be expanded
	 in the same method where the "..." appears.  (I think.)
	 */
	{
		va_list arguments;
		va_start (arguments, messageOrFormattingString);
		formattedMessage = [[NSString alloc] initWithFormat: messageOrFormattingString
												  arguments: arguments];
		va_end (arguments);
	}
	// ----- end extraction -----


	[self log: @"EXCEPTION: %@ Exception text: %@  Stack trace:\n%@", formattedMessage, exception, exception.callStackSymbols];
}

+ (void) logException: (NSException *) exception
{
	[self log: @"EXCEPTION: [%@]. Stack trace:\n%@", exception, exception.callStackSymbols];
}

@end
