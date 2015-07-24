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
#import "NSDate+Helper.h"


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
    NSComparisonResult result = [[APCSchedule class] compareSchedule: self
                                                        withSchedule: otherSchedule];

    return result;
}

+ (NSComparisonResult) compareSchedule: (APCSchedule *) schedule1
                          withSchedule: (APCSchedule *) schedule2
{
    NSComparisonResult result = NSOrderedSame;
    NSArray *taskSorters = [APCTask defaultSortDescriptors];

    NSArray *schedule1tasks = [schedule1.tasks sortedArrayUsingDescriptors: taskSorters];
    NSArray *schedule2tasks = [schedule2.tasks sortedArrayUsingDescriptors: taskSorters];
    APCTask *schedule1task = schedule1tasks.firstObject;
    APCTask *schedule2task = schedule2tasks.firstObject;

    if (schedule1task == nil && schedule2task == nil)
    {
        result = NSOrderedSame;
    }
    else if (schedule2task == nil)
    {
        result = NSOrderedDescending;
    }
    else if (schedule1task == nil)
    {
        result = NSOrderedAscending;
    }
    else
    {
        NSArray *plainTasks = @[schedule1task, schedule2task];
        NSArray *sortedTasks = [plainTasks sortedArrayUsingDescriptors: taskSorters];

        if (sortedTasks.firstObject == schedule1task)
        {
            result = NSOrderedAscending;
        }
        else
        {
            result = NSOrderedDescending;
        }
    }

    return result;
}

+ (NSArray *) sortSchedules: (NSArray *) schedules
{
    NSArray *result = [schedules sortedArrayUsingComparator:^NSComparisonResult (APCSchedule *schedule1,
                                                                                 APCSchedule *schedule2)
                       {
                           return [self compareSchedule: schedule1
                                           withSchedule: schedule2];
                       }];

    return result;
}

- (BOOL) isFunctionallyEquivalentToSchedule: (APCSchedule *) otherSchedule
{
    BOOL schedulesAreEquivalent = NO;

    BOOL propertiesAreEqual = (
                               [self object1: self.scheduleSource      equalsObject2: otherSchedule.scheduleSource]    &&      // server, disk, glucose log, etc.
                               [self object1: self.scheduleType        equalsObject2: otherSchedule.scheduleType]      &&      // one-time, cron-based, interval-based
                               [self object1: self.effectiveEndDate    equalsObject2: otherSchedule.effectiveEndDate]  &&
                               [self object1: self.delay               equalsObject2: otherSchedule.delay]             &&      // delay before first instance shows up on calendar
                               [self object1: self.expires             equalsObject2: otherSchedule.expires]           &&      // delay before each instance vanishes from calendar
                               [self object1: self.maxCount            equalsObject2: otherSchedule.maxCount]          &&      // max number of occurrences on calendar
                               [self object1: self.notes               equalsObject2: otherSchedule.notes]             &&
                               [self object1: self.scheduleString      equalsObject2: otherSchedule.scheduleString]    &&      // the cron expression
                               [self object1: self.shouldRemind        equalsObject2: otherSchedule.shouldRemind]      &&
                               [self object1: self.reminderMessage     equalsObject2: otherSchedule.reminderMessage]   &&
                               [self object1: self.reminderOffset      equalsObject2: otherSchedule.reminderOffset]    &&
                               [self object1: self.interval            equalsObject2: otherSchedule.interval]          &&      // time between appearances, like "3 months"
                               [self object1: self.timesOfDay          equalsObject2: otherSchedule.timesOfDay]        &&      // list of times of day, if using intervals

                               true     // leave this at the end, to make it easier to rearrange the lines above
                               );

    if (propertiesAreEqual &&
        (self.tasks.count == otherSchedule.tasks.count) &&
        (self.tasks.count > 0))
    {
        /*
         Up to here, they're identical.  Past this point, we'll
         look for something NOT different, and set this to NO
         if found:
         */
        schedulesAreEquivalent = YES;

        /*
         We have the same number of tasks.  Let's sort both lists of tasks
         by ID and version, and then walk through them in order.  If we find
         any differences, one of the tasks is different from the other, which
         is all we need to know.

         Sort them using an array of sort descriptors we declared at the top
         of this file.  We might call this method hundreds of times for a given
         schedule download.  We won't do that OFTEN, but there's no reason to
         keep reallocating those sort descriptors every time that happens.
         */
        NSArray *myTasks    = [self.tasks.allObjects sortedArrayUsingDescriptors: [APCTask defaultSortDescriptors]];
        NSArray *otherTasks = [otherSchedule.tasks.allObjects sortedArrayUsingDescriptors: [APCTask defaultSortDescriptors]];

        for (NSUInteger taskIndex = 0; taskIndex < myTasks.count; taskIndex ++)
        {
            APCTask *myTask = myTasks [taskIndex];
            APCTask *otherTask = otherTasks [taskIndex];

            if (! [self object1: myTask.taskID            equalsObject2: otherTask.taskID] ||
                ! [self object1: myTask.taskVersionNumber equalsObject2: otherTask.taskVersionNumber])
            {
                schedulesAreEquivalent = NO;
                break;
            }
        }
    }

    return schedulesAreEquivalent;
}

/**
 The rules, by example:
 -  if self.delay == nil:  return the specified date.
 -  Feb 1, 2010 + 4 hours (P4H)  = Feb 1, 2010, 00:00:00 (start of the same day)
 -  Feb 1, 2010 + 3 days  (P3D)  = Feb 3, 2010, 00:00:00 (start of Feb 3, on the third day as measured from midnight on Feb 1)
 
 Note that this means P1D == P0D.
 */
- (NSDate *) computeDelayedStartDateFromDate: (NSDate *) date
{
    NSDate *result = [[self class] computeDelayedStartDateFromDate: date
                                            usingISO860DelayPeriod: self.delay];

    return result;
}

+ (NSDate *) computeDelayedStartDateFromDate: (NSDate *) date
                      usingISO860DelayPeriod: (NSString *) delay
{
    NSDate *result = date.startOfDay;

    if (delay.length)
    {
        result = [result dateByAddingISO8601Duration: delay];

        if ([result isSameDayAsDate: date])
        {
            // No problem.
        }
        else
        {
            // Lets us say:  a "delay" of 2 days == "day 2" as counted from the first day.
            result = result.dayBefore;
        }

        result = result.startOfDay;
    }

    return result;
}

/**
 The rules, by example:
 -  if self.expires == nil:  return nil.
 -  Feb 1, 2010 + 4 hours (P4H)  = Feb 1, 2010, 23:59:59 (end of the same day)
 -  Feb 1, 2010 + 3 days  (P3D)  = Feb 3, 2010, 23:59:59 (end of Feb 3, 3 full days later)
 */
- (NSDate *) computeExpirationDateForScheduledDate: (NSDate *) date
{
    NSDate *result = [[self class] computeExpirationDateForScheduledDate: date
                                             usingISO860ExpirationPeriod: self.expires];

    return result;
}

+ (NSDate *) computeExpirationDateForScheduledDate: (NSDate *) date
                       usingISO860ExpirationPeriod: (NSString *) expirationPeriod
{
    NSDate *expirationDate = nil;

    if (expirationPeriod.length > 0)
    {
        NSDate *firstMorningMidnight = date.startOfDay;
        expirationDate = [date dateByAddingISO8601Duration: expirationPeriod];

        if ([expirationDate isSameDayAsDate: firstMorningMidnight])
        {
            /*
             We'll get here if, for example, self.expires == "P4H" (4 hours).
             */
            expirationDate = expirationDate.endOfDay;
        }
        else
        {
            /*
             We'll get here if, for example, self.expires = "P3D" (3 days) 
             or greater.

             ISO 8601 durations are never negative, so if we get to this 
             "else" clause, we're on some calendar date *after* date.
             */
            expirationDate = expirationDate.dayBefore.endOfDay;
        }
    }

    return expirationDate;
}

- (NSSet *) taskIds
{
    NSMutableSet *result = [NSMutableSet new];

    for (APCTask *task in self.tasks)
    {
        NSString *taskId = task.taskID;

        if (taskId.length > 0)
        {
            [result addObject: taskId];
        }
    }

    return [NSSet setWithSet: result];
}

+ (NSSet *) extractTaskIdsFromSchedules: (NSSet *) schedules
{
    NSMutableSet *taskIds = [NSMutableSet new];

    for (APCSchedule *schedule in schedules)
    {
        [taskIds unionSet: schedule.taskIds];
    }

    return [NSSet setWithSet: taskIds];
}

/**
 Performs a "practical" version of "isEqual", returning YES if
 (a)  both objects are nil, or
 (b)  [object1 isEqual: object2]
 */
- (BOOL) object1: (id) object1
   equalsObject2: (id) object2
{
    return ((object1 == nil && object2 == nil) || [object1 isEqual: object2]);
}

@end
