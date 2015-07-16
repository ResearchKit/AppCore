//
//  APCMatchingSourceFilter.m
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

#import "APCMatchingSourceFilter.h"
#import "APCSchedule.h"
#import "APCScheduleTaskMap.h"
#import "APCScheduleTaskMapEntry.h"
#import "APCTask.h"
#import "NSArray+APCHelper.h"


@interface APCMatchingSourceFilter ()
@property (nonatomic, strong) NSSet *schedulesWithSameSource;
@property (nonatomic, strong) NSSet *schedulesWithDifferentSources;
@property (nonatomic, strong) NSSet *schedulesNotMentioned;
@end


@implementation APCMatchingSourceFilter

- (instancetype) init
{
    self = [super init];

    if (self)
    {
        _schedulesNotMentioned = nil;
        _schedulesWithDifferentSources = nil;
        _schedulesNotMentioned = nil;
    }

    return self;
}

- (NSSet *) passed
{
    return self.schedulesWithSameSource;
}

- (NSSet *) failed
{
    return self.schedulesWithDifferentSources;
}

- (NSSet *) unknown
{
    return self.schedulesNotMentioned;
}

- (void) split: (NSSet *) setOfSchedules
       withMap: (APCScheduleTaskMap *) map
{
    NSMutableSet *schedulesWithSameSource       = [NSMutableSet new];
    NSMutableSet *schedulesWithDifferentSources = [NSMutableSet new];
    NSMutableSet *schedulesNotMentioned         = [NSMutableSet new];

    for (APCSchedule *schedule in setOfSchedules)
    {
        BOOL allTasksAreFromSameSourceAsMappedSchedule = YES;
        BOOL scheduleHasAtLeastOneTaskInMap = NO;

        for (APCTask *task in schedule.tasks)
        {
            APCScheduleTaskMapEntry *entry = [map entryForTaskId: task.taskID];

            if (entry != nil)
            {
                APCSchedule *otherSchedule = entry.schedule;

                if (otherSchedule != nil)
                {
                    scheduleHasAtLeastOneTaskInMap = YES;

                    if (schedule.scheduleSource.integerValue != otherSchedule.scheduleSource.integerValue)
                    {
                        allTasksAreFromSameSourceAsMappedSchedule = NO;
                        break;
                    }
                }
            }
        }

        if (! scheduleHasAtLeastOneTaskInMap)
        {
            [schedulesNotMentioned addObject: schedule];
        }
        else if (allTasksAreFromSameSourceAsMappedSchedule)
        {
            [schedulesWithSameSource addObject: schedule];
        }
        else
        {
            [schedulesWithDifferentSources addObject: schedule];
        }
    }

    self.schedulesWithSameSource        = [NSSet setWithSet: schedulesWithSameSource];
    self.schedulesWithDifferentSources  = [NSSet setWithSet: schedulesWithDifferentSources];
    self.schedulesNotMentioned          = [NSSet setWithSet: schedulesNotMentioned];
}

@end
