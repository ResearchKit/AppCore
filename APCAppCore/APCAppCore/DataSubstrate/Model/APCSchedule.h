//
//  APCSchedule.h
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

@class APCScheduledTask, APCTask;

@interface APCSchedule : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * delay;
@property (nonatomic, retain) NSDate * effectiveEndDate;
@property (nonatomic, retain) NSDate * effectiveStartDate;
@property (nonatomic, retain) NSDate * endsOn;
@property (nonatomic, retain) NSString * expires;
@property (nonatomic, retain) NSNumber * inActive;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * reminderMessage;
@property (nonatomic, retain) NSNumber * reminderOffset;
@property (nonatomic, retain) NSNumber * scheduleSource;
@property (nonatomic, retain) NSString * scheduleString;
@property (nonatomic, retain) NSString * scheduleType;
@property (nonatomic, retain) NSNumber * shouldRemind;
@property (nonatomic, retain) NSDate * startsOn;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * interval;
@property (nonatomic, retain) NSString * timesOfDay;
@property (nonatomic, retain) NSNumber * maxCount;
@property (nonatomic, retain) NSSet *scheduledTasks;
@property (nonatomic, retain) NSSet *tasks;
@end

@interface APCSchedule (CoreDataGeneratedAccessors)

- (void)addScheduledTasksObject:(APCScheduledTask *)value;
- (void)removeScheduledTasksObject:(APCScheduledTask *)value;
- (void)addScheduledTasks:(NSSet *)values;
- (void)removeScheduledTasks:(NSSet *)values;

- (void)addTasksObject:(APCTask *)value;
- (void)removeTasksObject:(APCTask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

@end
