// 
//  APCResult+Bridge.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
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
        if (self.archiveFilename.length > 0) {
            [SBBComponent(SBBUploadManager) uploadFileToBridge:self.archiveURL contentType:@"application/zip" completion:^(NSError *error) {
                
                if (error) {
                    APCLogError2(error);
                } else {
                    APCLogEventWithData(kNetworkEvent, (@{@"event_detail":[NSString stringWithFormat:@"Uploaded Task: %@    RunID: %@", self.taskID, self.taskRunID]}));
                    
                    self.uploaded = @(YES);
                    NSError * saveError;
                    [self saveToPersistentStore:&saveError];
                    
                    //Delete archiveURLs
                    NSString * path = [[self.archiveURL path] stringByDeletingLastPathComponent];
                    NSError * deleteError;
                    if (![[NSFileManager defaultManager] removeItemAtPath:path error:&deleteError]) {
                        APCLogError2(deleteError);
                    }
                    APCLogError2 (saveError);
                }
                
                if (completionBlock) {
                    completionBlock(error);
                }
            }];
        }
        else
        {
            if (completionBlock) {
                completionBlock(nil);
            }
        }

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
