//
//  APCUploadValidationServer.h
//  AppCore
//
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//



/*
 Only allow this file to appear in the compiled code
 if we're diagnosting stuff, in-house.
 */
// ---------------------------------------------------------
#ifdef USE_DATA_VERIFICATION_CLIENT
// ---------------------------------------------------------



#import <Foundation/Foundation.h>

/*
 Uploads files and text to a matching
 DataVerificationServer, written in Ruby,
 running on a specific machine.  (We're
 still evolving how to specify the IP
 address.)
 
 For documentation, please see
 https://ymedialabs.atlassian.net/wiki/display/APPLE/How+to+see+the+data+we+send+to+Sage
 */
@interface APCDataVerificationClient : NSObject

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




// ---------------------------------------------------------
#endif  // USE_DATA_VERIFICATION_CLIENT
// ---------------------------------------------------------


