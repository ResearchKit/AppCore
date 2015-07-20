//
//  APCScheduleFilter.h
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

/**
 Abstract superclass of a family of classes which let us split a set of
 APCSchedules into a one or more other sets of schedules by applying a
 customizable set of rules.  Create a different filter class for each
 type of filtration you need to do.

 The class is designed to let you easily plug the output(s) of one filter
 into the inputs of another, making an easy-to-read chain of logic flowing
 from one filter to another.  For example, if we wanted to:
 
 a) filter out some schedules according to the tasks they're managing; then

 b) use a map of some sort to find schedules managing one particular task; and finally

 c) remove duplicates from the stuff which was not on the map
 
 ...we might do that as follows:

 @code
 [taskFilter      split: newSchedules       withTaskId: deadTask.taskID];
 [mapFilter       split: taskFilter.passed  withMap: recentScheduleMap];
 [deDupingFilter  split: mapFilter.failed];

 [scheduleImporter saveSchedules: deDupingFilter.passed];
 @endcode
 
 You define the filters to do whatever sort of customized filtering you need.

 As of this writing (July, 2015), the filters are used in the process of
 importing tasks and schedules into the system, embodying our rules for
 how to merge those tasks and schedules.

 As of this writing (July, 2015), subclasses of this class are expected
 to operate synchronously, on the same thread from which they were called.
 */
@interface APCScheduleFilter : NSObject


/**
 Splits the specified set of schedules into schedules which pass or do not pass
 the filter embodied by a Filter subclass.  Those subsets will be available in
 -passed and -failed, respectively.  Subclasses may provide other subset
 properties, with names more closely tied to the purpose of the subclass.
 Subclasses may also have methods like -split:aroundDate:, -split:usingTasks:,
 etc., letting us supply the filter with extra data to do its filtration.

 The abstract implementation does nothing, and throws an NSAssert when debugging.
 */
- (void) split: (NSSet *) setOfSchedules;

/**
 After you call -split:, this property will contain the set of objects
 which passed this filter.
 
 The abstract implementation returns nil, and throws an NSAssert when debugging.

 @see -failed
 */
@property (readonly) NSSet *passed;

/** 
 After you call -split:, this property will contain the set of objects
 which did not pass this filter.
 
 The abstract implementation returns nil, and throws an NSAssert when debugging.
 
 @see -passed
 */
@property (readonly) NSSet *failed;

@end
