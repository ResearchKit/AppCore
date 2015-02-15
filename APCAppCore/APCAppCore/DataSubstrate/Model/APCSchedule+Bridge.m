// 
//  APCSchedule+Bridge.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCSchedule+Bridge.h"

NSString *const kSurveyTaskViewController = @"APCGenericSurveyTaskViewController";

@implementation APCSchedule (Bridge)

+ (BOOL) serverDisabled
{
#if DEVELOPMENT
    return YES;
#else
    return ((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.parameters.bypassServer;
#endif
}

+ (void) updateSchedulesOnCompletion: (void (^)(NSError * error)) completionBlock
{
    if (![self serverDisabled]) {
        [SBBComponent(SBBScheduleManager) getSchedulesWithCompletion:^(id schedulesList, NSError *error) {
            APCLogError2 (error);
            if (!error) {
                SBBResourceList *list = (SBBResourceList *)schedulesList;
                NSArray * schedules = list.items;
                NSManagedObjectContext * context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                context.parentContext = ((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.persistentContext;
                [self clearAllRemoteUpdatableSchedules:context];
                [context performBlockAndWait:^{
                    [schedules enumerateObjectsUsingBlock:^(SBBSchedule* schedule, NSUInteger  __unused idx, BOOL * __unused stop) {
                        APCSchedule * apcSchedule = [APCSchedule newObjectForContext:context];
                        [self mapSBBSchedule:schedule APCSchedule:apcSchedule];
                        NSError * error;
                        [apcSchedule saveToPersistentStore:&error];
                        APCLogError2 (error);
                    }];
                }];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    APCLogEventWithData(kNetworkEvent, @{@"event_detail":@"schedule updated"});
                }
                if (completionBlock) {
                    completionBlock(error);
                }
            });
        }];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
    }
}

+ (void) clearAllRemoteUpdatableSchedules: (NSManagedObjectContext*) context
{
    [context performBlockAndWait:^{
        NSFetchRequest * request = [APCSchedule request];
        request.predicate = [NSPredicate predicateWithFormat:@"remoteUpdatable == %@", @(YES)];
        NSError * error;
        NSMutableArray * mutableArray = [[context executeFetchRequest:request error:&error] mutableCopy];
        APCLogError2 (error);
        APCSchedule * handle = [mutableArray lastObject];
        while (mutableArray.count) {
            APCSchedule * schedule = [mutableArray lastObject];
            [mutableArray removeLastObject];
            [context deleteObject:schedule];
        }
        [handle saveToPersistentStore:&error];
        APCLogError2 (error);
    }];
}

+ (void) mapSBBSchedule:(SBBSchedule*) sbbSchedule APCSchedule: (APCSchedule*) apcSchedule
{
    apcSchedule.remoteUpdatable = @(YES);
    apcSchedule.scheduleType = sbbSchedule.scheduleType;
    apcSchedule.scheduleString = sbbSchedule.cronTrigger;
    apcSchedule.expires = sbbSchedule.expires;
    apcSchedule.startsOn = sbbSchedule.startsOn;
    apcSchedule.endsOn = sbbSchedule.endsOn;
    apcSchedule.reminderMessage = sbbSchedule.label;
    
    SBBActivity * activity = [sbbSchedule.activities firstObject];
    if(activity != nil) {
        //APCTask
        if ([activity.activityType isEqualToString:@"survey"]) {
            APCTask * task = [APCTask taskWithTaskID:activity.survey.uniqueID inContext:apcSchedule.managedObjectContext];
            if (!task) {
                task = [APCTask newObjectForContext:apcSchedule.managedObjectContext];
                task.taskID = activity.survey.uniqueID;
                task.taskHRef = activity.ref;
                task.taskClassName = kSurveyTaskViewController;
            }
            apcSchedule.taskID = activity.survey.uniqueID;
        }
        else
        {
            APCLogError(@"Unknown Activity Type: %@", activity.activityType);
        }
    }


}
@end
