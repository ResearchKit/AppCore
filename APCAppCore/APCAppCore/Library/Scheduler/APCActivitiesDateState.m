//
//  APCActivitiesDateState.m
//  APCAppCore
//
//  Copyright (c) 2015, Apple Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  1.  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  2.  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation and/or
//  other materials provided with the distribution.
//
//  3.  Neither the name of the copyright holder(s) nor the names of any contributors
//  may be used to endorse or promote products derived from this software without
//  specific prior written permission. No license is granted to the trademarks of
//  the copyright holders even if such marks are included in this software.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "APCActivitiesDateState.h"
#import "APCTopLevelScheduleEnumerator.h"
#import "APCScheduler.h"
#import <NSDate+Helper.h>
#import "APCSchedule+AddOn.h"
#import "APCAppDelegate.h"
#import "APCTask.h"
#import "APCScheduledTask.h"
#import "APCLog.h"
#import "NSManagedObject+APCHelper.h"

@implementation APCActivitiesDateState

-(NSDictionary *)activitiesStateForDate:(NSDate *)date
{
    
    NSMutableDictionary *activitiesState = [NSMutableDictionary new];
    
    //incomplete Activity State
    for (APCSchedule *schedule in [self activitiesSchedulesForDate:date])
    {
        NSArray *scheduledTimes = [self scheduledTimesForSchedule:schedule forDate:date];
        
        NSMutableDictionary *times = [NSMutableDictionary new];
        for (NSDate *date in scheduledTimes) {
            APCLogDebug(@"scheduled time for task: %@ is %@", [(APCTask *)schedule.tasks.anyObject taskID], date);
            [times setObject:[NSNumber numberWithBool:NO] forKey:date];
        }
        [activitiesState setValue:times forKey:[(APCTask *)schedule.tasks.anyObject taskID]];
    }

    //Complete Activity State. Update the completed boolean on the dictionary
    NSArray *completedTasks = [self completedScheduledTasksForDate:date];
    for (APCScheduledTask *scheduledTask in completedTasks) {
        APCLogDebug(@"scheduled time for task: %@ is %@ and completed = %@", scheduledTask.task.taskID, date, scheduledTask.completed);
        //get the existing time object for task
        
        NSMutableDictionary *taskTimes = [activitiesState objectForKey:scheduledTask.task.taskID] ?: [NSMutableDictionary new];
        if ([taskTimes objectForKey:scheduledTask.startOn]) {
            [taskTimes setObject:@YES forKey:scheduledTask.startOn];
        }
        
        [activitiesState setValue:taskTimes forKey:scheduledTask.task.taskID];
    }
    
    return activitiesState;
}

- (NSArray *)scheduledTimesForSchedule:(APCSchedule *)schedule forDate:(NSDate *)date
{

    APCTopLevelScheduleEnumerator *enumerator = [schedule enumeratorFromDate: date.startOfDay
                                                                  toDate: date.endOfDay];
    
    NSMutableArray *appearanceDates = [NSMutableArray new];
    
    for (NSDate *nextAppearance in enumerator)
    {
        if ([nextAppearance isLaterThanOrEqualToDate: schedule.effectiveStartDate.startOfDay]
            && [nextAppearance isEarlierOrEqualToDate: schedule.effectiveEndDate.endOfDay])
        {
            [appearanceDates addObject: nextAppearance];
        }
    }

    return appearanceDates;
}

- (NSArray *)activitiesSchedulesForDate: (NSDate *)date
{
    /*
    get ALL of the schedules active on the date
    endDate >= date.endOfDay //this value will often be null - need to programatically check results
    effectiveEndDate >= date.endOfDay //this value will often be null - need to programatically check results
    effectiveStartDate <= date
    startsOn <= date
     */
    
    NSArray *dailySchedules = nil;
    NSFetchRequest *request = [APCSchedule request];
    NSDate *startDate = date.startOfDay;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(%K >= %@ OR %K == null) AND %K <= %@ AND %K <= %@",
                              NSStringFromSelector (@selector (effectiveEndDate)), date.endOfDay,
                              NSStringFromSelector (@selector (effectiveEndDate)),
                              NSStringFromSelector (@selector (effectiveStartDate)), startDate,
                              NSStringFromSelector (@selector (startsOn)), startDate
                              ];
    
    request.predicate = predicate;
    NSError *error = nil;
    dailySchedules = [[APCAppDelegate sharedAppDelegate].dataSubstrate.mainContext executeFetchRequest:request error:&error];
    
    return dailySchedules;
}

- (NSArray *)completedScheduledTasksForDate: (NSDate *)date
{
    NSFetchRequest *request = [APCScheduledTask request];
    request.predicate = [NSPredicate predicateWithFormat:@"%K >= %@ AND %K <= %@ AND %K == %@",
                         NSStringFromSelector (@selector (startOn)),
                         date.startOfDay,
                         NSStringFromSelector (@selector (startOn)),
                         date.endOfDay,
                         NSStringFromSelector (@selector (completed)),
                         @YES];
 
    NSError *error = nil;
    NSArray *dailyScheduledTasks = [[APCAppDelegate sharedAppDelegate].dataSubstrate.mainContext executeFetchRequest:request error:&error];
    
    return dailyScheduledTasks;
}

@end
