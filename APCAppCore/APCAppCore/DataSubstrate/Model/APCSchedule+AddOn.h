// 
//  APCSchedule+AddOn.h 
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
 
#import "APCSchedule.h"
#import "APCScheduleExpression.h"


@class APCTopLevelScheduleEnumerator;
@class APCTask;
@class APCDateRange;



/**
 Describes the enumeration style of a particular Schedule.
 Also determines which techniques we employ when enumerating
 the date/time values represented by that Schedule.
 */
typedef enum : NSUInteger {

    /** The schedule specifies a single occurrence. */
    APCScheduleRecurrenceStyleExactlyOnce,

    /** The schedule recurs according to the rules of 
     a Unix-style cron expression. */
    APCScheduleRecurrenceStyleCronExpression,

    /** The schedule recurs according to a (human-readable)
     ISO 8601 time interval, like "every 90 days," and
     an optional list of times in a given day. */
    APCScheduleRecurrenceStyleInterval,

}   APCScheduleRecurrenceStyle;


/**
 Used in the very occasional place we need to know one
 specific value of the scheduleType field outside this
 category.  For the most part, we can get more and
 better information from schedule.recurrenceStyle.
 */
FOUNDATION_EXPORT NSString * const kAPCScheduleTypeValueOneTimeSchedule;



@interface APCSchedule (AddOn)

@property (readonly) APCScheduleExpression * scheduleExpression;
@property (readonly) APCScheduleRecurrenceStyle recurrenceStyle;
@property (readonly) NSString *firstTaskTitle;
@property (readonly) NSString *firstTaskId;
@property (readonly) BOOL isOneTimeSchedule;
@property (readonly) BOOL isRecurringCronSchedule;
@property (readonly) BOOL isRecurringIntervalSchedule;

- (APCTopLevelScheduleEnumerator *) enumeratorFromDate: (NSDate *) startDate
                                                toDate: (NSDate *) endDate;

- (APCTopLevelScheduleEnumerator *) enumeratorOverDateRange: (APCDateRange *) dateRange;

- (NSComparisonResult) compareWithSchedule: (APCSchedule *) otherSchedule;

@end

