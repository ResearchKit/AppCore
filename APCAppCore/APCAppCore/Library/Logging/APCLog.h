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

#define APCLogError(...)							\
	NSLog (@"APC_ERROR  %@:%d  %s  %@",				\
		@(__FILE__).lastPathComponent,				\
		(int) __LINE__,								\
		__PRETTY_FUNCTION__,						\
		[NSString stringWithFormat: __VA_ARGS__]	\
	)

#define APCLogDebug(...)							\
	NSLog (@"APC_DEBUG  %@:%d  %s  %@",				\
		@(__FILE__).lastPathComponent,				\
		(int) __LINE__,								\
		__PRETTY_FUNCTION__,						\
		[NSString stringWithFormat: __VA_ARGS__]	\
	)

#define APCLogEvent(...)							\
	NSLog (@"APC_EVENT  %@:%d  %s  %@",				\
		@(__FILE__).lastPathComponent,				\
		(int) __LINE__,								\
		__PRETTY_FUNCTION__,						\
		[NSString stringWithFormat: __VA_ARGS__]	\
	)

#define APCLogEventWithData(eventName, eventDictionary)  \
	NSLog (@"APC_DATA   %@:%d  %s  %@:%@",			\
		@(__FILE__).lastPathComponent,				\
		(int) __LINE__,								\
		__PRETTY_FUNCTION__,						\
		eventName,									\
		eventDictionary								\
	);


//
// I think APCLogMethod(), below, describes what this is doing better.
//
//	#define APCLogViewController()						\
//		NSLog (@"APC_VIEW_CONTROLLER  %@:%d  %@",		\
//			@(__FILE__).lastPathComponent,				\
//			(NSInteger) __LINE__,						\
//			NSStringFromClass ([self class])			\
//		)
#define APCLogViewController() APCLogMethod()



// ---------------------------------------------------------
#pragma mark - ...and running with that...
// ---------------------------------------------------------

#define APCLogMethod()						\
	NSLog (@"%@:%d  %s",					\
		@(__FILE__).lastPathComponent,		\
		(int) __LINE__,						\
		__PRETTY_FUNCTION__					\
	)



@end
















