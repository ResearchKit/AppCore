// 
//  APCScheduleExpression.h 
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
 
#import <Foundation/Foundation.h>

@class APCScheduleEnumerator;



/**
 
 The `APCScheduleExpression` class is the public interface for scheduled backed by a modified cron expression.
 
 Example usage:
    APCScheduleExpression*    schedule   = [[APCScheduleExpression alloc] initWithExpression:@"A 5 * * * *" timeZero:0];
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[dateFormatter dateFromString:@"2014-01-01 06:00"]];

    NSDate* date;
    while ((date = enumerator.nextObject))
    {
        NSLog(@"Date: %@", date);
    }

 
 A *schedule* represents a potentially infinite sequence of `moments` (date-time events).
 The supported cron expression is as follows:
 
 * * * * *  task id
 │ │ │ │ │
 │ │ │ │ │
 │ │ │ │ └──────── day of week
 │ │ │ └────────── month
 │ │ └──────────── day of month
 │ └────────────── hour
 └──────────────── minutes
 
                                Allowed     Special
    Index   Field Name          Values      Characters      Note
    ------------------------------------------------------------------------------------------------
    0:      Minutes             0-59        * , -
    1:      Hours               0-23        * , -
    2:      Day of month        1-31        * , -
    3:      Month               1-12        * , -           1: Jan, 2: Feb, ..,, 12: Dec
    4:      Day of week         0-6         * , -           0: Sun, 1: Mon, ..., 6: Sat

    *   Matches all values. Example: an ‘*’ in the Day of Month field means every day.
    ,   Separate items of a list. Example: 7,14,21 for the Day of Week field means the 7th, 14th,
        and 21st day on the month.
    -   Ranges. Example: 9-12 for the Month field means Sept through December.

 A schedule is considered satisified if all the date and time fields match the provided date and time
 (logical conjunction). There is a partial relaxation if the Day of Week and Day of Month are restricted
 (ie, not '*'); these two fields are logical disjunction.
 
 */


@interface APCScheduleExpression : NSObject

/**
 *  Designated initializer
 *
 *  @param expression A modified cron expression that identifies points in time at which the
 *                    `schedule` is satisfied
 *  @param timeZero   An non-negative offset from midnight that will be considered as `time zero`
 *                    for satisifing a schedule.
 *
 *  @return instancetype
 */
- (instancetype)initWithExpression:(NSString*)expression timeZero:(NSTimeInterval)timeZero;

/**
 *  An enumerator that provides an infinite sequence of NSDates that satisfies `self`, beginning at
 *  `start date`
 *
 *  @param start The point in time in which to begin the enumeration
 *
 *  @return An enumerator; returns NSDate(s) that satisfies `self`
 */
- (APCScheduleEnumerator*)enumeratorBeginningAtTime:(NSDate*)start;

/**
 *  An enumerator that provides a finite sequence of NSDates from `start` to `end` that satifisies `self`
 *
 *  @param start The initial date and time to begin the enumeration, inlcusive.
 *  @param end   The final date and time to end the enumeration, exclusive.
 *
 *  @return An enumerator, returns NSDate(s) that satisfies `self`
 */
- (APCScheduleEnumerator*)enumeratorBeginningAtTime:(NSDate*)start endingAtTime:(NSDate*)end;

@end
