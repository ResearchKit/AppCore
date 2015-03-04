// 
//  APCScheduledTask+AddOn.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCScheduledTask.h"
#import "APCDateRange.h"

@class UILocalNotification;
@interface APCScheduledTask (AddOn)

- (void) completeScheduledTask;
- (void) deleteScheduledTask;
- (BOOL)removeScheduledTask:(NSError **)taskError;

@property (nonatomic, readonly) APCResult* lastResult;

@property (nonatomic, readonly) NSString * completeByDateString;

+ (NSDictionary*) APCActivityVCScheduledTasksInContext: (NSManagedObjectContext*) context;
+ (instancetype) scheduledTaskForStartOnDate: (NSDate *) startOn schedule: (APCSchedule*) schedule inContext: (NSManagedObjectContext*) context;

+ (NSArray *)allScheduledTasksForDateRange: (APCDateRange*) dateRange completed: (NSNumber*) completed inContext: (NSManagedObjectContext*) context;
/*********************************************************************************/
#pragma mark - Counts
/*********************************************************************************/
+ (NSUInteger)countOfAllScheduledTasksTodayInContext: (NSManagedObjectContext*) context;
+ (NSUInteger)countOfAllCompletedTasksTodayInContext: (NSManagedObjectContext*) context;

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
@property (nonatomic, strong) APCDateRange * dateRange;

@end
