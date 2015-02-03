//
//  APCUploadValidationServer.m
//  AppCore
//
//  Copyright (c) 2015 Apple Inc. All rights reserved.
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



#import "APCDataVerificationClient.h"


/**
 To use this app with the DataVerificationServer,
 add an entry for your computer to this list of
 IP addresses, and then uncomment it.
 
 You can also use the "localhost" entry.
 */
#import "APCDataVerificationClient_PersonalComputerIPAddresses.h"


/**
 This will probably never change, but, still.
 Don't modify this unless you're also changing
 the matching Ruby code, please.
 */
static NSInteger const DATA_VERIFICATION_SERVER_PORT_NUMBER = 4567;



/**
 For extracting the MIME type of the file to upload.
 Used in -mimeTypeForPath.
 */
#import <MobileCoreServices/MobileCoreServices.h>


static NSString * const MESSAGE_IF_DATA_IS_EMPTY = @"No data provided.";


@implementation APCDataVerificationClient

+ (void)                uploadText: (NSString *) text
	withFakeFilenameForContentType: (NSString *) fakeFilename
{
	NSData *data = [text dataUsingEncoding: NSUTF8StringEncoding];

	[self uploadData: data withFilenameForMimeType: fakeFilename];
}

+ (void) uploadDataFromFileAtPath: (NSString *) path
{
	NSData *data = [NSData dataWithContentsOfFile: path];
	NSString *filename = path.lastPathComponent;

	[self uploadData: data withFilenameForMimeType: filename];
}

+ (void) uploadData: (NSData *) dataToLog withFilenameForMimeType: (NSString *) filename
{
	NSURL * url = [NSURL URLWithString: [NSString stringWithFormat: @"http://%@:%d/api/v1/upload/%@",
										 DATA_VERIFICATION_SERVER_IP_ADDRESS,
										 (int) DATA_VERIFICATION_SERVER_PORT_NUMBER,
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

	NSLog (@"+[APCUploadValiationServer uploadData:] Attempting to log data to DataValidationServer at IP address [%@...]", DATA_VERIFICATION_SERVER_IP_ADDRESS);

	NSURLSessionUploadTask *task = [session uploadTaskWithRequest: request
														 fromData: data
												completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
		if (error)
		{
			NSLog (@"+[APCUploadValiationServer uploadData:] \n"
				   "Error when copying Sage data file to the DataValidationServer.  Please check:\n"
				   "- Is the local server running?\n"
				   "- Is the correct IP address selected in APCDataVerificationClient_PersonalComputerIPAddresses.h ?\n"
				   "- Is your phone on the office network (not 4G)?\n"
				   "The error was:\n-----\n%@\n-----",
				   error);
		}
		else
		{
			NSLog (@"+[APCUploadValiationServer uploadData:] ...done.");
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
#endif  // USE_DATA_VERIFICATION_CLIENT
// ---------------------------------------------------------


