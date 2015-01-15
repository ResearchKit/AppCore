// 
//  APCScheduledTask+AddOn.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCScheduledTask.h"

@class UILocalNotification;
@interface APCScheduledTask (AddOn)

- (void) completeScheduledTask;
- (void) deleteScheduledTask;
@property (nonatomic, readonly) APCResult* lastResult;

@property (nonatomic, readonly) NSString * completeByDateString;

+ (NSArray*) APCActivityVCScheduledTasksInContext: (NSManagedObjectContext*) context;
+ (instancetype) scheduledTaskForStartOnDate: (NSDate *) startOn schedule: (APCSchedule*) schedule inContext: (NSManagedObjectContext*) context;

/*********************************************************************************/
#pragma mark - Reminder 
/*********************************************************************************/
- (void)scheduleReminderIfNecessary;
- (void)clearCurrentReminderIfNecessary;
- (UILocalNotification *) currentReminder;

+ (void)clearAllReminders;

/*********************************************************************************/
#pragma mark - Multiday Tasks
/*********************************************************************************/
@property (nonatomic, readonly) BOOL isMultiDayTask;

@end
