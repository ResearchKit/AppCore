//
//  Scheduler.h
//  APCAppleCore
//
//  Created by Justin Warmkessel on 8/27/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class APCDataSubstrate;
@class APCSchedule;

@interface APCScheduler : NSObject

- (instancetype)initWithDataSubstrate: (APCDataSubstrate*) dataSubstrate;
- (void)updateScheduledTasks;

- (void)clearNotificationActivityType:(NSString *)taskType;
- (void)clearAllScheduledTaskNotifications;
- (BOOL)scheduleUpdated:(APCSchedule *)schedule;
- (void)createScheduledTask:(APCSchedule *)schedule;
- (void)scheduleLocalNotification:(NSString *)message withDate:(NSDate *)dueOn withTaskType:(NSString *)taskType withAPCScheduleTaskId:(NSString *)objectUID andReminder:(int)reminder;

@end

