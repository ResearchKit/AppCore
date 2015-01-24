//
//  APCDataArchiver.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKSTTaskResult;

@interface APCDataArchiver : NSObject

- (instancetype) initWithTaskResult: (RKSTTaskResult*) taskResult;
- (instancetype)initWithResults: (NSArray*) results itemIdentifier: (NSString*) itemIdentifier runUUID: (NSUUID*) runUUID;

@property (nonatomic) BOOL preserveUnencryptedFile;

- (void) writeToOutputDirectory: (NSString*) outputDirectory;


@end
