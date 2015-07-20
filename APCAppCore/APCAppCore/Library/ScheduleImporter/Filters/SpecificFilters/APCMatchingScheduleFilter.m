//
//  APCMatchingScheduleFilter.m
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

#import "APCMatchingScheduleFilter.h"
#import "APCSchedule+AddOn.h"
#import "APCScheduleTaskMapEntry.h"
#import "APCTask.h"
#import "NSArray+APCHelper.h"


@interface APCMatchingScheduleFilter ()
@property (nonatomic, strong) NSSet *matchingSchedules;
@property (nonatomic, strong) NSSet *nonMatchingSchedules;
@end


@implementation APCMatchingScheduleFilter

- (instancetype) init
{
    self = [super init];

    if (self)
    {
        _matchingSchedules = nil;
        _nonMatchingSchedules = nil;
    }

    return self;
}

- (NSSet *) passed
{
    return self.matchingSchedules;
}

- (NSSet *) failed
{
    return self.nonMatchingSchedules;
}

- (void) split: (NSSet *) setOfSchedules
       withMap: (APCScheduleTaskMap *) map
{
    NSMutableSet *matchingSchedules = [NSMutableSet new];
    NSMutableSet *nonMatchingSchedules = [NSMutableSet new];

    for (APCSchedule *schedule in setOfSchedules)
    {
        BOOL isIdentical = YES;

        for (APCTask *task in schedule.tasks)
        {
            if (task.taskID.length)
            {
                APCScheduleTaskMapEntry *entry = [map entryForTaskId: task.taskID];

                BOOL isIdenticalToThisSchedule = [schedule isFunctionallyEquivalentToSchedule: entry.schedule];

                if (! isIdenticalToThisSchedule)
                {
                    isIdentical = NO;
                    break;
                }
            }
        }

        if (isIdentical)
        {
            [matchingSchedules addObject: schedule];
        }
        else
        {
            [nonMatchingSchedules addObject: schedule];
        }
    }

    self.matchingSchedules    = [NSSet setWithSet: matchingSchedules];
    self.nonMatchingSchedules = [NSSet setWithSet: nonMatchingSchedules];
}

@end
