// 
//  APCSchedule+AddOn.m 
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
 
#import "APCSchedule+AddOn.h"
#import "APCModel.h"
#import "APCTopLevelScheduleEnumerator.h"
#import "APCTask+AddOn.h"
#import "APCDateRange.h"


static NSString * const kScheduleShouldRemindKey    = @"shouldRemind";
static NSString * const kScheduleReminderOffsetKey  = @"reminderOffset";
static NSString * const kScheduleReminderMessageKey = @"reminderMessage";

static NSString * const kTaskIDKey                  = @"taskID";
static NSString * const kScheduleStringKey          = @"scheduleString";
static NSString * const kScheduleTypeKey            = @"scheduleType";

static NSString * const kExpires                    = @"expires";
static NSString * const kScheduleDelayKey           = @"delay";
static NSString * const kScheduleNotesKey           = @"notes";

NSString * const kAPCScheduleTypeValueOneTimeSchedule = @"once";



@implementation APCSchedule (AddOn)

- (APCScheduleExpression *) scheduleExpression
{
    return [[APCScheduleExpression alloc] initWithExpression:self.scheduleString timeZero:0];
}

+ (NSString *) safeScheduleIdFromDictionaryValue: (id) dictionaryValue
{
    NSString *result = nil;

    result = [self safeStringFromDictionaryValue: dictionaryValue
                                        allowNil: YES   // schedule IDs are optional -- we're phasing them in.
                                  trimWhitespace: YES];

    return result;
}

+ (NSString *) safeStringFromDictionaryValue: (id) dictionaryValue
                                    allowNil: (BOOL) shouldAllowNil
                              trimWhitespace: (BOOL) shouldTrimWhitespace
{
    NSString *result = nil;

    if ([dictionaryValue isKindOfClass: [NSString class]])
    {
        result = dictionaryValue;

        if (result == nil && ! shouldAllowNil)
        {
            result = @"";
        }

        if (shouldTrimWhitespace)
        {
            result = [result stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }

    return result;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveValue:[NSDate date] forKey:@"createdAt"];
}

- (void)willSave
{
    [self setPrimitiveValue:[NSDate date] forKey:@"updatedAt"];
}

- (APCTopLevelScheduleEnumerator *) enumeratorFromDate: (NSDate *) startDate
                                                toDate: (NSDate *) endDate
{
    APCTopLevelScheduleEnumerator *enumerator = [[APCTopLevelScheduleEnumerator alloc] initWithSchedule: self
                                                                                               fromDate: startDate
                                                                                                 toDate: endDate];
    return enumerator;
}

- (APCTopLevelScheduleEnumerator *) enumeratorOverDateRange: (APCDateRange *) dateRange
{
    return [self enumeratorFromDate: dateRange.startDate
                             toDate: dateRange.endDate];
}

- (APCScheduleRecurrenceStyle) recurrenceStyle
{
    APCScheduleRecurrenceStyle style = APCScheduleRecurrenceStyleExactlyOnce;

    if ([self.scheduleType isEqualToString: kAPCScheduleTypeValueOneTimeSchedule])
    {
        style = APCScheduleRecurrenceStyleExactlyOnce;
    }

    else if (self.interval.length > 0)
    {
        style = APCScheduleRecurrenceStyleInterval;
    }

    else if (self.scheduleString.length > 0)
    {
        style = APCScheduleRecurrenceStyleCronExpression;
    }

    else
    {
        style = APCScheduleRecurrenceStyleExactlyOnce;
    }

    return style;
}

- (BOOL) isOneTimeSchedule
{
    return self.recurrenceStyle == APCScheduleRecurrenceStyleExactlyOnce;
}

- (BOOL)isRecurringCronSchedule
{
    return self.recurrenceStyle == APCScheduleRecurrenceStyleCronExpression;
}

- (BOOL) isRecurringIntervalSchedule
{
    return self.recurrenceStyle == APCScheduleRecurrenceStyleInterval;
}

- (NSString *) firstTaskTitle
{
    NSString *result = nil;

    if (self.tasks.count)
    {
        APCTask *firstTask = self.tasks.anyObject;
        result = firstTask.taskTitle;
    }

    return result;
}

- (NSString *) firstTaskId
{
    NSString *result = nil;

    if (self.tasks.count)
    {
        APCTask *firstTask = self.tasks.anyObject;
        result = firstTask.taskID;
    }

    return result;
}

- (NSComparisonResult) compareWithSchedule: (APCSchedule *) otherSchedule
{
    NSComparisonResult result = NSOrderedSame;
    APCTask *oneOfMyTasks = self.tasks.anyObject;
    APCTask *oneOfOtherTasks = otherSchedule.tasks.anyObject;

    if (oneOfMyTasks == nil && oneOfOtherTasks == nil)
    {
        result = NSOrderedSame;
    }
    else if (oneOfOtherTasks == nil)
    {
        result = NSOrderedDescending;
    }
    else if (oneOfMyTasks == nil)
    {
        result = NSOrderedAscending;
    }
    else
    {
        NSArray *plainTasks = @[oneOfMyTasks, oneOfOtherTasks];
        NSArray *sortedTasks = [plainTasks sortedArrayUsingDescriptors: [APCTask defaultSortDescriptors]];
        result = sortedTasks.firstObject == oneOfMyTasks ? NSOrderedAscending : NSOrderedDescending;
    }

    return result;
}

@end
