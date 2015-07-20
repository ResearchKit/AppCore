//
//  APCCompletedOneTimeTaskFilter.h
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

#import "APCScheduleFilter.h"
@class APCScheduleTaskMap;


/**
 Splits a set of schedules into two subsets:  those whose task IDs
 refer to "completed, one-time tasks," and those which don't.

 A "completed, one-time task" is a task whose most recent schedule
 is a one-time schedule (its type is "once"), and for which that task
 has been performed by the user at least once.  Such tasks represent
 a special conceptual category:  stuff which the researchers want the
 users to perform exactly once, such as a sign-up survey.
 
 Schedules that have at least one task referring to a completed
 one-time task will be returned in -passed.  Other schedules will be
 returned in -failed.
 */
@interface APCCompletedOneTimeTaskFilter : APCScheduleFilter


/**
 Splits a set of schedules into two subsets:  those whose task IDs
 refer to "completed, one-time tasks," and those which don't.

 A "completed, one-time task" is a task whose most recent schedule
 is a one-time schedule (its type is "once"), and for which that task
 has been performed by the user at least once.  Such tasks represent
 a special conceptual category:  stuff which the researchers want the
 users to perform exactly once, such as a sign-up survey.

 Schedules that have at least one task referring to a completed
 one-time task will be returned in -passed.  Other schedules will be
 returned in -failed.

 @param setOfSchedules  The schedules to split.

 @param mapOfTheseTaskIdsToSavedTasksAndMostRecentSchedules  A taskID-schedule-task
 map containing the task IDs in setOfSchedules mapped to existing, saved tasks with
 the IDs mentioned in setOfSchedules, and the most recent, saved schedule for each
 of those tasks.
 */
- (void) split: (NSSet *) setOfSchedules
       withMap: (APCScheduleTaskMap *) mapOfTheseTaskIdsToSavedTasksAndMostRecentSchedules;

@end
