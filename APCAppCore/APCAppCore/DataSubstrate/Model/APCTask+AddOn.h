// 
//  APCTask+AddOn.h 
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
 
#import "APCTask.h"

@protocol ORKTask;
@interface APCTask (AddOn)

/**
 Simple, statically-allocated list of sort descriptors we use in various
 places to ensure tasks always appear on the screen, and in debug statements,
 in the same sequence.
 */
+ (NSArray *) defaultSortDescriptors;

/**
 Runs a CoreData query in the specified context, using that context's operation
 queue, to retrieve a task with the specified ID.  Returns nil if there was an
 error, or if there was no task with such an ID.
 */
+ (APCTask *) taskWithTaskID: (NSString *) taskID
                   inContext: (NSManagedObjectContext *) context;

/**
 Returns all *saved* tasks whose task ID is in the specified set of task IDs.
 Meaning:  tasks that are in the process of being inserted into CoreData are
 skipped.  Uses the specified context to run the query.  This query runs on the
 calling method's thread.  Returns nil on error.
 */
+ (NSSet *) querySavedTasksWithTaskIds: (NSSet *) setOfTaskIds
                          usingContext: (NSManagedObjectContext *) context;

/**
 Stores and retrieves the binary, encoded content of the
 survey itself represented by this task.
 
 The data is stored in CoreData as an NSData blob.
 */
@property (nonatomic, strong) id<ORKTask> rkTask;

/**
 Sorts my schedules by their -startsOn field, and returns the first
 resulting object.  Ignores temporary schedules (i.e., schedules in
 the process of being imported).
 */
@property (readonly) APCSchedule *mostRecentSchedule;

@end
