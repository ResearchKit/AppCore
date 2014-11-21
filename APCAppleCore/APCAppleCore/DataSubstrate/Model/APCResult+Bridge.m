//
//  APCResult+Bridge.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 11/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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
