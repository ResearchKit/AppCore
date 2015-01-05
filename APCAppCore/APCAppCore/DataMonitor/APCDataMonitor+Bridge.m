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
                [APCTask refreshSurveys];
                BOOL refreshToday = ![[NSUserDefaults standardUserDefaults] boolForKey:kFirstTimeRefreshToday];
                if (refreshToday) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstTimeRefreshToday];
                    [self.scheduler updateScheduledTasksIfNotUpdating:YES OnCompletion:^(NSError * error) {
                        [self.scheduler updateScheduledTasksIfNotUpdating:NO OnCompletion:^(NSError * error) {
                            if (completionBlock) {
                                completionBlock(error);
                            }
                        }];
                    }];
                }
                else
                {
                    [self.scheduler updateScheduledTasksIfNotUpdating:NO OnCompletion:^(NSError * error) {
                        if (completionBlock) {
                            completionBlock(error);
                        }
                    }];
                }
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




@end
