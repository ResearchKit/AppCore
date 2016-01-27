//
//  MockAPCTasksReminderManager.m
//  APCAppCore
//
//  Created by Michael L DePhillips on 1/26/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
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

- (NSTimeZone*) timeZone
{
    return [NSTimeZone defaultTimeZone];
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
