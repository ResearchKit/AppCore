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

/**
 Lets us sort schedules for human readability:  by the human-readable
 name and/or sort order by one of the taks controlled by the schedule.
 */
- (NSComparisonResult) compareWithSchedule: (APCSchedule *) otherSchedule;

/**
 Lets us sort schedules for human readability:  by the human-readable
 name and/or sort order by one of the taks controlled by the schedule.
 */
+ (NSComparisonResult) compareSchedule: (APCSchedule *) schedule1
                          withSchedule: (APCSchedule *) schedule2;

/**
 Sorts the specified set of schedules by task name (or, rather, by the
 tasks' default sort order, which is usually by the human-readable
 title).
 */
+ (NSArray *) sortSchedules: (NSArray *) schedules;

/**
 Checks for functional equivalence between self and otherSchedule,
 comparing the two schedules property by property (except startsOn,
 which is almost always different).
 */
- (BOOL) isFunctionallyEquivalentToSchedule: (APCSchedule *) otherSchedule;

/**
 Embodies our rules for applying a delay to a schedule's start date.
 This method simply calls the class-level method
 +computeDelayedStartDateFromDate:usingISO860DelayPeriod:.
 */
- (NSDate *) computeDelayedStartDateFromDate: (NSDate *) date;

/**
 Embodies our rules for applying a delay to a schedule's start date.  Please
 use this method when adding delays (the schedule.delay property) to a date, in
 order to get consistent behavior when comparing dates.

 If delay is nil, returns date.  Otherwise, adds delay to date and rounds to
 the morning before that.  For example:

 -  Feb 1, 2010, noon + 4 hours (P4H) = Feb 1, 00:00:00 (start of the same day)
 -  Feb 1, 2010, noon + 3 days  (P3D) = Feb 3, 00:00:00 (start of the 3rd day, counting from Feburary 1)

 The delay is a string representing a time interval, like "P4D" for "4 days" or
 "P1W" for "1 week."  The strings are in ISO 8601 format.  This method uses the
 category method -[NSDate+Helper dateByAddingISO8601Duration:] to do the math.
 */
+ (NSDate *) computeDelayedStartDateFromDate: (NSDate *) date
                      usingISO860DelayPeriod: (NSString *) delay;

/**
 Embodies our rules for "expiration periods" ("grace periods").
 This method simply calls the class-level method
 +computeExpirationDateForScheduledDate:usingISO860ExpirationPeriod:.
 */
- (NSDate *) computeExpirationDateForScheduledDate: (NSDate *) date;

/**
 Embodies our rules for "expiration periods" ("grace periods").  Please use
 this method when adding expiration-time intervals (the schedule.expires
 property) to a date, in order to get consistent behavior when comparing dates.

 If expirationPeriod is nil, returns nil, indicating that there is no
 expiration period for that date.  (Note that for repeating schedules, a task
 will always expire at the next repetition of that schedule -- unless that
 schedule's "expires" property says it should expire sooner.)  If
 expirationPeriod is not nil, adds expirationPeriod to date.  For example:

 -  Feb 1, 2010 + 4 hours (P4H)  = Feb 1, 2010, 23:59:59 (end of the same day)
 -  Feb 1, 2010 + 3 days  (P3D)  = Feb 3, 2010, 23:59:59 (end of Feb 3, 3 full days later)

 The expirationPeriod is a string representing a time interval, like "P4D" for
 "4 days" or "P1W" for "1 week."  The strings are in ISO 8601 format.  This
 method uses the category method -[NSDate+Helper dateByAddingISO8601Duration:]
 to do the math.
 */
+ (NSDate *) computeExpirationDateForScheduledDate: (NSDate *) date
                       usingISO860ExpirationPeriod: (NSString *) expirationPeriod;

/**
 Extracts and returns the set of non-nil taskIDs from my tasks.
 The resulting set may be empty, but will never be nil.
 */
@property (readonly) NSSet *taskIds;

/**
 Walks through the specified set of schedules, extracting
 all their tasks' IDs.
 */
+ (NSSet *) extractTaskIdsFromSchedules: (NSSet *) schedules;

@end
