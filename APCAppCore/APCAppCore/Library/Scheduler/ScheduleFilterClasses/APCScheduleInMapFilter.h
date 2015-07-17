//
//  APCScheduleInMapFilter.h
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
#import "APCScheduleTaskMap.h"


/**
 Splits setOfSchedules into two subsets:  schedules containing tasks
 whose IDs ARE mentioned in the specified map of schedules, and those
 whose tasks are NOT mentioned in that map.
 
 Lets us quickly and easily find incoming schedules whose task are
 currently running, and currently-running schedules whose tasks have
 been mentioned in a download.
 */
@interface APCScheduleInMapFilter : APCScheduleFilter


/**
 Splits setOfSchedules into two subsets:  schedules containing tasks
 whose IDs ARE mentioned in the specified map of schedules (-passed),
 and those whose tasks are NOT mentioned in that map (-failed).

 @param setOfSchedules  Some set of APCSchedule objects.
 
 @param map  A "schedule/task map" which maps a specific task ID to
 a specific task and schedule.
 */
- (void) split: (NSSet *) setOfSchedules
       withMap: (APCScheduleTaskMap *) map;

@end
