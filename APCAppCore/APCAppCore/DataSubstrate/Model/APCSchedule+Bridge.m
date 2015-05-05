// 
//  APCSchedule+Bridge.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCSchedule+Bridge.h"
#import "APCAppDelegate.h"
#import "APCTask.h"
#import "APCLog.h"

#import "NSManagedObject+APCHelper.h"

#import <BridgeSDK/BridgeSDK.h>

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
