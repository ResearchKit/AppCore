// 
//  APCResult+Bridge.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCResult+Bridge.h"

@implementation APCResult (Bridge)

- (BOOL) serverDisabled
{
#if DEVELOPMENT
    return YES;
#else
    return ((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.parameters.bypassServer;
#endif
}

- (void) uploadToBridgeOnCompletion: (void (^)(NSError * error)) completionBlock
{
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        [SBBComponent(SBBUploadManager) uploadFileToBridge:self.archiveURL contentType:@"application/zip" completion:^(NSError *error) {
            self.uploaded = @(YES);
            NSError * saveError;
            [self saveToPersistentStore:&saveError];
            [saveError handle];
            if (completionBlock) {
                completionBlock(error);
            }
        }];
    }
}

- (NSURL *)archiveURL
{
    NSString * filePath = [[[self applicationsDirectory] stringByAppendingPathComponent:self.taskRunID] stringByAppendingPathComponent:self.archiveFilename];
    return [NSURL fileURLWithPath:filePath];
}

- (NSString*) applicationsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

@end
