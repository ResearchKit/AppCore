//
//  APCTask.h
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
#import <CoreData/CoreData.h>

@class APCSchedule, APCScheduledTask;

@interface APCTask : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * sortString;
@property (nonatomic, retain) NSString * taskClassName;
@property (nonatomic, retain) NSString * taskCompletionTimeString;
@property (nonatomic, retain) NSString * taskContentFileName;
@property (nonatomic, retain) NSData * taskDescription;
@property (nonatomic, retain) NSString * taskHRef;
@property (nonatomic, retain) NSString * taskID;
@property (nonatomic, retain) NSNumber * taskIsOptional;
@property (nonatomic, retain) NSString * taskTitle;
@property (nonatomic, retain) NSNumber * taskVersionNumber;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *scheduledTasks;
@property (nonatomic, retain) NSSet *schedules;
@end

@interface APCTask (CoreDataGeneratedAccessors)

- (void)addScheduledTasksObject:(APCScheduledTask *)value;
- (void)removeScheduledTasksObject:(APCScheduledTask *)value;
- (void)addScheduledTasks:(NSSet *)values;
- (void)removeScheduledTasks:(NSSet *)values;

- (void)addSchedulesObject:(APCSchedule *)value;
- (void)removeSchedulesObject:(APCSchedule *)value;
- (void)addSchedules:(NSSet *)values;
- (void)removeSchedules:(NSSet *)values;

@end
