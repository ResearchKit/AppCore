//
//  APCCompletedOneTimeTaskFilter.m
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

#import "APCCompletedOneTimeTaskFilter.h"
#import "APCSchedule+AddOn.h"
#import "APCScheduleTaskMap.h"
#import "APCScheduleTaskMapEntry.h"
#import "APCScheduledTask.h"
#import "APCTask.h"
#import "NSArray+APCHelper.h"


@interface APCCompletedOneTimeTaskFilter ()
@property (nonatomic, strong) NSSet *schedulesWithCompletedOneTimeTasks;
@property (nonatomic, strong) NSSet *schedulesWithoutCompletedOneTimeTasks;
@end


@implementation APCCompletedOneTimeTaskFilter

- (instancetype) init
{
    self = [super init];

    if (self)
    {
        _schedulesWithCompletedOneTimeTasks = nil;
        _schedulesWithoutCompletedOneTimeTasks = nil;
    }

    return self;
}

- (NSSet *) passed
{
    return self.schedulesWithCompletedOneTimeTasks;
}

- (NSSet *) failed
{
    return self.schedulesWithoutCompletedOneTimeTasks;
}

- (void) split: (NSSet *) setOfSchedules
       withMap: (APCScheduleTaskMap *) mapOfTheseTaskIdsToSavedTasksAndMostRecentSchedules
{
    NSMutableSet *schedulesWithCompletedOneTimeTasks    = [NSMutableSet new];
    NSMutableSet *schedulesWithoutCompletedOneTimeTasks = [NSMutableSet new];

    for (APCSchedule *schedule in setOfSchedules)
    {
        BOOL atLeastOneTaskIsACompletedOneTimeTask = NO;

        for (APCTask *task in schedule.tasks)
        {
            APCScheduleTaskMapEntry *entry = [mapOfTheseTaskIdsToSavedTasksAndMostRecentSchedules entryForTaskId: task.taskID];

            if (entry == nil)
            {
                // No problem.
            }
            else
            {
                BOOL thisEntryRepresentsACompletedOneTimeTask = [self analyzeEntryForCompletedOneTimeTask: entry];

                if (thisEntryRepresentsACompletedOneTimeTask)
                {
                    atLeastOneTaskIsACompletedOneTimeTask = YES;
                    break;
                }
            }
        }

        if (atLeastOneTaskIsACompletedOneTimeTask)
        {
            [schedulesWithCompletedOneTimeTasks addObject: schedule];
        }
        else
        {
            [schedulesWithoutCompletedOneTimeTasks addObject: schedule];
        }
    }

    self.schedulesWithCompletedOneTimeTasks    = [NSSet setWithSet: schedulesWithCompletedOneTimeTasks];
    self.schedulesWithoutCompletedOneTimeTasks = [NSSet setWithSet: schedulesWithoutCompletedOneTimeTasks];
}

- (BOOL) analyzeEntryForCompletedOneTimeTask: (APCScheduleTaskMapEntry *) entry
{
    BOOL isCompletedOneTimeTask = NO;

    if (! entry.schedule.isOneTimeSchedule)
    {
        // It's not a one-time schedule, so don't worry about it.
    }
    else
    {
        /*
         The "scheduled tasks" are the user's data records for a given task:
         a task that was scheduled on (and usually completed on) a particular
         date.
         */
        for (APCScheduledTask *maybeCompletedTask in entry.task.scheduledTasks)
        {
            if (maybeCompletedTask.generatedSchedule == entry.schedule)
            {
                if (maybeCompletedTask.completed.boolValue)
                {
                    isCompletedOneTimeTask = YES;
                }
                else
                {
                    // One-time task, yes.  Completed, no.  No problem.
                }

                break;
            }
            else
            {
                // We don't care about old schedules, and we know we only received
                // a list of the most recent schedules.  Look at the next scheduledTask.
            }
        }
    }

    return isCompletedOneTimeTask;
}

@end
