//
//  APCUploadValidationServer.m
//  AppCore
//
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//

#import "APCUploadValidationServer.h"

/**
 For extracting the MIME type of the file to upload.
 Used in -mimeTypeForPath.
 */
#import <MobileCoreServices/MobileCoreServices.h>


/**
 If this is non-nil, we'll use it.
 Otherwise, we'll use YES if in debug mode,
 NO if in production.  See +isLoggingOn.
 */
static NSNumber *shouldLog = nil;
static NSString * const MESSAGE_IF_DATA_IS_EMPTY = @"No data provided.";


@implementation APCUploadValidationServer

+ (void) setupTurningLoggingOn: (BOOL) shouldTurnLoggingOn
{
	shouldLog = @(shouldTurnLoggingOn);
}

+ (BOOL) isLoggingOn
{
	BOOL result = NO;

	if (shouldLog != nil)
	{
		result = shouldLog.boolValue;
	}

	else
	{
		/*
		 Uncomment this if appropriate.

		 If this is commented out, and no one calls
		 +[self setupTurningLoggingOn: YES], then
		 this logging server code will not run.
		 */

//		#if DEBUG
//		{
//			result = YES;
//		}
//		#endif
	}

	return result;
}

+ (void) logText: (NSString *) text
withFakeFilename: (NSString *) fakeFilename
{
	NSData *data = [text dataUsingEncoding: NSUTF8StringEncoding];

	[self uploadData: data withFilenameForMimeType: fakeFilename];
}

+ (void) logDataFromFileAtPath: (NSString *) path
{
	NSData *data = [NSData dataWithContentsOfFile: path];
	NSString *filename = path.lastPathComponent;

	[self uploadData: data withFilenameForMimeType: filename];
}

/*
 The stuff below is the "original" stuff,
 from a commit of APCDataSubstrate+ResearchKit.m ,
 dated 2014-Dec-03.
 */

+ (void) uploadData: (NSData *) dataToLog withFilenameForMimeType: (NSString *) filename
{
	if (self.isLoggingOn)
	{
		NSURL * url = [NSURL URLWithString: [NSString stringWithFormat: @"http://127.0.0.1:4567/api/v1/upload/%@", filename]];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
		[request setHTTPMethod: @"POST"];
		NSString *boundary = [self boundaryString];
		[request addValue: [NSString stringWithFormat: @"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField: @"Content-Type"];
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		NSURLSession *session = [NSURLSession sessionWithConfiguration: configuration];

		NSData *data = [self createFormBodyPartWithBoundary: boundary
													   data: dataToLog
												   filename: filename];

		NSURLSessionUploadTask *task = [session uploadTaskWithRequest: request
															 fromData: data
													completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
			if (error) {
				NSLog(@"+[APCUploadValiationServer uploadData:] Error when copying Sage data file to local validation server. Is the local server running? The error was:\n-----\n%@\n-----", error);
			}
		}];

		[task resume];
	}
}

+ (NSString *) boundaryString
{
	// generate boundary string
	//
	// adapted from http://developer.apple.com/library/ios/#samplecode/SimpleURLConnections

	/*
	 Original version:

		 CFUUIDRef  uuid;
		 NSString  *uuidStr;

		 uuid = CFUUIDCreate(NULL);
		 assert(uuid != NULL);

		 uuidStr = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
		 assert(uuidStr != NULL);

		 CFRelease(uuid);
	 
	 I'm leaving that here because I don't know if NSUUID
	 reliably does the same thing.  The documentation suggests
	 that, maybe, it doesn't.
	 */

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







