//
//  APCScheduleStartDateFilter.m
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

#import "APCScheduleStartDateFilter.h"
#import "APCSchedule.h"
#import "NSArray+APCHelper.h"
#import "NSDate+Helper.h"


@interface APCScheduleStartDateFilter ()
@property (nonatomic, strong) NSSet *schedulesBeforeDate;
@property (nonatomic, strong) NSSet *schedulesOnDate;
@property (nonatomic, strong) NSSet *schedulesAfterDate;
@end


@implementation APCScheduleStartDateFilter

- (instancetype) init
{
    self = [super init];

    if (self)
    {
        _schedulesBeforeDate = nil;
        _schedulesOnDate = nil;
        _schedulesAfterDate = nil;
    }

    return self;
}

- (NSSet *) before
{
    return self.schedulesBeforeDate;
}

- (NSSet *) during
{
    return self.schedulesOnDate;
}

- (NSSet *) after
{
    return self.schedulesAfterDate;
}

- (void) split: (NSSet *) setOfSchedules
      withDate: (NSDate *) date
{
    NSMutableSet *schedulesBeforeDate = [NSMutableSet new];
    NSMutableSet *schedulesOnDate     = [NSMutableSet new];
    NSMutableSet *schedulesAfterDate  = [NSMutableSet new];

    for (APCSchedule *schedule in setOfSchedules)
    {
        NSDate* startDate = schedule.startsOn;

        if (startDate == nil)
        {
            [schedulesBeforeDate addObject: schedule];
        }
        else if ([startDate isSameDayAsDate: date])
        {
            [schedulesOnDate addObject: schedule];
        }
        else if ([startDate isEarlierThanDate: date])
        {
            [schedulesBeforeDate addObject: schedule];
        }
        else
        {
            [schedulesAfterDate addObject: schedule];
        }
    }

    self.schedulesBeforeDate = [NSSet setWithSet: schedulesBeforeDate];
    self.schedulesOnDate     = [NSSet setWithSet: schedulesOnDate];
    self.schedulesAfterDate  = [NSSet setWithSet: schedulesAfterDate];
}

@end
