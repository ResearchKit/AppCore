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

@property (nonatomic, readonly) NSString * completeByDateString;

+ (NSArray*) APCActivityVCScheduledTasks: (BOOL) tomorrow inContext: (NSManagedObjectContext*) context;
+ (instancetype) scheduledTaskForStartOnDate: (NSDate *) startOn schedule: (APCSchedule*) schedule inContext: (NSManagedObjectContext*) context;

/*********************************************************************************/
#pragma mark - Reminder 
/*********************************************************************************/
- (void)scheduleReminderIfNecessary;
- (void)clearCurrentReminderIfNecessary;
- (UILocalNotification *) currentReminder;

+ (void)clearAllReminders;

@end
