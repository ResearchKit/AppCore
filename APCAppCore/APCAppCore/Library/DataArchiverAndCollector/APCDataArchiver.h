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

@property (nonatomic) BOOL preserveUnencryptedFile;

- (NSString*) writeToOutputDirectory: (NSString*) outputDirectory;

RK_EXTERN NSData *RKSTCryptographicMessageSyntaxEnvelopedData(NSData *data, NSData *identity, RKEncryptionAlgorithm algorithm, NSError * __autoreleasing *error) RKST_AVAILABLE_IOS(8_3);

@end
