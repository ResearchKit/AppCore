//
//  APCUploadValidationServer.h
//  AppCore
//
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 This stuff was originally in

	APCDataSubstrate+ResearchKit.m

 That file is CURRENTLY (for this 48 hours) not used.
 This happens to be when I'm working on this "mirror to local server" feature.
 After discussion with Farhan, this seems the best (temporary) place to put this code.

 Copied from Ed's commit of
 APCDataSubstrate+ResearchKit.m
 dated 2014-Dec-03.
 */
@interface APCUploadValidationServer : NSObject

/**
 Call this to enable or disable logging.
 By default, uses the "DEVELOPMENT" #define,
 which is YES in debug mode and NO in production.
 */
+ (void) setupTurningLoggingOn: (BOOL) shouldTurnLoggingOn;

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
+ (void) logText: (NSString *) text
withFakeFilename: (NSString *) fakeFilename;

/* 
 The point of this class.

 If the data is empty or nil, logs a "no data" message.

 Does nothing if logging is disabled.  Logging is enabled
 by default in debug mode.  To enable in production,
 call +setupTurningLoggingOn.
 */
+ (void) logDataFromFilePath: (NSString *) path;

@end
