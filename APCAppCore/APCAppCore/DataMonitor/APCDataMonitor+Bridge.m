// 
//  APCDataMonitor+Bridge.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCDataMonitor+Bridge.h"
#import "APCSchedule+Bridge.h"
#import "APCAppCore.h"

NSString *const kFirstTimeRefreshToday = @"FirstTimeRefreshToday";

@implementation APCDataMonitor (Bridge)

- (void) refreshFromBridgeOnCompletion: (void (^)(NSError * error)) completionBlock
{
    if (self.dataSubstrate.currentUser.isConsented) {
        [APCSchedule updateSchedulesOnCompletion:^(NSError *error) {
            if (!error) {
                [self.scheduler updateScheduledTasksIfNotUpdatingWithRange:kAPCSchedulerDateRangeToday];
                [self.scheduler updateScheduledTasksIfNotUpdatingWithRange:kAPCSchedulerDateRangeTomorrow];
                [APCTask refreshSurveysOnCompletion:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:APCUpdateActivityNotification object:self userInfo:NULL];
                    });
                    if (completionBlock) {
                        completionBlock(error);
                    }
                }];

            }
            else {
                if (completionBlock) {
                    completionBlock(error);
                }
            }
        }];
    }
}

- (void) batchUploadDataToBridgeOnCompletion: (void (^)(NSError * error)) completionBlock
{
    if (self.dataSubstrate.currentUser.isConsented && !self.batchUploadingInProgress) {
        self.batchUploadingInProgress = YES;
        NSManagedObjectContext * context = self.dataSubstrate.persistentContext;
        [context performBlock:^{
            NSFetchRequest * request = [APCResult request];
            request.predicate = [NSPredicate predicateWithFormat:@"uploaded == nil || uploaded == %@", @(NO)];
            NSError * error;
            NSArray * unUploadedResults = [context executeFetchRequest:request error:&error];
            for (APCResult * result in unUploadedResults) {
                [result uploadToBridgeOnCompletion:^(NSError *error) {
                    APCLogError2 (error);
                }];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.batchUploadingInProgress = NO;
                if (completionBlock) {
                    completionBlock(error);
                }
            });
        }];
    }
}

- (void) uploadZipFile:(NSString*) path onCompletion: (void (^)(NSError * error)) completionBlock
{
    NSParameterAssert(path);
    [SBBComponent(SBBUploadManager) uploadFileToBridge:[NSURL fileURLWithPath:path] contentType:@"application/zip" completion:^(NSError *error) {
        if (!error) {
            APCLogEventWithData(kNetworkEvent, (@{@"event_detail":[NSString stringWithFormat:@"Uploaded Passive Collector File: %@", path.lastPathComponent]}));
        }
        if (completionBlock) {
            completionBlock(error);
        }
    }];
    
}

@end
