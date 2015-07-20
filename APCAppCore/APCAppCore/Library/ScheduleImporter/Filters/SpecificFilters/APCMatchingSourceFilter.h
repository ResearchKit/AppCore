//
//  APCMatchingSourceFilter.h
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
 Splits a set of schedules into two subsets:  those which have
 the same ScheduleSource as a schedule in a map of schedules
 controlling the same task IDs, and those which don't.  Returns
 a third set as well:  schedules whose tasks weren't (all) in
 the map.
 
 Allows us to filter schedules according to the schedules which
 have the right to control each other.
 */
@interface APCMatchingSourceFilter : APCScheduleFilter


/**
 Splits a set of schedules into two subsets:  those which have
 the same ScheduleSource as a schedule in a map of schedules
 controlling the same task IDs, and those which don't.  Returns
 a third set as well:  schedules whose tasks weren't (all) in
 the map.

 Here's an example:
 
 Let's say that setOfSchedules contains three schedules, all from the server:
 (1)  a schedule for a task called "walk the dog," with task ID "walkTheDog"
 (2)  a schedule for a task called "go for a walk," with task ID "goForAWalk"
 (3)  a schedule for a task called "go to sleep," with task ID "goToSleep"
 
 Let's say that the map contains only two schedules, from different sources,
 and does not contain an entry for "goToSleep":
 (4)  a schedule for a task "walkTheDog," source == server
 (5)  a schedule for a task "goForAWalk," source == disk
 
 This method splits setOfSchedules into 3 subsets:

 -  -passed will contain the schedule for walkTheDog,
    because (1) is from the same source as (4)

 -  -failed will contain the schedule for goForAWalk,
    because (2) is from a different source than (5)

 -  -unknown will contain the schedule for goToSleep,
    because goToSleep is not in the map (there's no item 6)

 @param setOfSchedules  The set of schedules to split.
 @param map             A mapping of task IDs to tasks and schedules.
 */
- (void) split: (NSSet *) setOfSchedules
       withMap: (APCScheduleTaskMap *) map;

/**
 See -split:withMap: for description and example.
 */
@property (readonly) NSSet *unknown;

@end
