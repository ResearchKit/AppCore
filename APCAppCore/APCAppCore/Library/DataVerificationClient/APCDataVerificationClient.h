//
//  APCUploadValidationServer.h
//  AppCore
//
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Uploads files and text to a matching
 DataVerificationServer, written in Ruby,
 running on a specific machine.  (We're
 still evolving how to specify the IP
 address.)
 */
@interface APCDataVerificationClient : NSObject

/**
 Call this to enable or disable logging.
 By default, uses the "DEVELOPMENT" #define,
 which is YES in debug mode and NO in production.
 */
+ (void) setupTurningLoggingOn: (BOOL) shouldTurnLoggingOn;

/**
 Returns the value passed to +setupTurningLoggingOn,
 or NO if that method was not called.
 */
+ (BOOL) isLoggingOn;

/**
 Kind of a hack, until we get result-data-archiving
 working again.  The "fake filename" is so we know
 what MIME type to give it, and so we can label it
 in the uploaded "form field."
 
 If the data is empty or nil, logs a "no data" message.

 Does nothing if logging is disabled.  Logging is enabled
 by default in debug mode.  To enable in production,
 call +setupTurningLoggingOn.
 */
+ (void)                uploadText: (NSString *) text
	withFakeFilenameForContentType: (NSString *) fakeFilename;

/* 
 The point of this class.

 If the data is empty or nil, logs a "no data" message.

 Does nothing if logging is disabled.  Logging is enabled
 by default in debug mode.  To enable in production,
 call +setupTurningLoggingOn.
 */
+ (void) uploadDataFromFileAtPath: (NSString *) path;

@end
