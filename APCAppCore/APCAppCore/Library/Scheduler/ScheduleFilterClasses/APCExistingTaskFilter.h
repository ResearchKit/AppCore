//
//  APCExistingTaskFilter.h
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
 Splits a set of schedules into two subsets:  those whose task IDs already
 exist in CoreData -- meaning, a task with that ID has already appeared on
 this device, at some point in the past -- and those whose task IDs are
 brand-new.  The former are returned in -passed; the latter are returned in
 -failed.  If a schedule contains even one task whose ID is in CoreData,
 it will appear in -passed.

 Allows us to know whether to blindly accept a new schedule (i.e., if it's
 referring to brand-new tasks) or whether we have to compare it to other
 schedules before accepting it.
 */
@interface APCExistingTaskFilter : APCScheduleFilter


/**
 Splits a set of schedules into two subsets:  those whose task IDs already
 exist in CoreData -- meaning, a task with that ID has already appeared on
 this device, at some point in the past -- and those whose task IDs are
 brand-new.  The former are returned in -passed; the latter are returned in
 -failed.  If a schedule contains even one task whose ID is in CoreData,
 it will appear in -passed.

 @param setOfSchedules  The schedules whose tasks we wish to search for.

 @param mapOfTheseTaskIdsToSavedTasksAndSchedules  A taskID-schedule-task map
 containing the task IDs in setOfSchedules mapped to existing, saved tasks and
 schedules.
 */
- (void) split: (NSSet *) setOfSchedules
       withMap: (APCScheduleTaskMap *) mapOfTheseTaskIdsToSavedTasksAndSchedules;

@end
