// 
//  NSError+APCAdditions.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSError (APCAdditions)

/*********************************************************************************/
#pragma mark - Error handlers
/*********************************************************************************/

- (void) handle DEPRECATED_ATTRIBUTE;
- (NSString*) message;


/*********************************************************************************/
#pragma mark - Convenience Initializers
/*********************************************************************************/

/**
 Shortcut for creating an NSError with the specified fields.
 Code and domain are required.  The other fields are optional.

 These convenience methods all call the same, master convenience
 method behind the scenes.  Please add any more such methods
 you need.

 @param  code       APCErrorCode is an enum intended as a catchall
                    for all our errors.  Please feel free to add your
                    own error codes in there, alphabetized and grouped
                    like the rest of them.  You can also just pass an
                    NSInteger for this field.
 
 @param  domain     A string representing the category of error.
 */
+ (NSError *) errorWithCode: (APCErrorCode) code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion;

/**
 Shortcut for creating an NSError with the specified fields.
 Code and domain are required.  The other fields are optional.

 These convenience methods all call the same, master convenience
 method behind the scenes.  Please add any more such methods
 you need.

 @param  code           APCErrorCode is an enum intended as a catchall
                        for all our errors.  Please feel free to add your
                        own error codes in there, alphabetized and grouped
                        like the rest of them.  You can also just pass an
                        NSInteger for this field.

 @param  domain         A string representing the category of error.
 
 @param  nestedError    The error which caused the error you're reporting.
                        Appears in the resulting error's userInfo dictionary
                        using Apple's standard "underlying error" key.  If you
                        pass nil, that value will be omitted.  This also means
                        you can pass in some random error variable which may
                        or may not be set to anything, and this method will
                        do the right thing with it.
 */
+ (NSError *) errorWithCode: (APCErrorCode) code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
                nestedError: (NSError *)  rootCause;

/**
 Shortcut for creating an NSError with the specified fields.
 Code and domain are required.  The other fields are optional.

 These convenience methods all call the same, master convenience
 method behind the scenes.  Please add any more such methods
 you need.

 @param  code       APCErrorCode is an enum intended as a catchall
                    for all our errors.  Please feel free to add your
                    own error codes in there, alphabetized and grouped
                    like the rest of them.  You can also just pass an
                    NSInteger for this field.
 
 @param  domain     A string representing the category of error.
 */
+ (NSError *) errorWithCode: (APCErrorCode) code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
            relatedFilePath: (NSString *) someFilePath;

/**
 Shortcut for creating an NSError with the specified fields.
 Code and domain are required.  The other fields are optional.

 These convenience methods all call the same, master convenience
 method behind the scenes.  Please add any more such methods
 you need.

 @param  code       APCErrorCode is an enum intended as a catchall
                    for all our errors.  Please feel free to add your
                    own error codes in there, alphabetized and grouped
                    like the rest of them.  You can also just pass an
                    NSInteger for this field.
 
 @param  domain     A string representing the category of error.
 */
+ (NSError *) errorWithCode: (APCErrorCode) code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
                 relatedURL: (NSURL *)    someURL;

/**
 Shortcut for creating an NSError with the specified fields.
 Code and domain are required.  The other fields are optional.

 These convenience methods all call the same, master convenience
 method behind the scenes.  Please add any more such methods
 you need.

 @param  code           APCErrorCode is an enum intended as a catchall
                        for all our errors.  Please feel free to add your
                        own error codes in there, alphabetized and grouped
                        like the rest of them.  You can also just pass an
                        NSInteger for this field.

 @param  domain         A string representing the category of error.
 
 @param  nestedError    The error which caused the error you're reporting.
                        Appears in the resulting error's userInfo dictionary
                        using Apple's standard "underlying error" key.  If you
                        pass nil, that value will be omitted.  This also means
                        you can pass in some random error variable which may
                        or may not be set to anything, and this method will
                        do the right thing with it.
 */
+ (NSError *) errorWithCode: (APCErrorCode) code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
            relatedFilePath: (NSString *) someFilePath
                 relatedURL: (NSURL *)    someURL
                nestedError: (NSError *)  rootCause;

@end




















