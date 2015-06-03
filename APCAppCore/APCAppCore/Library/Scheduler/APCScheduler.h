// 
//  APCScheduler.h 
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
#import <UIKit/UIKit.h>
#import "APCConstants.h"

@class APCDataSubstrate;
@class APCSchedule;
@class APCDateRange;
@class APCTask;
@class APCScheduledTask;
@class APCPotentialTask;

typedef NS_ENUM(NSUInteger, APCSchedulerDateRange) {
    kAPCSchedulerDateRangeYesterday,
    kAPCSchedulerDateRangeToday,
    kAPCSchedulerDateRangeTomorrow
};

typedef enum : NSUInteger {
    APCDateGroupInstants,
    APCDateGroupHours,
    APCDateGroupDays,
} APCDateGroup;


typedef void (^APCSchedulerCallbackForTaskGroupQueries) (NSDictionary *taskGroups, NSError *queryError);
typedef void (^APCSchedulerCallbackForFetchAndLoadOperations) (NSError *errorFetchingOrLoading);
typedef void (^APCSchedulerCallbackForFetchingCount) (NSUInteger count, NSError *errorFetchingOrLoading);


/**
 Manages tasks and schedules.
 
 Specifically, manages the processes of downloading 
 tasks and schedules, merging them with existing ones,
 figuring out which ones are "active" or "current,"
 figuring out which to display on a given day in 
 the future or past.  Maintains a cache of the query
 results for each type of query, because each query
 is actually time-consuming:  we not only pull
 stuff from CoreData, but do a fair amount of math
 to figure out how to project schedules onto a
 human calendar.
 
 Please note.  As of this writing, this class contains
 a bunch of code that should be distributed across
 other classes.  It was easier to develop the logic
 for all those pieces if I could physically see them on
 one screen.  Having done that, we should be able to
 fairly easily redistribute the pieces to other,
 appropriate classes.  Before this, all these pieces
 had evolved in place, and it showed.
 */
@interface APCScheduler : NSObject

- (instancetype) initWithDataSubstrate: (APCDataSubstrate*) dataSubstrate;

@property (nonatomic, strong) APCDateRange * referenceRange;


+ (APCScheduler *) defaultScheduler;

/*
 This is not as generic as it looks:  it groups the tasks
 for each day into specific subtypes, and within a given day,
 does not sort (or group) by date.  If needed, we'll add such
 overrides later.
 */
- (void) fetchTaskGroupsFromDate: (NSDate *) startDate
                          toDate: (NSDate *) endDate
                      usingQueue: (NSOperationQueue *) queue
                 toReportResults: (APCSchedulerCallbackForTaskGroupQueries) callbackBlock;

- (void) fetchTaskGroupsFromDate: (NSDate *) startDate
                          toDate: (NSDate *) endDate
          forTasksMatchingFilter: (NSPredicate *) taskFilter
                      usingQueue: (NSOperationQueue *) queue
                 toReportResults: (APCSchedulerCallbackForTaskGroupQueries) callbackBlock;


/** Exposes an internal property.  Not at all sure I should. */
- (NSManagedObjectContext *) managedObjectContext;

- (void) fetchTasksAndSchedulesFromServerAndThenUseThisQueue: (NSOperationQueue *) queue
                                            toDoThisWhenDone: (APCSchedulerCallbackForFetchAndLoadOperations) callbackBlock;

- (void) loadTasksAndSchedulesFromDiskAndThenUseThisQueue: (NSOperationQueue *) queue
                                         toDoThisWhenDone: (APCSchedulerCallbackForFetchAndLoadOperations) callbackBlock;

- (void) importScheduleFromDictionary: (NSDictionary *) scheduleContainingTasks
                      assigningSource: (APCScheduleSource) scheduleSource
                  andThenUseThisQueue: (NSOperationQueue *) queue
                     toDoThisWhenDone: (APCSchedulerCallbackForFetchAndLoadOperations) callbackBlock;

- (APCScheduledTask *) createScheduledTaskFromPotentialTask: (APCPotentialTask *) potentialTask;

/**
 Used, for example, when deleting a task that the user cancelled.
 In the new version of the world, we only save ScheduledTasks when
 the user actually does something with them.  Ideally, we wouldn't
 even create them until the user did something permanent-ish.
 */
- (void) deleteScheduledTask: (APCScheduledTask *) scheduledTask;

/**
 Used for debugging and testing.  Inside this class, everything that
 wants to access the system date uses this property.  This allows you
 to create schedules as if they had arrived at a specific date in the
 future or the past, and then change your view independently.
 
 Call -clearFakeSystemDate to make it use the actual system date
 (or set this property to nil).

 In a release build, this feature is disabled, and always returns
 the system date.
 */
@property (nonatomic, strong) NSDate *fakeSystemDate;

/**
 Sets the -fakeSystemDate property to nil, making the scheduler
 use the underlying system date for all calculations.  See
 -fakeSystemDate for more information.
 */
- (void) clearFakeSystemDate;


@end






















