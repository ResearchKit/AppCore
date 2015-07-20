//
//  APCUniqueTaskIdFilter.m
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

#import "APCUniqueTaskIdFilter.h"
#import "APCSchedule.h"
#import "APCTask.h"
#import "NSArray+APCHelper.h"

/**
 If we import multiple tasks with an ID of "null," this
 value will appear in the list of duplicate IDs.
 */
static NSString * const kAPCNullTaskIdString = @"(this task ID was null)";


@interface APCUniqueTaskIdFilter ()
@property (nonatomic, strong) NSSet *schedulesWithUniqueTaskIds;
@property (nonatomic, strong) NSSet *schedulesWithoutUniqueTaskIds;
@end


@implementation APCUniqueTaskIdFilter

- (instancetype) init
{
    self = [super init];

    if (self)
    {
        _schedulesWithUniqueTaskIds = nil;
        _schedulesWithoutUniqueTaskIds = nil;
    }

    return self;
}

- (NSSet *) passed
{
    return self.schedulesWithUniqueTaskIds;
}

- (NSSet *) failed
{
    return self.schedulesWithoutUniqueTaskIds;
}

- (void) split: (NSSet *) setOfSchedules
{
    NSMutableSet *uniqueTaskIds       = [NSMutableSet new];
    NSMutableSet *duplicateTaskIds    = [NSMutableSet new];
    NSMutableSet *uniquifiedSchedules = [NSMutableSet new];
    NSMutableSet *duplicateSchedules  = [NSMutableSet new];

    for (APCSchedule *schedule in setOfSchedules)
    {
        BOOL thisScheduleContainsSomeoneElsesTaskId = NO;

        for (APCTask *task in schedule.tasks)
        {
            NSString *taskId = task.taskID;

            if (taskId == nil)
            {
                taskId = kAPCNullTaskIdString;
            }

            if ([uniqueTaskIds containsObject: taskId])
            {
                thisScheduleContainsSomeoneElsesTaskId = YES;
                [duplicateTaskIds addObject: taskId];
                break;
            }
            else
            {
                [uniqueTaskIds addObject: taskId];
            }
        }

        if (thisScheduleContainsSomeoneElsesTaskId)
        {
            [duplicateSchedules addObject: schedule];
        }
        else
        {
            [uniquifiedSchedules addObject: schedule];
        }
    }

    // Done!
    self.schedulesWithUniqueTaskIds    = [NSSet setWithSet: uniquifiedSchedules];
    self.schedulesWithoutUniqueTaskIds = [NSSet setWithSet: duplicateSchedules];
}

@end
