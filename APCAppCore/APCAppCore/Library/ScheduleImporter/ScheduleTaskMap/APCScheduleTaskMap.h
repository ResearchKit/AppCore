//
//  APCScheduleTaskMap.h
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
@class APCScheduleTaskMapEntry;
@class APCSchedule;
@class APCTask;


/**
 Maps task IDs to a single task and schedule.  Lets us quickly access
 (and re-access) the schedules and tasks associated with a task ID.

 There are two basic ways to use this:
 
 1) Initialize it with -init.  Then fill it with individual
    APCScheduleTaskMapEntry objects:
 
 @code
 [myMap setEntry: someEntry forTaskId: someTask.taskID];
 @endcode

 2) Initialize it with -initWithSetOfSchedules:.  This simply iterates through
    the APCSchedule objects in a set, and their APCTasks, creating an Entry for
    each tuple of (task ID, task, schedule).
 */
@interface APCScheduleTaskMap : NSObject


/**
 Returns the number of entries in this map.
 */
@property (readonly) NSUInteger count;

/**
 Initializes this map with safe values.  After doing this, you can
 manually add APCScheduleTaskEntries using -setEntry:forTaskId:.
 
 @see -initWithSetOfSchedules:
 @see -setEntry:forTaskId:
 */
- (instancetype) init NS_DESIGNATED_INITIALIZER;

/**
 Initializes this map with the specified set of APCSchedule objects.  Walks
 through the schedules and the APCTasks inside each schedule, creating an
 APCScheduleTaskMapEntry for each tuple of (task ID, task, schedule), and
 adding those entries to this map.

 Internally, simply stores the task ID and the new Entry in our internal
 NSDictionary.
 */
- (instancetype) initWithSetOfSchedules: (NSSet *) schedules;

/**
 Returns YES if the map contains an APCScheduleTaskMapEntry for the
 specified task ID, NO otherwise.
 */
- (BOOL) containsTaskId: (NSString *) taskId;

/**
 Returns the entry mapped to the specified task ID, or nil
 if the task ID is not in this map.
 
 @see -setEntry:forTaskId:
 */
- (APCScheduleTaskMapEntry *) entryForTaskId: (NSString *) taskId;

/**
 Maps the specified task ID to the specified entry (by simply 
 calling -setObject:forKey: on the internal NSDictionary).
 Has no effect if either taskID or entry is nil.
 */
- (void) setEntry: (APCScheduleTaskMapEntry *) entry
        forTaskId: (NSString *) taskId;

/**
 Retrieves the APCScheduleTaskMapEntry for the specified task ID, and returns
 its -schedule property.  Returns nil if taskId is nil, empty, or not in this
 map.
 */
- (APCSchedule *) scheduleForTaskId: (NSString *) taskId;

/**
 Retrieves the APCScheduleTaskMapEntry for the specified task ID, and returns
 its -task property.  Returns nil if taskId is nil, empty, or not in this map.
 */
- (APCTask *) taskForTaskId: (NSString *) taskId;

@end
