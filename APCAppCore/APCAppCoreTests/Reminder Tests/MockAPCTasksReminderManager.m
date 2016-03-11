//
//  MockAPCTasksReminderManager.m
//  APCAppCore
//
// Copyright (c) 2016, Sage Bionetworks. All rights reserved.
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

#import "MockAPCTasksReminderManager.h"
#import <UIKit/UIKit.h>

@interface APCTasksReminderManager()
- (instancetype)initWithUserDefaultsWithSuiteName:(NSString*)name;
- (NSUserDefaults*) storedDefaults;
@end

@implementation MockAPCTasksReminderManager

- (instancetype) init
{
    self = [super initWithUserDefaultsWithSuiteName:[[NSUUID UUID] UUIDString]];
    [self setAllReminders:YES];
    _scheduledLocalNotification = [@[] mutableCopy];
    return self;
}

- (NSString*) initializeDefaultTime
{
    return @"5:00PM";
}

- (BOOL) notificationsAreEnabled
{
    return @YES;
}

- (void) scheduleLocalNotification:(UILocalNotification*)notification
{
    [self.scheduledLocalNotification addObject:notification];
}

- (void) cancelLocalNotificationsIfExist
{
    [self.scheduledLocalNotification removeAllObjects];
}

- (NSDate*) now
{
    if (self.mockNow == nil)
    {
        self.mockNow = [NSDate new];
    }
    return self.mockNow;
}

- (NSTimeZone*) timeZone
{
    if (self.mockTimeZone == nil)
    {
        self.mockTimeZone = [NSTimeZone defaultTimeZone];
    }
    return self.mockTimeZone;
}

- (void) setAllReminders:(BOOL)on
{
    [[self storedDefaults] setObject:@(on) forKey:kTasksReminderDefaultsOnOffKey];
}

- (void) setReminderKey:(NSString*)reminderKey toOn:(BOOL)on
{
    [[self storedDefaults] setObject:@(on) forKey:reminderKey];
    [[self storedDefaults] synchronize];
}

- (void) addNotificationCategoryIfNeeded
{
    // no implementation
}

- (void) initializeDefaultReminderMessages
{
    // no implementation
}

-(BOOL)includeTaskInReminder:(APCTaskReminder *)taskReminder {
    BOOL includeTask = NO;
    
    //the reminderIdentifier shall be added to NSUserDefaults only when the task reminder is set to ON
    if (![self.storedDefaults objectForKey: taskReminder.taskID]) {
        //the reminder for this task is off
        return includeTask;
    }

    // Instead of the below logic, let's just do a completed dictionary
    return ![self.tasksFullComplete[taskReminder.taskID] boolValue];
//    APCTaskGroup *groupForTaskID;
//    for (APCTaskGroup *group in self.taskGroups) {
//        
//        if ([group.task.taskID isEqualToString:taskReminder.taskID]) {
//            groupForTaskID = group;
//            break;
//        }
//    }
//    
//    if (!groupForTaskID) {
//        includeTask = NO;
//    } else if (!groupForTaskID.isFullyCompleted ) {//if this task has not been completed but was required, include it in the reminder
//        includeTask = YES;
//    }
//    
//    return includeTask;
}

@end
