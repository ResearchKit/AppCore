//
//  Scheduler.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 8/27/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//


#import "APCScheduler.h"
#import "APCAppleCore.h"

static NSInteger kReminderMinutesBeforeTask = -15;
static NSInteger kMinutes = 60;

@interface APCScheduler()
@property  (weak, nonatomic)     APCDataSubstrate        *dataSubstrate;
@property  (strong, nonatomic)   NSManagedObjectContext  *scheduleMOC;
@property  (nonatomic) BOOL isUpdating;
@end

@implementation APCScheduler

- (instancetype)initWithDataSubstrate: (APCDataSubstrate*) dataSubstrate
{
    self = [super init];
    if (self) {
        self.dataSubstrate = dataSubstrate;
        self.scheduleMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.scheduleMOC.parentContext = self.dataSubstrate.persistentContext;
    }
    return self;
}

- (void)updateScheduledTasksIfNotUpdating: (BOOL) today
{
    if (!self.isUpdating) {
        self.isUpdating = YES;
        [self updateScheduledTasks: today];
    }
}

- (void) updateScheduledTasks: (BOOL) today
{
    [self.scheduleMOC performBlock:^{
        
        //STEP 1: Update inActive property of schedules based on endOn date.
        
        //STEP 2: Read active schedules: inActive == NO && (startOn == nil || startOn <= currentTime)
        
        //STEP 3: Delete all incomplete tasks for TOMORROW (along with clearing notifications)
        
        //STEP 4: Generate new scheduledTasks based on the active schedules
        
    }];
}


/*********************************************************************************/
#pragma mark - Local Notification Logic
/*********************************************************************************/

- (void)scheduleLocalNotification:(NSString *)message withDate:(NSDate *)dueOn withAPCScheduleTaskId:(NSString *)APCScheduledTaskId andReminder:(int)reminder  {

    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = dueOn;
    localNotification.alertBody = message;
    
    //TODO: figure out how the badge numbers are going to be set.
    //localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    NSMutableDictionary *notificationInfo = [[NSMutableDictionary alloc] init];
    notificationInfo[@"APCScheduledTaskId"] = APCScheduledTaskId;
    
    if (reminder) {
        
        NSTimeInterval reminderInterval = kReminderMinutesBeforeTask * kMinutes;
        
        [dueOn dateByAddingTimeInterval:reminderInterval];
        notificationInfo[@"reminder"] = @"reminder";
    }
    
    localNotification.userInfo = notificationInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


- (void)clearAllScheduledTaskNotifications {
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    
    for (int i=0; i<[eventArray count]; i++) {
        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        
        NSDictionary *userInfoCurrent = oneEvent.userInfo;
        
        //If scheduled task identification exists then it was issued by scheduler and can be deleted
        
        if ( userInfoCurrent[@"scheduledTaskId"] ) {
            [app cancelLocalNotification:oneEvent];
        }
    }
}


- (void)clearNotificationActivityType:(NSString *)taskType {
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    
    for (int i=0; i<[eventArray count]; i++) {
        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        
        NSDictionary *userInfoCurrent = oneEvent.userInfo;
        
        //If scheduled task activity exists then delete
        if ([userInfoCurrent[@"taskType"] isEqualToString:taskType]) {
            [app cancelLocalNotification:oneEvent];
        }
    }
}

@end
