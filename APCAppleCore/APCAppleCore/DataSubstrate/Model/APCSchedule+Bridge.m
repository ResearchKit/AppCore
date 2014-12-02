//
//  APCSchedule+Bridge.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 11/21/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSchedule+Bridge.h"
#import "SBBSchedule+APCAdditions.h"

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
            [error handle];
            if (!error) {
                SBBResourceList *list = (SBBResourceList *)schedulesList;
                NSArray * schedules = list.items;
                NSManagedObjectContext * context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                context.parentContext = ((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.persistentContext;
                [self clearAllRemoteUpdatableSchedules:context];
                [context performBlockAndWait:^{
                    [schedules enumerateObjectsUsingBlock:^(SBBSchedule* schedule, NSUInteger idx, BOOL *stop) {
                        APCSchedule * apcSchedule = [APCSchedule newObjectForContext:context];
                        [self mapSBBSchedule:schedule APCSchedule:apcSchedule];
                        NSError * error;
                        [apcSchedule saveToPersistentStore:&error];
                        [error handle];
                    }];
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) {
                        completionBlock(error);
                    }
                });
            }
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
        [error handle];
        APCSchedule * handle = [mutableArray lastObject];
        while (mutableArray.count) {
            APCSchedule * schedule = [mutableArray lastObject];
            [mutableArray removeLastObject];
            [context deleteObject:schedule];
        }
        [handle saveToPersistentStore:&error];
        [error handle];
    }];
}

+ (void) mapSBBSchedule:(SBBSchedule*) sbbSchedule APCSchedule: (APCSchedule*) apcSchedule
{
    apcSchedule.remoteUpdatable = @(YES);
    apcSchedule.scheduleType = sbbSchedule.scheduleType;
#warning Temporary Kludge
    apcSchedule.scheduleString = sbbSchedule.cronTrigger ? @"0 5 * * *" : nil;
    apcSchedule.expires = sbbSchedule.expires;
    apcSchedule.startsOn = sbbSchedule.startsOn;
    apcSchedule.endsOn = sbbSchedule.endsOn;
    apcSchedule.reminderMessage = sbbSchedule.label;
    
    //APCTask 
    if ([sbbSchedule.activityType isEqualToString:@"survey"]) {
        APCTask * task = [APCTask taskWithTaskID:sbbSchedule.taskID inContext:apcSchedule.managedObjectContext];
        if (!task) {
            task = [APCTask newObjectForContext:apcSchedule.managedObjectContext];
            task.taskID = sbbSchedule.taskID;
            task.taskHRef = sbbSchedule.activityRef;
            task.taskClassName = kSurveyTaskViewController;
        }
        apcSchedule.taskID = sbbSchedule.taskID;
    }
    else
    {
        APCTask * task = [APCTask taskWithTaskID:sbbSchedule.taskID inContext:apcSchedule.managedObjectContext];
        NSAssert(task, @"Task not found!");
        apcSchedule.taskID = sbbSchedule.taskID;
    }

}
@end
