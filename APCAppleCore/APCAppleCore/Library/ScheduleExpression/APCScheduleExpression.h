//
//  APCScheduleExpression.h
//  Schedule
//
//  Created by Edward Cessna on 9/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


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

 
 A *schedule* represents a potentially infinite sequence of `moments` (date-time events). This
 sequence is represented by a cron expression with the addition of a `relative indicator`. The
 relative indicator was added in order to support 24-hours periods that could begin at times other
 than midnight.

 The supported cron expression is as follows:
 
 * * * * * *  task id
 │ │ │ │ │ │
 │ │ │ │ │ │
 │ │ │ │ │ └──────── day of week
 │ │ │ │ └────────── month
 │ │ │ └──────────── day of month
 │ │ └────────────── hour
 │ └──────────────── minutes
 └────────────────── relative indicator
 
                                Allowed     Special
    Index   Field Name          Values      Characters      Note
    ------------------------------------------------------------------------------------------------
    0:      Relative indicator  A, R                        A: absolute, R: relative
    1:      Minutes             0-59        * , -
    2:      Hours               0-23        * , -
    3:      Day of month        1-31        * , -
    4:      Month               1-12        * , -           1: Jan, 2: Feb, ..,, 12: Dec
    5:      Day of week         0-6         * , -           0: Sun, 1: Mon, ..., 6: Sat

    A   If hours or minutes are specified, they are absolute
    R   If hours or minutes are specified, they are relative to the user’s general wake time
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
 *  @param expression A modified cron expression that identifies point in time in which the 
 *                    `schedule` is satisfied
 *  @param timeZero   An non-negative offset from midnight that will be considered as `time zero`
 *                    for satisifing a schedule.
 *
 *  @return instancetype
 */
- (instancetype)initWithExpression:(NSString*)expression timeZero:(NSTimeInterval)timeZero;

/**
 *  isValid
 *
 *  @return True if the cron expression provided was parsable.
 */
- (BOOL)isValid;

/**
 *  An enumerator that provides an infinite sequence of NSDates that satisfies `self`, beginning at
 *  `start date`
 *
 *  @param start The point in time in which to begin the enumeration
 *
 *  @return An enumerator; returns NSDate(s) that satisfies `self`
 */
- (NSEnumerator*)enumeratorBeginningAtTime:(NSDate*)start;

/**
 *  An enumerator that provides a finite sequence of NSDates from `start` to `end` that satifisies `self`
 *
 *  @param start The initial date and time to begin the enumeration, inlcusive.
 *  @param end   The final date and time to end the enumeration, exclusive.
 *
 *  @return An enumerator, returns NSDate(s) that satisfies `self`
 */
- (NSEnumerator*)enumeratorBeginningAtTime:(NSDate*)start endingAtTime:(NSDate*)end;

@end
