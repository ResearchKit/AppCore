// 
//  APCLog.h 
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



@interface APCLog : NSObject

// ---------------------------------------------------------
#pragma mark - Logging wrappers:  almost generic
// ---------------------------------------------------------

/*
 These macros wrap NSLog. Evolving.
 
 You can also just call the Objective-C versions yourself.
 The reasons to use the macros are:

 -	Conceptual compatibility with NSLog().  It feels familiar.

 -	The macros automatically include the current file name,
	line number, and Objective-C class and method name.
	You can also provide that stuff to the Obj-C methods
	yourself, by calling the macro APCLogMethodInfo(),
	defined at the bottom of this file.
 */

#define APCLogError( ... )                              [APCLog methodInfo: APCLogMethodInfo ()  errorMessage: __VA_ARGS__]
#define APCLogError2( nsErrorObject )                   [APCLog methodInfo: APCLogMethodInfo ()  error: nsErrorObject]
#define APCLogException( nsException )                  [APCLog methodInfo: APCLogMethodInfo ()  exception: nsException]
#define APCLogDebug( ... )                              [APCLog methodInfo: APCLogMethodInfo ()  debug: __VA_ARGS__]
#define APCLogEvent( ... )                              [APCLog methodInfo: APCLogMethodInfo ()  event: __VA_ARGS__]
#define APCLogEventWithData( name, dictionary )         [APCLog methodInfo: APCLogMethodInfo ()  eventName: name  data: dictionary]
#define APCLogViewControllerAppeared()                  [APCLog methodInfo: APCLogMethodInfo ()  viewControllerAppeared: self]
#define APCLogFilenameBeingArchived( filenameOrPath )   [APCLog methodInfo: APCLogMethodInfo ()  filenameBeingArchived: filenameOrPath]
#define APCLogFilenameBeingUploaded( filenameOrPath )   [APCLog methodInfo: APCLogMethodInfo ()  filenameBeingUploaded: filenameOrPath]



// ---------------------------------------------------------
#pragma mark - Objective-C versions of Dhanush's API
// ---------------------------------------------------------

/*
 These methods are called by the macros above.
 
 A key feature of these methods is that they take,
 as the first parameter, a nicely-formatted string
 representing the current file, line number, class
 name, and method name.  The macros above provide that
 info for you.  You can also provide it yourself, by
 calling APCLogMethodInfo(), defined at the bottom of
 this file.  (For that matter, you can pass any
 string you like as that first parameter.)

 As with everything else, this is evolving.
 */

/** Please consider calling APCLogError() instead. */
+ (void) methodInfo: (NSString *) apcLogMethodInfo
	   errorMessage: (NSString *) formatString, ... ;

/** Please consider calling APCLogError2() instead. */
+ (void) methodInfo: (NSString *) apcLogMethodInfo
			  error: (NSError *) error;

/** Please consider calling APCLogException() instead. */
+ (void) methodInfo: (NSString *) apcLogMethodInfo
          exception: (NSException *) exception;

/** Please consider calling APCLogDebug() instead. */
+ (void) methodInfo: (NSString *) apcLogMethodInfo
              debug: (NSString *) formatString, ... ;

/** Please consider calling APCLogFilenameBeingArchived() instead. */
+ (void)       methodInfo: (NSString *) apcLogMethodInfo
    filenameBeingArchived: (NSString *) filenameOrPath;

/** Please consider calling APCLogFilenameBeingUploaded() instead. */
+ (void)       methodInfo: (NSString *) apcLogMethodInfo
    filenameBeingUploaded: (NSString *) filenameOrPath;

/** Please consider calling APCLogEvent() instead. */
+ (void) methodInfo: (NSString *) apcLogMethodInfo
			  event: (NSString *) formatString, ... ;

/** Please consider calling APCLogEventWithData() instead. */
+ (void) methodInfo: (NSString *) apcLogMethodInfo
		  eventName: (NSString *) name
			   data: (NSDictionary *) eventDictionary;

/** Please consider calling APCLogViewControllerAppeared() instead. */
+ (void)        methodInfo: (NSString *) apcLogMethodInfo
	viewControllerAppeared: (NSObject *) viewController;



// ---------------------------------------------------------
#pragma mark - Utility Macro
// ---------------------------------------------------------

/**
 Generates an NSString with the current filename,
 line number, class name, and method name.  You can
 use this by itself.  All our logging macros also
 use it.
 
 This macro requires parentheses just for readability,
 so we realize it's doing work (allocating an NSString).
 */
#define APCLogMethodInfo()								\
	([NSString stringWithFormat: @"in %s at %@:%d",		\
		(__PRETTY_FUNCTION__),							\
		@(__FILE__).lastPathComponent,					\
		(int) (__LINE__)								\
	])


@end
















