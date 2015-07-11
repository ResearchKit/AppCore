// 
//  APCDataArchive.h 
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

/**
 APCDataArchive is provided as a wrapper class for your favorite compression API.
 
 This functional cohesion of APCDataArchiver, APCDataEncryptor, and APCDataUploader enables
 procedural cohesion where json data can be encrypted by APCDataEncryptor before inserting into
 an APCArchive. APCDataArchiveUploader can then be used to upload the archive.
 
 The initializer returns an instance of the archive stored in the temporary directory in a
 working directory folder with the name passed in the reference argument. This working directory is protected at the
 level of NSFileProtectionComplete.
 
 This directory will be deleted when the cleanWorkingDirectory method is called.
 */

#import <Foundation/Foundation.h>

@class ORKTaskResult;

@interface APCDataArchive : NSObject

@property (strong, nonatomic) NSURL *unencryptedURL;

/**
 Designated Initializer
 
 @param     reference           Reference for the archive used as a directory name in temp directory
 
 @return    APCDataArchive      An instance of APCDataArchive
 */
- (id)initWithReference: (NSString *)reference;

/**
 Inserts json data into the archive.
 
 @param     jsonData            JSON data to be inserted into the zip archive.
 
 @param     filename            Filename for the JSON to be included without path extension
 */
- (void)insertJSONDataIntoArchive:(NSData *)jsonData filename:(NSString *)filename;

/**
 Converts a dictionary into json data and inserts into the archive.
 
 @param     dictionary              Dictionary to be inserted into the zip archive.
 
 @param     filename                Filename for the json data to be included without path extension
 */
- (void)insertIntoArchive:(NSDictionary *)dictionary filename: (NSString *)filename;

/**
 Inserts the data from the file at the url.
 
 @param     url                     URL where the file exists
 
 @param     filename                Filename for the json data to be included without path extension (path extension will be preserved from the url).
 */
- (void)insertDataAtURLIntoArchive: (NSURL*) url fileName: (NSString *) filename extension:(NSString *)extension;

/**
 Inserts the data with the filename and path extension
 
 @param     url                     URL where the file exists
 
 @param     filename                Filename for the data to be included without path extension (path extension will be preserved from the url)
 
 @param     extension               File extension
 */
- (void)insertDataIntoArchive :(NSData *)data filename: (NSString *)filename extension: (NSString *)extension;

/**
 Inserts an info.json file into the archive.
 
 @param     errorHandler            Called to pass in the error. Take action based on the error.
 */
- (void)completeArchiveWithErrorHandler: (void(^)(NSError *error))errorHandler;

/**
 Guarantees to delete the archive and its working directory container.
 Call this method when you are finished with the archive, for example after encrypting or uploading.
 */
- (void) removeArchive;

/**
 Utility method to indicate whether this class can handle the file extension when inserting into an archive and deriving Content Type.
 
 @param     extension               NSString extension to inspect
 */
+ (BOOL) isKnownFileExtension: (NSString *)extension;

/**
 Utility method to get a filename from an NSURL by inspecting the last path component.
 If the URL contains a known path extension internal to ResearchKit such as ".outbound" or ".rest", the filename is reformed without the internal extension by replacing the dot (.) with an underscore (_).
 Otherwise, the filename is stripped of the path extension and returned.
 
 @param     url                     URL from which to derive the filename
 @return    NSString                the filename without path extension
 */
+ (NSString *)filenameFromURL: (NSURL *)url;

@end
