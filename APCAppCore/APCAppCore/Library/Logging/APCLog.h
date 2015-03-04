//
//  APCLog.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface APCLog : NSObject



// ---------------------------------------------------------
#pragma mark - Flurry integration
// ---------------------------------------------------------

/**
 Master method which turns Flurry logging on or off.
 
 This is not particularly generic.  Each of our apps
 has a hard-coded, well-known "API key" for the Flurry
 analytics service.  Each app declares that value, and
 (as of this writing) our centralized app initializers
 call this method with those values.
 
 The concept is pretty easy -- set a boolean if we want
 to enable logging -- but the implementation is quite
 app-specific, and evolving.
 */
+ (void) setupTurningFlurryOn: (BOOL) shouldTurnFlurryOn
				 flurryApiKey: (NSString *) flurryApiKey;



// ---------------------------------------------------------
#pragma mark - Logging wrappers:  almost generic, lots of Flurry
// ---------------------------------------------------------

/*
 These macros wrap NSLog and, sometimes, calls to Flurry
 to analyze our apps' behavior.  Evolving.  Please
 see the body of each matching Objective-C method (below)
 to learn which macros call Flurry.
 
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
















