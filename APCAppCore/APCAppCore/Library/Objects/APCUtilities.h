// 
//  APCUtilities.h 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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
 Returns YES if the current build is a "DEBUG" build --
 i.e., if the DEBUG preprocessor flag is defined.  Lets
 us use debug-only logic in normal "if" statements,
 instead of having to use #if statements.
 */
+ (BOOL) isInDebuggingMode;

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

/**
 Returns the path to the user's "Documents" directory.
 */
+ (NSString *) pathToUserDocumentsFolder;

/**
 Returns the temporary directory for the current user.
 
 @param shouldAddUUID  Specify YES to append a new, randomly-generated
 UUID to the end of the temporary directory, NO to get the raw 
 temp directory itself.
 */
+ (NSString *) pathToTemporaryDirectoryAddingUuid: (BOOL) shouldAddUuid;


/**
 Returns the file-creation date on our database file.
 A good approximation of the first time the user ran the
 app.
 */
+ (NSDate *) firstKnownFileAccessDate;


@end



// ---------------------------------------------------------
#pragma mark - Other Macros
// ---------------------------------------------------------

/**
 Returns valueToTest clamped to minValue and maxValue.
 I.e., returns minValue if valueToTest is less than
 minValue, maxValue if valueToTest if greater than
 maxValue, and valueToTest itself if it's between those
 two values.
 
 This macro name is in ALL CAPS simply to be consistent
 with MIN() and MAX().
 */
#define CLAMP( minValue, valueToTest, maxValue ) (MIN (MAX (valueToTest, minValue), maxValue))



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
			NSString extractedString = NSStringFromVariadicArgumentsAndFormat ( messageFormat );
 
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



/**
 Macro NSArrayFromVariadicArguments()

 This macro converts a bunch of "..." arguments into an NSArray,
 including the parameter to the left of the "...".  Each argument
 must be an "id" type, or a subclass of NSObject.
 
 @details
 To use it: 
 
 First, create a method that ENDS with a "...", like this:
 
 @code
		- (void) collectMyStuff: (NSNumber *) myAge, ...
		{
		}
 @endcode

 The data type of that parameter doesn't matter for the purpose
 of this macro.  It only matters that there IS a parameter to the
 left of the ", ..." (the comma-space-dot-dot-dot).
 
 Inside that method, call this macro, passing it the name of the
 parameter to the left of the "...".  Using the above method as
 an example, you might write:
 
 @code
		- (void) collectMyStuff: (NSNumber *) myAge, ...
		{
			NSArray myStuff = NSArrayFromVariadicArguments( myAge );
 
			//
			// now use myStuff.  For example:
			//
			NSLog (@"All my stuff is: %@", myStuff);
		}
 @endcode
 
 You might use it like this:

 @code
        NSString *name = @"Joe";
        UIColor *favoriteColor = [UIColor blueColor];
        NSNumber *age = "50";

        [self collectMyStuff: name, favoriteColor, age];
 @endcode

 Behind the scenes, this macro adds that first parameter to
 a mutable array.  Then it walks through all the remaining "..."
 parameters (if any), adding each of them to the same mutable
 array.  Finally, it slurps the contents of the mutable array
 into a normal NSArray and returns that.
 
 Note that this macro requires ARC.  (To use it without ARC,
 you'll need to edit the macro to release and autorelease
 things appropriately.)
 
 This macro was created with the same research as for
 NSStringFromVariadicArgumentsAndFormat(), with some additional
 help regarding this command for accessing individual parameters
 in the "..." list:

    http://www.cplusplus.com/reference/cstdarg/va_arg/

 For more information, see NSStringFromVariadicArgumentsAndFormat ().

 Other keywords to find this chunk of code:  va_args, varargs,
 vaargs, variadic arguments, variadic macro, dotdotdot, ellipsis,
 three dots
*/
#define NSArrayFromVariadicArguments( firstArgumentName )                   \
    ({                                                                      \
        NSMutableArray *incomingObjects = [NSMutableArray new];             \
        [incomingObjects addObject: firstArgumentName];                     \
        va_list arguments;                                                  \
        va_start (arguments, firstArgumentName);                            \
        [incomingObjects addObject: va_arg (arguments, id)];                \
        va_end (arguments);                                                 \
        NSArray *returnValue = [NSArray arrayWithArray: incomingObjects];   \
        returnValue; \
    })




