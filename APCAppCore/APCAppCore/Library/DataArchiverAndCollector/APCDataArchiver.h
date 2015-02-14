//
//  APCDataArchiver.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>

@class RKSTTaskResult;

@interface APCDataArchiver : NSObject

- (instancetype) initWithTaskResult: (RKSTTaskResult*) taskResult;
- (instancetype)initWithResults: (NSArray*) results itemIdentifier: (NSString*) itemIdentifier runUUID: (NSUUID*) runUUID;
- (NSString*) writeToOutputDirectory: (NSString*) outputDirectory;

+ (void) encryptZipFile: (NSString*) unencryptedPath encryptedPath:(NSString*) encryptedPath;

RK_EXTERN NSData *RKSTCryptographicMessageSyntaxEnvelopedData(NSData *data, NSData *identity, RKEncryptionAlgorithm algorithm, NSError * __autoreleasing *error) RKST_AVAILABLE_IOS(8_3);


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
