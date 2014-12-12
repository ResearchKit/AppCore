//
//  APCLog.h
//  APCAppCore
//
//  Created by Ron Conescu on 12/7/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface APCLog : NSObject



// ---------------------------------------------------------
#pragma mark - Flurry integration
// ---------------------------------------------------------

+ (void) start;



// ---------------------------------------------------------
#pragma mark - Ron's ideas
// ---------------------------------------------------------

+ (void) log: (NSString *) format, ...;
+ (void) logException: (NSException *) exception;
+ (void) logException: (NSException *) exception format: (NSString *) messageOrFormattingString, ...;

+ (void) file: (NSString *) fileName
		 line: (NSInteger) lineNumber
	   method: (NSString *) classAndMethodName
	   format: (NSString *) messageFormat, ...;


/**
 This macro calls the method +[APCLog file:line:format:],
 passing it the __FILE__, __LINE__, and __PRETTY_FUNCTION__
 (class and method name) from which you called it.
 Use this like so:
 
		[APCLogF format: @"blah blah blah", ...]
 
 just the way you use NSLog() or [APCLog log:].
 */
#define APCLogF APCLog file: @(__FILE__).lastPathComponent line: (NSInteger) __LINE__  method: @(__PRETTY_FUNCTION__)


/* Experiments.  In progress.  Ignore, please. */
#define APCErrorLog_ron(messageString)	[APCLogF message: messageString];
#define APCScreenLog_ron(x)
#define APCEventLog_ron(x)
#define APCDebugLog_ron(x)	[APCLogF format: messageString];




// ---------------------------------------------------------
#pragma mark - Objective-C versions of Dhanush's API
// ---------------------------------------------------------

/*
 These methods are called by the macros in the next section
 of this file.  The goal is to get all the macros to use
 the same centralized function for logging, so we can disable
 and/or redirect the logging messages in one place.
 
 As with everything else, this is evolving.
 */

/** Please call APCLogError() instead. */
+ (void) methodInfo: (NSString *) apcLogMethodInfo  errorMessage           : (NSString *) formatString, ... ;

/** Please call APCLogError2() instead. */
+ (void) methodInfo: (NSString *) apcLogMethodInfo  error                  : (NSError *)  error;

/** Please call APCLogDebug() instead. */
+ (void) methodInfo: (NSString *) apcLogMethodInfo  log                    : (NSString *) formatString, ... ;

/** Please call APCLogEvent() instead. */
+ (void) methodInfo: (NSString *) apcLogMethodInfo  event                  : (NSString *) formatString, ... ;

/** Please call APCLogEventWithData() instead. */
+ (void) methodInfo: (NSString *) apcLogMethodInfo  eventName              : (NSString *) name  data: (NSDictionary *) eventDictionary;

/** Please call APCLogViewControllerAppeared() instead. */
+ (void) methodInfo: (NSString *) apcLogMethodInfo  viewControllerAppeared : (NSObject *) viewController;



// ---------------------------------------------------------
#pragma mark - Dhanush's API (Ron's version)
// ---------------------------------------------------------

#define APCLogError( ... )						[APCLog methodInfo: APCLogMethodInfo ()  errorMessage: __VA_ARGS__]
#define APCLogError2( nsErrorObject )			[APCLog methodInfo: APCLogMethodInfo ()  error: nsErrorObject]
#define APCLogDebug( ... )						[APCLog methodInfo: APCLogMethodInfo ()  log: __VA_ARGS__]
#define APCLogEvent( ... )						[APCLog methodInfo: APCLogMethodInfo ()  event: __VA_ARGS__]
#define APCLogEventWithData( name, dictionary )	[APCLog methodInfo: APCLogMethodInfo ()  eventName: name  data: dictionary]
#define APCLogViewControllerAppeared()			[APCLog methodInfo: APCLogMethodInfo ()  viewControllerAppeared: self]




// ---------------------------------------------------------
#pragma mark - Utility Macros
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
















