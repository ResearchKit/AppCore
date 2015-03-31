// 
//  APCDataVerificationClient.h 
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
 

/*
 Only allow this file to exist in the compiled code if
 we're diagnosting stuff, in-house.  For documentation,
 see:

 https://ymedialabs.atlassian.net/wiki/display/APPLE/How+to+see+the+data+we+send+to+Sage
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


