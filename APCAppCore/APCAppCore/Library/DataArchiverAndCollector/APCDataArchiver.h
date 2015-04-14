// 
//  APCDataArchiver.h 
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
 
#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>

@class ORKTaskResult;

@interface APCDataArchiver : NSObject

- (instancetype) initWithTaskResult: (ORKTaskResult*) taskResult;
- (instancetype)initWithResults: (NSArray*) results itemIdentifier: (NSString*) itemIdentifier runUUID: (NSUUID*) runUUID;
- (NSString*) writeToOutputDirectory: (NSString*) outputDirectory;

+ (BOOL) encryptZipFile: (NSString*) unencryptedPath encryptedPath:(NSString*) encryptedPath;


/**
 Converts the specified object to data we can serialize into
 JSON.  Sometimes, uses verrrrry specific rules to do this
 conversion.  Some examples of this oddness:
 -  we convert the key "identifier" in a top-level dictionary
    to the word "item"
 -  we attempt to convert strings into integers and Booleans
 -  we stringify dates to ISO-8601 format
 -  we return nil for NSCalendars, intended to mean "please
    don't serialize this object," because we include the
    time zone in the NSDate conversions (above)
 -  Arrays and dictionaries will always be converted to
    arrays and dictionaries, even if they end up having
    no contents (evolving)
 
 This method is recursive.  If it encounters an array or
 dictionary, it'll call the same conversion routines on that
 object and its contents.
 */
- (NSDictionary *) generateSerializableDataFromSourceDictionary: (NSDictionary *) sourceDictionary;


/*
 Make sure crackers (Bad Guys) don't know these features
 exist, and (also) cannot use them, even by accident.
 */
#ifdef USE_DATA_VERIFICATION_CLIENT

	/**
	 Should we save the unencrypted .zip file?  Specifically
	 so we can retrieve it with -unencryptedFilePath?
	 */
	@property (nonatomic) BOOL preserveUnencryptedFile;

	/**
	 The path where the unencrypted .zip file was generated.
	 If you set -preserveUnencryptedFile to YES, the file will
	 exist at this path after the -init process has finished
	 creating the .zip file.
	 */
	@property (nonatomic, strong) NSString *unencryptedFilePath;

#endif


@end
