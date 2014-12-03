//
//  APCDataMonitor+Bridge.m
//  APCAppCore
//
//  Created by Dhanush Balachandran on 12/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDataMonitor+Bridge.h"
#import "APCSchedule+Bridge.h"
#import "APCAppCore.h"

@implementation APCDataMonitor (Bridge)

- (void) refreshFromBridgeOnCompletion: (void (^)(NSError * error)) completionBlock
{
    if (self.dataSubstrate.currentUser.isConsented) {
        [APCSchedule updateSchedulesOnCompletion:^(NSError *error) {
            [APCTask refreshSurveys];
            [self.scheduler updateScheduledTasksIfNotUpdating:NO OnCompletion:^(NSError * error) {
                if (completionBlock) {
                    completionBlock(error);
                }
            }];
        }];
    }
}

- (void) batchUploadDataToBridgeOnCompletion: (void (^)(NSError * error)) completionBlock
{
    if (self.dataSubstrate.currentUser.isConsented) {
        NSManagedObjectContext * context = self.dataSubstrate.persistentContext;
        [context performBlock:^{
            NSFetchRequest * request = [APCResult request];
            request.predicate = [NSPredicate predicateWithFormat:@"uploaded == nil || uploaded == %@", @(NO)];
            NSError * error;
            NSArray * unUploadedResults = [context executeFetchRequest:request error:&error];
            for (APCResult * result in unUploadedResults) {
                [result uploadToBridgeOnCompletion:^(NSError *error) {
                    [error handle];
                }];
            }
        }];
    }
}


@end
