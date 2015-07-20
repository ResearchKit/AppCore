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
#import "APCScheduleQueryEngine.h"

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



typedef void (^APCSchedulerCallbackForTaskGroupQueries) (NSDictionary *taskGroups, NSError *queryError);
typedef void (^APCSchedulerCallbackForFetchAndLoadOperations) (NSError *errorFetchingOrLoading);
typedef void (^APCSchedulerCallbackForFetchingCount) (NSUInteger count, NSError *errorFetchingOrLoading);



/**
 Manages tasks and schedules.
 
 Specifically, manages the processes of downloading tasks
 and schedules, merging them with existing ones, figuring
 out which ones are active on a given day, and figuring out
 which to display on a given day, whether present, past, or
 future.  Maintains a cache of the query results for each
 type of query, because each query is time-consuming: we
 not only pull stuff from CoreData, but do a fair amount of
 math to figure out how to map schedules onto a human
 calendar.
 
 Combines features formerly in several other classes, so
 we can see and debug them in the same place.  These
 features are those which either query or manipulate 
 tasks, schedules, PotentialTasks, and some aspects of
 ScheduledTasks.

 In former versions of the app, tasks were "scheduled" out
 into the future, based on their projected dates of
 appearance.  When their schedules changed, those
 ScheduledTask objects were modified.  This new Scheduler
 class represents a different paradigm: instead of
 scheduling tasks into the future, we simply maintain a
 Schedule -- a set of rules about when tasks should appear
 on a user's calendar.  Whenever we want to display the
 calendar, we query the schedule.  Only when the user wants
 to actually *perform* one of those tasks do we create a
 ScheduledTask object representing the task being performed
 and/or completed, and if the user cancels the task, we
 delete that ScheduledTask.
 */
@interface APCScheduler : NSObject <APCScheduleQueryEngine>

+ (APCScheduler *) defaultScheduler;

@property (nonatomic, strong) APCDateRange * referenceRange;

@property (readonly) NSManagedObjectContext * managedObjectContext;



// ---------------------------------------------------------
#pragma mark - Setup
// ---------------------------------------------------------

- (instancetype) initWithDataSubstrate: (APCDataSubstrate *) dataSubstrate;



// ---------------------------------------------------------
#pragma mark - Querying
// ---------------------------------------------------------

- (void) fetchTaskGroupsFromDate: (NSDate *) startDate
                          toDate: (NSDate *) endDate
                      usingQueue: (NSOperationQueue *) queue
                 toReportResults: (APCSchedulerCallbackForTaskGroupQueries) callbackBlock;

- (void) fetchTaskGroupsFromDate: (NSDate *) startDate
                          toDate: (NSDate *) endDate
          forTasksMatchingFilter: (NSPredicate *) taskFilter
                      usingQueue: (NSOperationQueue *) queue
                 toReportResults: (APCSchedulerCallbackForTaskGroupQueries) callbackBlock;

- (NSArray *) querySchedulesActiveOnDayOfDate: (NSDate *) date
                                   fromSource: (APCScheduleSource) scheduleSource
                                    inContext: (NSManagedObjectContext *) context
                               returningError: (NSError * __autoreleasing *) errorToReturn;



// ---------------------------------------------------------
#pragma mark - Importing
// ---------------------------------------------------------

- (void) fetchTasksAndSchedulesFromServerAndThenUseThisQueue: (NSOperationQueue *) queue
                                            toDoThisWhenDone: (APCSchedulerCallbackForFetchAndLoadOperations) callbackBlock;

- (void) loadTasksAndSchedulesFromDiskAndThenUseThisQueue: (NSOperationQueue *) queue
                                         toDoThisWhenDone: (APCSchedulerCallbackForFetchAndLoadOperations) callbackBlock;

- (void) loadTasksAndSchedulesFromDiskFileNamed: (NSString *) fileNameWithExtension
                                       inBundle: (NSBundle *) bundle
                                assigningSource: (APCScheduleSource) scheduleSource
                            andThenUseThisQueue: (NSOperationQueue *) queue
                               toDoThisWhenDone: (APCSchedulerCallbackForFetchAndLoadOperations) callbackBlock;

- (void) importScheduleFromDictionary: (NSDictionary *) scheduleContainingTasks
                      assigningSource: (APCScheduleSource) scheduleSource
                  andThenUseThisQueue: (NSOperationQueue *) queue
                     toDoThisWhenDone: (APCSchedulerCallbackForFetchAndLoadOperations) callbackBlock;



// ---------------------------------------------------------
#pragma mark - Converting PotentialTasks to ScheduledTasks
// ---------------------------------------------------------

/**
 We only save ScheduledTasks when the user actually does
 something with them.  The -fetch methods above return
 (among other things) PotentialTask objects which show when
 a user *could* perform a task.  This method lets us
 convert from one of those PotentialTasks to a
 ScheduledTask, representing the user's real work.  Please
 be sure to call -deleteScheduledTask: if the user cancels
 that operation.
 */
- (APCScheduledTask *) createScheduledTaskFromPotentialTask: (APCPotentialTask *) potentialTask;

/**
 ScheduledTasks represent work the user is actually doing.
 If the user cancels a particular task, we want to delete
 the task from the database.  This method lets us do that.
 */
- (void) deleteScheduledTask: (APCScheduledTask *) scheduledTask;



// ---------------------------------------------------------
#pragma mark - Debugging
// ---------------------------------------------------------

/**
 Used for debugging and testing.  Inside this class,
 everything that wants to access the system date uses this
 property.  This allows you to create schedules as if they
 had arrived at a specific date in the future or the past,
 and then change your view independently.

 Call -clearFakeSystemDate to make it use the actual system
 date (or set this property to nil).

 In a release build, this feature is disabled, and always
 returns the system date.
 */
@property (nonatomic, strong) NSDate *fakeSystemDate;

/**
 Sets the -fakeSystemDate property to nil, making the
 scheduler use the real system date for all calculations.
 See -fakeSystemDate for more information.
 */
- (void) clearFakeSystemDate;


@end
