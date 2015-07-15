// 
// NSError+APCAdditions.h
// APCAppCore
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

FOUNDATION_EXPORT NSString * const kAPCServerBusyErrorMessage;
FOUNDATION_EXPORT NSString * const kAPCUnexpectedConditionErrorMessage;
FOUNDATION_EXPORT NSString * const kAPCNotConnectedErrorMessage;
FOUNDATION_EXPORT NSString * const kAPCServerUnderMaintanenceErrorMessage;
FOUNDATION_EXPORT NSString * const kAPCAccountAlreadyExistsErrorMessage;
FOUNDATION_EXPORT NSString * const kAPCAccountDoesNotExistErrorMessage;
FOUNDATION_EXPORT NSString * const kAPCBadEmailAddressErrorMessage;
FOUNDATION_EXPORT NSString * const kAPCBadPasswordErrorMessage;
FOUNDATION_EXPORT NSString * const kAPCNotReachableErrorMessage;
FOUNDATION_EXPORT NSString * const kAPCInvalidEmailAddressOrPasswordErrorMessage;

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
 Creates an NSError with the specified domain, error code,
 reason, and suggestion, using Apple's standard keys to
 store the reason and suggestion in the error's userInfo
 dictionary.

 These convenience methods all call the same, master
 convenience method behind the scenes.  Please add any
 more such methods you need.

 @param  code       An error code.  Any integer you like.

 @param  domain     A string representing the category of error.
 */
+ (NSError *) errorWithCode: (NSInteger)  code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion;

/**
 Creates an NSError with the specified domain, error code,
 reason, suggestion, and originating error, using Apple's
 standard keys to store the latter three items in the
 error's userInfo dictionary.

 These convenience methods all call the same, master
 convenience method behind the scenes.  Please add any
 more such methods you need.

 @param  code           An error code.  Any integer you like.

 @param  domain         A string representing the category of error.
 
 @param  nestedError    The error which caused the error you're reporting.
                        Appears in the resulting error's userInfo dictionary
                        using Apple's standard "underlying error" key.  If you
                        pass nil, that value will be omitted.  This also means
                        you can pass in some random error variable which may
                        or may not be set to nil, and this method will do the
                        right thing with it.
 */
+ (NSError *) errorWithCode: (NSInteger)  code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
                nestedError: (NSError *)  rootCause;

/**
 Creates an NSError with the specified domain, error code,
 reason, suggestion, and a related file path, using Apple's
 standard keys to store the latter three items in the
 error's userInfo dictionary.

 These convenience methods all call the same, master
 convenience method behind the scenes.  Please add any
 more such methods you need.

 @param  code       An error code.  Any integer you like.

 @param  domain     A string representing the category of error.
 */
+ (NSError *) errorWithCode: (NSInteger)  code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
            relatedFilePath: (NSString *) someFilePath;

/**
 Creates an NSError with the specified domain, error code,
 reason, suggestion, and a related URL, using Apple's
 standard keys to store the latter three items in the
 error's userInfo dictionary.

 These convenience methods all call the same, master
 convenience method behind the scenes.  Please add any
 more such methods you need.

 @param  code       An error code.  Any integer you like.

 @param  domain     A string representing the category of error.
 */
+ (NSError *) errorWithCode: (NSInteger)  code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
                 relatedURL: (NSURL *)    someURL;

/**
 Creates an NSError with the specified domain, error code,
 reason, suggestion, a related file path, a related URL,
 and an originating error.  Uses Apple's standard keys to
 store those latter five items in the error's userInfo
 dictionary.

 These convenience methods all call the same, master
 convenience method behind the scenes.  Please add any
 more such methods you need.

 @param  code           An error code.  Any integer you like.

 @param  domain         A string representing the category of error.
 
 @param  nestedError    The error which caused the error you're reporting.
                        Appears in the resulting error's userInfo dictionary
                        using Apple's standard "underlying error" key.  If you
                        pass nil, that value will be omitted.  This also means
                        you can pass in some random error variable which may
                        or may not be set to nil, and this method will do the
                        right thing with it.
 */
+ (NSError *) errorWithCode: (NSInteger)  code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
            relatedFilePath: (NSString *) someFilePath
                 relatedURL: (NSURL *)    someURL
                nestedError: (NSError *)  rootCause;

/**
 Creates an NSError with the specified domain, error code,
 reason, suggestion, a related file path, a related URL, an
 originating error, and a dictionary of arbitrary other
 data.  Uses Apple's standard keys to store the reason,
 suggestion, file path, URL, and originating error in the
 error's user-info dictionary, and adds any items with
 non-conflicting keys from your otherUserInfo into that
 same dictionary.

 These convenience methods all call the same, master
 convenience method behind the scenes.  Please add any
 more such methods you need.

 @param  code           An error code.  Any integer you like.

 @param  domain         A string representing the category of error.

 @param  nestedError    The error which caused the error you're reporting.
                        Appears in the resulting error's userInfo dictionary
                        using Apple's standard "underlying error" key.  If you
                        pass nil, that value will be omitted.  This also means
                        you can pass in some random error variable which may
                        or may not be set to nil, and this method will do the
                        right thing with it.
 
 @param  otherUserInfo  Additional dictionary items you'd like to add to this
                        error object.  Note that most of the other parameters
                        to this method become entries in the userInfo dictionary,
                        too, and those values will override yours if you use the
                        same key names.  In other words, when you add items to 
                        this userInfo dictionary, don't use these keys:
                        NSLocalizedFailureReasonErrorKey,
                        NSLocalizedRecoverySuggestionErrorKey, NSFilePathErrorKey,
                        NSURLErrorKey, or NSUnderlyingErrorKey.
 */
+ (NSError *) errorWithCode: (NSInteger)  code
                     domain: (NSString *) domain
              failureReason: (NSString *) localizedFailureReason
         recoverySuggestion: (NSString *) localizedRecoverySuggestion
            relatedFilePath: (NSString *) someFilePath
                 relatedURL: (NSURL *)    someURL
                nestedError: (NSError *)  rootCause
              otherUserInfo: (NSDictionary *) otherUserInfo;

/**
 Walks through the error and prepares a friendly printout
 for it, specifically so we can print out and format the
 contents of nested errors, arrays, and dictionaries.
 */
- (NSString *) friendlyFormattedString;

@end
