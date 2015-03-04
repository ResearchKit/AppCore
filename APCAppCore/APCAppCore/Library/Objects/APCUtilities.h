//
//  APCUtilities.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCUtilities : NSObject

/**
 When the app loads, it calls this method to tell us
 what the REAL, human-readable name is.  If not set,
 we'll explore various sytem variables trying to find
 the name.
 */
+ (void) setRealApplicationName: (NSString *) realAppName;

/**
 Human-readable name of the app, on the phone's
 desktop (the Springboard).
 
 We're still evolving how to figure this out.
 We have 9 different experiments in here.  So far,
 at least one of them works in each app.
 */
+ (NSString *) appName;

/**
 Version number and build number.
 */
+ (NSString *) appVersion;

/**
 "Simulator," "iPhone 4GS," etc.
 */
+ (NSString *) deviceDescription;

/**
 "Simulator," "iPhone 4GS," etc.

 Actually, this just returns +deviceDescription.  I'm providing this
 because, to me, "phone info" makes more sense, when you're hunting
 through these libraries for something useful, even though 
 "device description" is more accurate.
 */
+ (NSString *) phoneInfo;

/**
 Trims whitespace from someString and returns it.
 If the trimmed string has length 0, returns nil.
 This lets us do simplified "if" statements, evaluating
 the string for its "truth" value.
 
 Included in this file simply because I needed it for the
 other code in this file.  If we find a better home for it,
 please move it there.
 */
+ (NSString *) cleanString: (NSString *) someString;


@end



// ---------------------------------------------------------
#pragma mark - Macro:  converting varArgs into a string
// ---------------------------------------------------------

/**
 This macro converts a bunch of "..." arguments into an NSString.
 
 (Other keywords to find this chunk of code:  va_args,
 varargs, vaargs, variadic arguments, variadic macro,
 dotdotdot, ellipsis, three dots)

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
			NSString extractedString = stringFromVariadicArgumentsAndFormat( messageFormat );
 
			//
			// now use the extractedString.  For example:
			//
			NSLog (@"That string was: %@", extractedString);
		}

 Behind the scenes, this macro extracts the parameters from
 that "...", takes your formatting string, and passes them
 all to +[NSString stringWithFormat], giving you a normally-
 formatted string as a result.
 
 This macro is identical to typing the following mess into
 the same method:
 
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

 -	More ways to get to the variadic arguments:
	https://developer.apple.com/library/mac/qa/qa1405/_index.html
 
 -	Well-written, general-purpose documentation about writing macros,
	which talks about the rules for defining macro "functions," using
	the trailing "\", and many cool tricks and rules:
	https://gcc.gnu.org/onlinedocs/cpp/Macros.html
 */
#define NSStringFromVariadicArgumentsAndFormat( formatString )				\
	({																		\
		NSString *formattedMessage = nil;									\
		va_list arguments;													\
		va_start (arguments, formatString);									\
		formattedMessage = [[NSString alloc] initWithFormat: formatString	\
												  arguments: arguments];	\
		va_end (arguments);													\
		formattedMessage;													\
	})






