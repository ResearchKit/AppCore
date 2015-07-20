//
//  APCScheduleTaskMap.m
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

#import "APCScheduleTaskMap.h"
#import "APCSchedule.h"
#import "APCScheduleTaskMapEntry.h"
#import "APCTask.h"


@interface APCScheduleTaskMap ()
@property (nonatomic, strong) NSMutableDictionary *internalDictionary;
@end


@implementation APCScheduleTaskMap

- (instancetype) init
{
    self = [super init];

    if (self)
    {
        _internalDictionary = [NSMutableDictionary new];
    }

    return self;
}

- (instancetype) initWithSetOfSchedules: (NSSet *) schedules
{
    self = [self init];

    if (self)
    {

        for (APCSchedule *schedule in schedules)
        {
            for (APCTask *task in schedule.tasks)
            {
                if (task.taskID.length)
                {
                    APCScheduleTaskMapEntry *entry = [[APCScheduleTaskMapEntry alloc] initWithTaskId: task.taskID
                                                                                                task: task
                                                                                            schedule: schedule];
                    _internalDictionary [task.taskID] = entry;
                }
            }
        }
    }

    return self;
}

- (BOOL) containsTaskId: (NSString *) taskId
{
    BOOL result = [self.internalDictionary.allKeys containsObject: taskId];
    
    return result;
}

- (APCScheduleTaskMapEntry *) entryForTaskId: (NSString *) taskId
{
    APCScheduleTaskMapEntry *entry = nil;

    if (taskId.length)
    {
        entry = self.internalDictionary [taskId];
    }

    return entry;
}

- (void) setEntry: (APCScheduleTaskMapEntry *) entry
        forTaskId: (NSString *) taskId
{
    if (taskId.length == 0)
    {
        // Not supported.  For now, ignore.
    }

    else if (entry == nil)
    {
        // Not supported.  For now, ignore.
    }

    else
    {
        self.internalDictionary [taskId] = entry;
    }
}

- (APCSchedule *) scheduleForTaskId: (NSString *) taskId
{
    APCScheduleTaskMapEntry *entry = [self entryForTaskId: taskId];
    APCSchedule *result = entry.schedule;
    return result;
}

- (APCTask *) taskForTaskId: (NSString *) taskId
{
    APCScheduleTaskMapEntry *entry = [self entryForTaskId: taskId];
    APCTask *result = entry.task;
    return result;
}

- (NSUInteger) count
{
    return self.internalDictionary.count;
}

@end
