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
                [self.scheduler updateScheduledTasksIfNotUpdatingWithRange:kAPCSchedulerDateRangeToday];
                [self.scheduler updateScheduledTasksIfNotUpdatingWithRange:kAPCSchedulerDateRangeTomorrow];
                if (completionBlock) {
                    completionBlock(error);
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

#warning Ron here.  Is this code correct?  It seems like it would unnecessarily suppress some uploads -- any uploads that start when another upload is in progress.  Maybe it should look like this:

//	if (self.dataSubstrate.currentUser.isConsented)
//	{
//		if (self.batchUploadingInProgress)	// <<<--- here's the change I'm suggesting:  put this in its own "if" statement.
//		{
//			// ...enqueue the new upload
//		}
//		else
//		{
//			// do one upload
//		}
//	}

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
