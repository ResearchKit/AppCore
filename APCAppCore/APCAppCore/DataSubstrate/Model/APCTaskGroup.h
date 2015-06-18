//
//  APCTaskGroup.h
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

#import <Foundation/Foundation.h>
@class APCTask;
@class APCPotentialTask;
@class APCScheduledTask;


/**
 Represents everything we know about a single Task --
 something the user can do -- on a given day:
 
 - how many times the user has done that task
 - links to the data representing the stuff the user has
   already done
 - the number of times the task's Schedule says the user
   should do that task
 - links to objects we can use to generate more user data
   for that task
 */
@interface APCTaskGroup : NSObject

/**
 The Task mentioned by all everything else in this group.
 A Task is our main template for "something the user
 should do." Other properties on this Group reflect
 different aspects of that to-do concept: stuff that's
 already been done, stuff that could be done at a specific
 date and time, etc.
 */
@property (nonatomic, strong) APCTask *task;

/**
 An array of PotentialTask objects representing both
 the number of remaining required tasks for this user,
 and the times of day, if any, that those tasks should
 be done.
 */
@property (nonatomic, strong) NSArray *requiredRemainingTasks;

/**
 An array of ScheduledTask objects that have been marked
 as "completed," which match the times required by the
 attached Schedule.
 */
@property (nonatomic, strong) NSArray *requiredCompletedTasks;

/** 
 An array of ScheduledTask objects that have been marked
 as "completed," which the user did without being required
 to do so, within the specified time range.
 */
@property (nonatomic, strong) NSArray *gratuitousCompletedTasks;

/**
 Returns the combination of -requiredCompletedTasks and
 -gratuitousCompletedTasks, sorted by date completed, such
 that the most recent completed task is the last object
 in the array.
 
 @see latestCompletedTask
 @see requiredCompletedTasks
 @see gratuitousCompletedTasks
 */
@property (readonly) NSArray *allCompletedTasks;

/**
 Returns the most recent task completed by the user on
 this date, regardless of whether it was required or
 gratuitous.  I.e., it returns the last object in the
 -allCompletedTasks array.
 
 @see allCompletedTasks
 */
@property (readonly) APCScheduledTask *latestCompletedTask;

/**
 YES if there are any completed tasks in this TaskGroup
 (i.e., for this date), whether required or gratuitous.
 NO otherwise.
 */
@property (readonly) BOOL hasAnyCompletedTasks;

/**
 A sample PotentialTask you can use to create new
 ScheduledTasks, and open the matching ViewController.
 Use this if there are no more requiredRemainingTasks,
 but the user still needs/wants to do one.
 */
@property (nonatomic, strong) APCPotentialTask *samplePotentialTask;

/**
 An integer reporting how many instances of this task were
 required for this date range.  This number will report the
 total number that should have occurred, while the
 -completedTasks and -requiredRemainingTasks will contain a
 continuously-variable number of tasks, based on what has
 in fact been accomplished.
 */
@property (nonatomic, assign) NSUInteger totalRequiredTasksForThisTimeRange;

/**
 Former name for totalRequiredTasksForThisTimeRange.
 Please use -totalRequiredTasksForThisTimeRange instead.
 */
@property (readonly) NSUInteger countOfRequiredTasksForThisTimeRange __attribute__((deprecated("Please use -totalRequiredTasksForThisTimeRange instead.")));

/**
 The day whose midnight-to-midnight is represented by the
 contents of this group.
 */
@property (nonatomic, strong) NSDate *date;

/**
 Returns YES if -requiredCompletedTasks.count is greater
 than -countOfRequiredTasksForThisTimeRange.
 */
@property (readonly) BOOL isFullyCompleted;

/**
 Returns the date this group was fully completed -- the
 latest "date updated" in the list of
 requiredCompletedTasks.
 */
@property (readonly) NSDate *dateFullyCompleted;

- (NSComparisonResult) compareWithTaskGroup: (APCTaskGroup *) otherTaskGroup;

- (instancetype)       initWithTask: (APCTask *) task
    requiredRemainingPotentialTasks: (NSArray *) requiredRemainingTasks
             requiredCompletedTasks: (NSArray *) requiredCompletedTasks
           gratuitousCompletedTasks: (NSArray *) gratuitousCompletedTasks
                samplePotentialTask: (APCPotentialTask *) samplePotentialTask
                 totalRequiredTasks: (NSUInteger) countOfRequiredTasks
                            forDate: (NSDate *) date;

@end
