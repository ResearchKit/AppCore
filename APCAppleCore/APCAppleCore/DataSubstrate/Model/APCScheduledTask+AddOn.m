//
//  APCScheduledTask+AddOn.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCScheduledTask+AddOn.h"
#import "APCAppleCore.h"

static NSInteger kSecondsPerMinute = 60;
static NSInteger kDefaultReminderOffset = -15;

static NSString * const kScheduledTaskIDKey = @"scheduledTaskID";

@implementation APCScheduledTask (AddOn)

- (void)completeScheduledTask
{
    self.completed = @(YES);
    
    //Turn off one time schedule
    if ([self.generatedSchedule isOneTimeSchedule])
    {
        self.generatedSchedule.inActive = @(YES);
    }
    NSError * saveError;
    [self saveToPersistentStore:&saveError];
    [saveError handle];
}

- (void) createLocalNotification
{
    //TODO: to be done
}

- (void) deleteLocalNotification
{
    //TODO: to be done
}

- (void) deleteScheduledTask
{
    [self deleteLocalNotification];
    [self.managedObjectContext deleteObject:self];
    NSError * saveError;
    [self saveToPersistentStore:&saveError];
    [saveError handle];
}

- (NSString *)completeByDateString
{
    return [self.endOn friendlyDescription];
}

+ (NSArray*) APCActivityVCScheduledTasks: (BOOL) tomorrow inContext: (NSManagedObjectContext*) context
{
    NSArray * array1 =  tomorrow ? [self allScheduledTasksForTomorrowInContext:context] : [self allScheduledTasksForTodayInContext:context];
    NSArray * array2 = [self allIncompleteTasksForPastWeekFrom:tomorrow InContext:context];
    NSMutableArray * finalArray = [NSMutableArray array];
    if (array1.count) {
        [finalArray addObjectsFromArray:array1];
    }
    if (array2.count) {
        [finalArray addObjectsFromArray:array2];
    }
    return finalArray.count ? finalArray : nil;
}

+ (NSArray *)allScheduledTasksForTodayInContext: (NSManagedObjectContext*) context
{
    NSFetchRequest * request = [APCScheduledTask request];
    
    //TODO: Support multiday
    request.predicate = [NSPredicate predicateWithFormat:@"startOn >= %@ && endOn < %@", [NSDate todayAtMidnight], [NSDate tomorrowAtMidnight]];
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startOn" ascending:YES];
    request.sortDescriptors = @[dateSortDescriptor];
    NSError * error;
    NSArray * array = [context executeFetchRequest:request error:&error];
    [error handle];
    return array.count ? array : nil;
}

+ (NSArray *)allScheduledTasksForTomorrowInContext: (NSManagedObjectContext*) context
{
    NSFetchRequest * request = [APCScheduledTask request];
    
    //TODO: Support multiday
    request.predicate = [NSPredicate predicateWithFormat:@"startOn >= %@ && endOn < %@", [NSDate tomorrowAtMidnight], [NSDate startOfTomorrow:[NSDate tomorrowAtMidnight]]];
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startOn" ascending:YES];
    request.sortDescriptors = @[dateSortDescriptor];
    NSError * error;
    NSArray * array = [context executeFetchRequest:request error:&error];
    [error handle];
    return array.count ? array : nil;
}

+ (NSArray* ) allIncompleteTasksForPastWeekFrom: (BOOL) tomorrow InContext: (NSManagedObjectContext*) context
{
    NSFetchRequest * request = [APCScheduledTask request];
    NSDate * startDate = tomorrow ? [[NSDate tomorrowAtMidnight] dateByAddingDays:-7] : [[NSDate todayAtMidnight] dateByAddingDays:-7];
    NSDate * endDate = tomorrow ? [NSDate tomorrowAtMidnight] : [NSDate todayAtMidnight];
    //TODO: Support multiday
    request.predicate = [NSPredicate predicateWithFormat:@"(completed == nil || completed == %@) && (endOn > %@ && endOn <= %@)", @(NO), startDate, endDate];
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startOn" ascending:YES];
    request.sortDescriptors = @[dateSortDescriptor];
    NSError * error;
    NSArray * array = [context executeFetchRequest:request error:&error];
    [error handle];
    return array.count ? array : nil;
}

+ (instancetype) scheduledTaskForStartOnDate: (NSDate *) startOn schedule: (APCSchedule*) schedule inContext: (NSManagedObjectContext*) context
{
    NSFetchRequest * request = [APCScheduledTask request];
    request.predicate = [NSPredicate predicateWithFormat:@"startOn == %@ && generatedSchedule == %@", startOn, schedule];
    NSError * error;
    NSArray * array = [context executeFetchRequest:request error:&error];
    [error handle];
    return array.count ? [array firstObject] : nil;
}


/*********************************************************************************/
#pragma mark - Life Cycle Methods
/*********************************************************************************/
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveValue:[NSDate date] forKey:@"createdAt"];
    [self setPrimitiveValue:[NSUUID UUID].UUIDString forKey:@"uid"];
}

- (void)willSave
{
    [self setPrimitiveValue:[NSDate date] forKey:@"updatedAt"];
}


/*********************************************************************************/
#pragma mark - Local Notification
/*********************************************************************************/

- (void)scheduleReminderIfNecessary
{
    if ([self.generatedSchedule.shouldRemind boolValue]) {
        [self clearCurrentReminderIfNecessary];
        // Schedule the notification
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        NSTimeInterval reminderOffset = self.generatedSchedule.reminderOffset ? (NSTimeInterval)[self.generatedSchedule.reminderOffset doubleValue] : kDefaultReminderOffset * kSecondsPerMinute;
        localNotification.fireDate = [self.startOn dateByAddingTimeInterval: reminderOffset];
        localNotification.alertBody = self.generatedSchedule.reminderMessage;
        
        //TODO: figure out how the badge numbers are going to be set.
        //localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        
        NSMutableDictionary *notificationInfo = [[NSMutableDictionary alloc] init];
        notificationInfo[kScheduledTaskIDKey] = self.uid;
        localNotification.userInfo = notificationInfo;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}


+ (void)clearAllReminders
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    [eventArray enumerateObjectsUsingBlock:^(UILocalNotification * obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *userInfoCurrent = obj.userInfo;
        if (userInfoCurrent[kScheduledTaskIDKey]) {
            [app cancelLocalNotification:obj];
        }
    }];
}

- (void)clearCurrentReminderIfNecessary
{
    UILocalNotification * currentReminder = [self currentReminder];
    UIApplication *app = [UIApplication sharedApplication];
    [app cancelLocalNotification:currentReminder];
}

- (UILocalNotification *) currentReminder
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    __block UILocalNotification * retValue;
    [eventArray enumerateObjectsUsingBlock:^(UILocalNotification * obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *userInfoCurrent = obj.userInfo;
        if ([userInfoCurrent[kScheduledTaskIDKey] isEqualToString:self.uid]) {
            retValue = obj;
        }
    }];
    return retValue;
}

@end
