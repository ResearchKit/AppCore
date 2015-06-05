//
//  APCTopLevelScheduleEnumerator.m
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

#import "APCTopLevelScheduleEnumerator.h"
#import "APCDateRange.h"
#import "APCSchedule+AddOn.h"
#import "APCScheduleEnumerator.h"
#import "APCScheduleIntervalEnumerator.h"
#import "NSDate+Helper.h"


@interface APCTopLevelScheduleEnumerator ()

- (instancetype) init NS_DESIGNATED_INITIALIZER;

// The basics
@property (nonatomic, strong) APCSchedule *schedule;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) APCScheduleRecurrenceStyle recurrenceStyle;

// enumeration style #1:  using cron expressions
@property (nonatomic, strong) NSString *originalCronExpression;
@property (nonatomic, strong) APCScheduleExpression *apcCronExpression;
@property (nonatomic, strong) APCScheduleEnumerator *apcCronExpressionEnumerator;

// enumeration style #2:  ISO 8601 (human-readable) time intervals
@property (nonatomic, strong) APCScheduleIntervalEnumerator *intervalEnumerator;

/*
 Optional max count of iterations.  This is an NSNumber
 to allow us to use "nil" to mean "not set."
 */
@property (nonatomic, strong) NSNumber *maxCount;
@property (nonatomic, assign) NSUInteger countOfTimesCalledSoFar;

@end


@implementation APCTopLevelScheduleEnumerator

- (instancetype) init
{
    self = [super init];

    if (self)
    {
        _apcCronExpression              = nil;
        _apcCronExpressionEnumerator    = nil;
        _countOfTimesCalledSoFar        = 0;
        _endDate                        = nil;
        _intervalEnumerator             = nil;
        _maxCount                       = nil;
        _originalCronExpression         = nil;
        _recurrenceStyle                = APCScheduleRecurrenceStyleExactlyOnce;
        _schedule                       = nil;
        _startDate                      = nil;
    }

    return self;
}

- (instancetype) initWithSchedule: (APCSchedule *) schedule
                         fromDate: (NSDate *) startDate
                           toDate: (NSDate *) endDate
{
    self = [self init];

    if (self)
    {
        _endDate                = endDate;
        _maxCount               = schedule.maxCount;
        _originalCronExpression = schedule.scheduleString;
        _schedule               = schedule;
        _startDate              = startDate;

        // This is a computed property.
        _recurrenceStyle = schedule.recurrenceStyle;

        switch (schedule.recurrenceStyle)
        {
            default:
            case APCScheduleRecurrenceStyleExactlyOnce:
            {
                _maxCount = @(1);
                break;
            }

            case APCScheduleRecurrenceStyleCronExpression:
            {
                if (_originalCronExpression.length)
                {
                    _apcCronExpression = schedule.scheduleExpression;
                    _apcCronExpressionEnumerator = [_apcCronExpression enumeratorBeginningAtTime: startDate
                                                                                    endingAtTime: endDate];
                }
                break;
            }

            case APCScheduleRecurrenceStyleInterval:
            {
                _intervalEnumerator = [[APCScheduleIntervalEnumerator alloc] initWithSchedule: schedule
                                                                                    startDate: startDate
                                                                                      endDate: endDate];
                break;
            }
        }
    }

    return self;
}

- (NSDate *) nextObject
{
    return [self nextScheduledAppearance];
}

- (NSDate *) nextScheduledAppearance
{
    NSDate    *appearanceDate = nil;
    NSUInteger maxCount       = self.maxCount.integerValue;

    if (self.schedule.recurrenceStyle == APCScheduleRecurrenceStyleExactlyOnce)
    {
        maxCount = 1;
    }

    BOOL weNeedToWatchForMaxCount = maxCount > 0;
    BOOL weHaveReachedMaxCount    = (self.countOfTimesCalledSoFar >= maxCount);


    if (weNeedToWatchForMaxCount && weHaveReachedMaxCount)
    {
        // We're done enumerating.  Return nil.
        appearanceDate = nil;
    }
    else
    {
        switch (self.recurrenceStyle)
        {
            default:
            case APCScheduleRecurrenceStyleExactlyOnce:
                appearanceDate = self.startDate;
                break;

            case APCScheduleRecurrenceStyleCronExpression:
                appearanceDate = self.apcCronExpressionEnumerator.nextScheduledDate;
                break;

            case APCScheduleRecurrenceStyleInterval:
                appearanceDate = self.intervalEnumerator.nextScheduledDate;
                break;
        }
    }

    self.countOfTimesCalledSoFar = self.countOfTimesCalledSoFar + 1;
    return appearanceDate;
}

@end
