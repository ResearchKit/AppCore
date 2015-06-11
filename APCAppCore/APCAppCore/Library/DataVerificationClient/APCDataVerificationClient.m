// 
//  APCDataVerificationClient.m 
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
 we're diagnosing stuff, in-house.
 */

// ---------------------------------------------------------
#import "APCDataVerificationServerAccessControl.h"
#ifdef USE_DATA_VERIFICATION_SERVER
// ---------------------------------------------------------



#import "APCDataVerificationClient.h"


/**
 For extracting the MIME type of the file to upload.
 Used in -mimeTypeForPath.
 */
#import <MobileCoreServices/MobileCoreServices.h>


/**
 The user (programmer) will enter this value into
 the Xcode Scheme's environment variables, if desired.
 */
static NSString * const KEY_OF_IP_ADDRESS_IN_USER_VARIABLE = @"DATA_VERIFICATION_SERVER_IP_ADDRESS";

/**
 The script get_debug_ip_address.sh uses this string
 as the key into a dynamically-generated info.plist
 file, which lets us extract it as shown in +initialize,
 below.
 */
static NSString * const KEY_OF_IP_ADDRESS_IN_INFO_PLIST_FILE = @"BUILD_MACHINE_IP_ADDRESS";

/**
 And the winner is...  this variable holds the IP address
 we'll use when trying to talk with the DataVerificationServer:
 user-specified, build-machine, or localhost.  Note that we
 don't need "none" as an option:  if this file compiles at
 all, we'll use localhost, unless one of the others is available.
 */
static NSString * selectedDataVerificationServerIpAddress = nil;
static NSString * selectedDataVerificationServerName = nil;

/*
 Various other variables for this file.
 */
static NSString * const LOCALHOST_IP_ADDRESS = @"127.0.0.1";
static NSInteger  const DATA_VERIFICATION_SERVER_PORT_NUMBER = 4567;
static NSString * const MESSAGE_IF_DATA_IS_EMPTY = @"No data provided.";
static NSString * const DATA_VERIFICATION_SERVER_API_PREFIX = @"api/v1";
static NSString * const DATA_VERIFICATION_SERVER_API_UPLOAD_COMMAND = @"upload";


@implementation APCDataVerificationClient

/**
 By definition, this method is called once per class, in a thread-safe
 way, the first time the class is sent a message -- basically, the first
 time we refer to the class.  That means we can use this to set up stuff
 that applies to all objects (instances) of this class.

 Documentation:  See +initialize in the NSObject Class Reference.  Currently, that's here:
 https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSObject_Class/index.html#//apple_ref/occ/clm/NSObject/initialize
 */
+ (void) initialize
{
	// From the environment variables specified in the Scheme.
	NSProcessInfo *me = NSProcessInfo.processInfo;
	NSDictionary *environmentVariables = me.environment;
	NSString *userSpecifiedIpAddress = environmentVariables [KEY_OF_IP_ADDRESS_IN_USER_VARIABLE];

	userSpecifiedIpAddress = [userSpecifiedIpAddress stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if (userSpecifiedIpAddress.length == 0)
	{
		userSpecifiedIpAddress = nil;
	}


	// Comes from the script get_debug_ip_address.sh.
	NSString *ipAddressOfBuildMachine = [[NSBundle mainBundle] objectForInfoDictionaryKey: KEY_OF_IP_ADDRESS_IN_INFO_PLIST_FILE];

	ipAddressOfBuildMachine = [ipAddressOfBuildMachine stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if (ipAddressOfBuildMachine.length == 0)
	{
		ipAddressOfBuildMachine = nil;
	}


	// And the winner is...
	if (userSpecifiedIpAddress)
	{
		selectedDataVerificationServerIpAddress = userSpecifiedIpAddress;
		selectedDataVerificationServerName = @"user-specified address in the Scheme's environment variables";
	}

	else if (ipAddressOfBuildMachine)
	{
		selectedDataVerificationServerIpAddress = ipAddressOfBuildMachine;
		selectedDataVerificationServerName = @"IP address of the machine where you built the app";
	}

	else
	{
		selectedDataVerificationServerIpAddress = LOCALHOST_IP_ADDRESS;
		selectedDataVerificationServerName = @"'localhost' address; this should work, if the server is running";
	}
}

+ (void)                uploadText: (NSString *) text
	withFakeFilenameForContentType: (NSString *) fakeFilename
{
	NSData *data = [text dataUsingEncoding: NSUTF8StringEncoding];

	[self uploadData: data withFilenameForMimeType: fakeFilename];
}

+ (void) uploadDataFromFileAtPath: (NSString *) path
{
	NSData *data = [NSData dataWithContentsOfFile: path];

    if (path.length == 0)
    {
        NSLog (@"WARNING:  Whoops! Asked to upload data to verification server, but I can't get to the path [%@].", path);
    }
    else if (data == nil)
    {
        NSLog (@"WARNING:  Whoops! Asked to upload data to verification server, but I can't import the stuff at [%@] into an NSData object.", path);
    }
    else
    {
        NSString *filename = path.lastPathComponent;

        [self uploadData: data withFilenameForMimeType: filename];
    }
}

+ (void) uploadData: (NSData *) dataToLog withFilenameForMimeType: (NSString *) filename
{
	NSURL * url = [NSURL URLWithString: [NSString stringWithFormat: @"http://%@:%d/%@/%@/%@",
										 selectedDataVerificationServerIpAddress,
										 (int) DATA_VERIFICATION_SERVER_PORT_NUMBER,
										 DATA_VERIFICATION_SERVER_API_PREFIX,
										 DATA_VERIFICATION_SERVER_API_UPLOAD_COMMAND,
										 filename]];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
	[request setHTTPMethod: @"POST"];
	NSString *boundary = [self boundaryString];
	[request addValue: [NSString stringWithFormat: @"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField: @"Content-Type"];
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration: configuration];

	NSData *data = [self createFormBodyPartWithBoundary: boundary
												   data: dataToLog
											   filename: filename];

	NSLog (@"+[APCDataVerificationClient uploadData:] Attempting to log data to DataVerificationServer at IP address [%@], the [%@]...", selectedDataVerificationServerIpAddress, selectedDataVerificationServerName);

	NSURLSessionUploadTask *task = [session uploadTaskWithRequest: request
														 fromData: data
												completionHandler: ^(NSData * __unused data,
																	 NSURLResponse * __unused response,
																	 NSError *error) {
		if (error)
		{
			NSLog (@"+[APCDataVerificationClient uploadData:] \n"
				   "ERROR when copying Sage data file to the DataVerificationServer at address [%@].  This is the [%@].  Please check:\n"
				   "- Is the local server running?\n"
				   "- Is that a valid address?\n"
				   "- Is your phone on the office network (not 4G)?\n"
				   "The error was:\n-----\n%@\n-----",
				   selectedDataVerificationServerIpAddress,
				   selectedDataVerificationServerName,
				   error);
		}
		else
		{
			NSLog (@"+[APCDataVerificationClient uploadData:] ...done.");
		}
	}];

	[task resume];
}

+ (NSString *) boundaryString
{
	NSUUID *uuid = [NSUUID new];
	return [NSString stringWithFormat: @"Boundary-%@", uuid.UUIDString];
}

/**
 Determine the MIME type for a given file, using MobileCoreServices.framework.

 I.e., this method requires
	#import <MobileCoreServices/MobileCoreServices.h>
 */
+ (NSString *) mimeTypeForPath:(NSString *)path
{
	CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
	CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
	assert(UTI != NULL);

	NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
	assert(mimetype != nil);
	CFRelease(UTI);

	return mimetype;
}

+ (NSData *) createFormBodyPartWithBoundary: (NSString *) boundary
									   data: (NSData *) data
								   filename: (NSString *) filename
{
	NSMutableData *body = [NSMutableData data];


	NSData *dataToLog = data;

	if (dataToLog.length == 0)
	{
		dataToLog = [MESSAGE_IF_DATA_IS_EMPTY dataUsingEncoding: NSUTF8StringEncoding];
	}

	if (dataToLog.length > 0)
	{
		//only send these methods when transferring data as well as username and password
		[body appendData: [[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
		[body appendData: [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filedata\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData: [[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", [self mimeTypeForPath:filename]] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData: dataToLog];
		[body appendData: [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}

	[body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	return body;
}

@end




// ---------------------------------------------------------
#endif  // USE_DATA_VERIFICATION_SERVER
// ---------------------------------------------------------


