//
//  SBBUploadManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 10/9/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeAPIManager.h"

typedef void (^SBBUploadManagerCompletionBlock)(NSError *error);

/*!
 *  This protocol defines the interface to the SBBUploadManager's non-constructor, non-initializer methods. The interface is
 *  abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBUploadManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 Upload a file to the Bridge server on behalf of the authenticated user, via the NSURLSessionUploadTask so it can proceed
 even if the app is suspended or killed.
 
 @param fileUrl     The file to upload.
 @param contentType The MIME type of the file (defaults to "application/octet-stream" if nil).
 @param completion  A completion block to be called when the upload finishes (or fails).
 */
- (void)uploadFileToBridge:(NSURL *)fileUrl contentType:(NSString *)contentType completion:(SBBUploadManagerCompletionBlock)completion;

@end

/*!
 *  This class handles communication with the Bridge file upload API.
 */
@interface SBBUploadManager : SBBBridgeAPIManager<SBBComponent, SBBUploadManagerProtocol>

@end
