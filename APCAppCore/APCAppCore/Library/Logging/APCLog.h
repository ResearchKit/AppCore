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
#pragma mark - Dhanush's API (Ron's version)
// ---------------------------------------------------------

/**
 Generates an NSString with the current filename,
 line number, class name, and method name.  You can
 use this by itself.  All our logging macros also
 use it.
 
 This macro requires parentheses just for readability,
 so we realize it's doing work (allocating an NSString).
 */
#define APCLogGetMethodCallData()						\
	[NSString stringWithFormat: @"in %s at %@:%d =>",	\
		__PRETTY_FUNCTION__,							\
		@(__FILE__).lastPathComponent,					\
		(int) __LINE__									\
	]

#define APCLogError(...)								\
	NSLog (@"APC_ERROR %@ %@",							\
		APCLogGetMethodCallData (),						\
		[NSString stringWithFormat: __VA_ARGS__]		\
	)

#define APCLogError2( nsErrorObject )					\
    if (nsErrorObject != nil)							\
	{													\
		NSString *description = (nsErrorObject.localizedDescription ?:					\
								 nsErrorObject.description ?:							\
								 [NSString stringWithFormat: @"%@", nsErrorObject]);	\
														\
		NSLog (@"APC_ERROR %@ %@",						\
			APCLogGetMethodCallData (),					\
			description									\
		);												\
	}

#define APCLogDebug(...)								\
	NSLog (@"APC_DEBUG %@ %@",							\
		APCLogGetMethodCallData (),						\
		[NSString stringWithFormat: __VA_ARGS__]		\
	)

#define APCLogEvent(...)								\
	NSLog (@"APC_EVENT %@ %@",							\
		APCLogGetMethodCallData (),						\
		[NSString stringWithFormat: __VA_ARGS__]		\
	)

#define APCLogEventWithData(eventName, eventDictionary)	\
	NSLog (@" APC_DATA %@ %@:%@",						\
		APCLogGetMethodCallData (),						\
		eventName,										\
		eventDictionary									\
	);

#define APCLogViewControllerAppeared()					\
	NSLog (@" APC_VIEW %@ %@ appeared.",				\
		APCLogGetMethodCallData (),						\
        NSStringFromClass (self.class)					\
	)



@end
















