//
//  APCTaskGroup.m
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

#import "APCTaskGroup.h"
#import "APCTask+AddOn.h"
#import "APCSchedule+AddOn.h"
#import "APCConstants.h"
#import "APCScheduledTask+AddOn.h"
#import "NSDate+Helper.h"
#import "APCPotentialScheduledTask.h"

/**
 We always sort -allCompletedTasks by the same set of
 sort descriptors, so we might as well make it common.
 This is thread-safe:  it's created during +initialize,
 and never changes.
 */
static NSArray *sortDescriptorsForSortingScheduledTasksByCompletionDate = nil;

/** The date format we use when debug-printing the taskGroup. */
static NSString * const kAPCDebugDateFormat = @"EEE yyyy-MM-dd HH:mm zzz";

/** A date formatter we use when debug-printing the taskGroup. */
static NSDateFormatter *debugDateFormatter = nil;



@interface APCTaskGroup ()

/**
 By flagging the -init method this way, we help ensure we all use the same
 master -init method -- we get a compiler warning if our other -init methods
 don't call this one.  Hopefully, this helps ensure that we initialize all
 properties consistently and safely.
 */
- (instancetype) init NS_DESIGNATED_INITIALIZER;

@end


@implementation APCTaskGroup

/**
 Set global, static values the first time anyone calls this class.

 By definition, this method is called once per class, in a thread-safe
 way, the first time the class is sent a message -- basically, the first
 time we refer to the class.  That means we can use this to set up stuff
 that applies to all objects (instances) of this class.

 Documentation:  See +initialize in the NSObject Class Reference.  Currently, that's here:
 https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSObject_Class/index.html#//apple_ref/occ/clm/NSObject/initialize
 */
+ (void) initialize
{
    sortDescriptorsForSortingScheduledTasksByCompletionDate = @[[NSSortDescriptor sortDescriptorWithKey: NSStringFromSelector (@selector (updatedAt))
                                                                                              ascending: YES]];

    debugDateFormatter = [NSDateFormatter new];
    debugDateFormatter.dateFormat = kAPCDebugDateFormat;
    debugDateFormatter.timeZone = [NSTimeZone localTimeZone];
}

- (instancetype) init
{
    self = [super init];

    if (self)
    {
        _task = nil;
        _schedule = nil;
        _samplePotentialTask = nil;
        _requiredRemainingTasks = nil;
        _requiredCompletedTasks = nil;
        _gratuitousCompletedTasks = nil;
        _totalRequiredTasksForThisTimeRange = 0;
        _scheduledDate = nil;
        _appearanceDate = nil;
        _expirationDate = nil;
        _expiresToday = NO;
    }

    return self;
}

- (instancetype)       initWithTask: (APCTask *) task
                           schedule: (APCSchedule *) schedule
    requiredRemainingPotentialTasks: (NSArray *) requiredRemainingTasks
             requiredCompletedTasks: (NSArray *) requiredCompletedTasks
           gratuitousCompletedTasks: (NSArray *) gratuitousCompletedTasks
                samplePotentialTask: (APCPotentialTask *) samplePotentialTask
                 totalRequiredTasks: (NSUInteger) countOfRequiredTasks
                   forScheduledDate: (NSDate *) scheduledDate
                     appearanceDate: (NSDate *) appearanceDate
                     expirationDate: (NSDate *) expirationDate
{
    self = [self init];

    if (self)
    {
        _task = task;
        _schedule = schedule;
        _samplePotentialTask = samplePotentialTask;
        _requiredRemainingTasks = requiredRemainingTasks;
        _requiredCompletedTasks = requiredCompletedTasks;
        _gratuitousCompletedTasks = gratuitousCompletedTasks;
        _totalRequiredTasksForThisTimeRange = countOfRequiredTasks;
        _scheduledDate = scheduledDate;
        _appearanceDate = appearanceDate;
        _expirationDate = expirationDate;

        _expiresToday = _expirationDate != nil && [_expirationDate.startOfDay isEqualToDate: _appearanceDate.startOfDay];
    }

    return self;
}

- (BOOL) hasAnyCompletedTasks
{
    return self.requiredCompletedTasks.count + self.gratuitousCompletedTasks.count > 0;
}

- (BOOL) isFullyCompleted
{
    return self.requiredCompletedTasks.count >= self.totalRequiredTasksForThisTimeRange;
}

- (NSArray *) allCompletedTasks
{
    NSMutableArray *result = [NSMutableArray new];

    if (self.requiredCompletedTasks.count)
    {
        [result addObjectsFromArray: self.requiredCompletedTasks];
    }

    if (self.gratuitousCompletedTasks.count)
    {
        [result addObjectsFromArray: self.gratuitousCompletedTasks];
    }

    [result sortUsingDescriptors: sortDescriptorsForSortingScheduledTasksByCompletionDate];

    return result;
}

- (APCScheduledTask *) latestCompletedTask
{
    return self.allCompletedTasks.lastObject;
}

/**
 This method (formerly a property) is deprecated.  Please see header file
 for details.
 */
- (NSDate *) date
{
    return self.appearanceDate;
}

- (NSDate *) dateFullyCompleted
{
    NSDate *latestCompletionDate = nil;

    for (APCScheduledTask *completedTask in self.requiredCompletedTasks)
    {
        if (latestCompletionDate == nil || [completedTask.updatedAt isLaterThanDate: latestCompletionDate])
        {
            latestCompletionDate = completedTask.updatedAt;
        }
    }

    return latestCompletionDate;
}

- (NSString *) description
{
    NSString *result = nil;

    NSMutableString *dates = [NSMutableString stringWithString: @"dates completed: "];

    if (! self.hasAnyCompletedTasks)
    {
        [dates appendString: @"(none)"];
    }
    else for (APCScheduledTask *scheduledTask in self.allCompletedTasks)
    {
        [dates appendFormat: @"%@, ", scheduledTask.updatedAt];
    }

    result = [NSString stringWithFormat: @"TaskGroup: %@ | %@ | %@ | vcToShow: %@ | %@ | expires today: %@ | tasks: %@ required, %@ completed, %@ remaining, %@ gratuitous completed, most recent completed on %@",
              NSStringShortFromAPCScheduleSourceAsNumber ([self.task.schedules.anyObject scheduleSource]),
              self.task.taskTitle,
              self.task.taskID,
              self.task.taskClassName,
              dates,
              self.expiresToday ? @"YES" : @"NO",
              @(self.totalRequiredTasksForThisTimeRange),
              @(self.requiredCompletedTasks.count),
              @(self.requiredRemainingTasks.count),
              @(self.gratuitousCompletedTasks.count),
              [self debugStringFromDate: self.latestCompletedTask.updatedAt]
              ];

    return result;
}

- (NSComparisonResult) compareWithTaskGroup: (APCTaskGroup *) otherTaskGroup
{
    NSComparisonResult result = NSOrderedSame;

    if (self.task == nil && otherTaskGroup.task == nil)
    {
        result = NSOrderedSame;
    }
    else if (otherTaskGroup.task == nil)
    {
        result = NSOrderedDescending;
    }
    else if (self.task == nil)
    {
        result = NSOrderedAscending;
    }
    else
    {
        NSArray *plainTasks = @[self.task, otherTaskGroup.task];
        NSArray *sortedTasks = [plainTasks sortedArrayUsingDescriptors: [APCTask defaultSortDescriptors]];
        result = sortedTasks.firstObject == self.task ? NSOrderedAscending : NSOrderedDescending;
    }

    return result;
}

/**
 Deprecated method name.  Replaced by
 -totalRequiredTasksForThisTimeRange.
 */
- (NSUInteger) countOfRequiredTasksForThisTimeRange
{
    return self.totalRequiredTasksForThisTimeRange;
}

- (NSString *) debugStringFromDate: (NSDate *) date
{
    NSString *result = @"(null)";

    if (date != nil)
    {
        result = [debugDateFormatter stringFromDate: date];
    }

    return result;
}

@end
