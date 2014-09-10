//
//  Scheduler.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 8/27/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//


#import "APCScheduler.h"
#import "APCAppleCore.h"
#import "APCScheduleInterpreter.h"


static NSInteger kMinutes = 60;
static NSInteger APCScheduledTaskNotComplete = 0;
//TODO local notificiation reminders are set to 15 minutes before the task
static NSInteger reminder_minutes_before_task = -15;

typedef NS_ENUM(NSInteger, APCScheduleReminderNotification)
{
    APCScheduleReminderNo = 0,
    APCScheduleReminderYES = 1
};

@interface APCScheduler()

@property  (nonatomic, strong)   NSArray                 *schedules;
@property  (weak, nonatomic)     APCDataSubstrate        *dataSubstrate;
@property  (strong, nonatomic)   APCScheduleInterpreter  *scheduleInterpreter;
@property  (strong, nonatomic)   NSManagedObjectContext  *localMOC;

@end


@implementation APCScheduler

- (instancetype)initWithDataSubstrate: (APCDataSubstrate*) dataSubstrate {
    
    self = [super init];
    if (self) {
        self.dataSubstrate = dataSubstrate;
        self.scheduleInterpreter = [[APCScheduleInterpreter alloc] init];
    }
    return self;
}


- (void)updateScheduledTasks {
    
    self.localMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.localMOC.parentContext = self.dataSubstrate.persistentContext;
    
    [self.localMOC performBlock:^{
        
        //Get APCSchedules from Core Data
        self.schedules = [self schedule];
        
        for(APCSchedule *schedule in self.schedules) {
            
            //Make sure scheduled task is not already created and then create scheduled task
            BOOL isUpdated = [self scheduleUpdated:schedule];
            
            if (!isUpdated) {
                
                [self createScheduledTask:schedule];
                
            }
        }
    }];
}


- (BOOL)scheduleUpdated:(APCSchedule *)schedule {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"APCScheduledTask"
                                              inManagedObjectContext:self.localMOC ];
    [request setEntity:entity];
    
    NSMutableArray *dates = [self.scheduleInterpreter taskDates:schedule.scheduleExpression];
    
    NSDate *dueOn = [dates objectAtIndex:0];
    APCTask *task = schedule.task;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"( dueOn == %@ ) AND ( task.uid == %@ )", dueOn, task.uid];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *array = [self.localMOC executeFetchRequest:request error:&error];
    
    NSAssert(array, @"Core data did not return an array on requesting fetch");
    
    if ([array count] == 0) {
        
        return NO;
    }
    
    return YES;
}


- (NSArray *)schedule {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"APCSchedule"
                                              inManagedObjectContext:self.localMOC];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *array = [self.localMOC executeFetchRequest:request error:&error];
    
    NSAssert(array, @"Core data did not return an array on requesting APCSchedule entities");
    
    return array;
}


- (void)createScheduledTask:(APCSchedule *)schedule {
    
    NSString *scheduleExpression = schedule.scheduleExpression;
    
    NSMutableArray *dates = [self.scheduleInterpreter taskDates:scheduleExpression];
    
    for (NSDate *date in dates) {
     
        APCScheduledTask * scheduledTask = [APCScheduledTask newObjectForContext:self.localMOC];
        
        scheduledTask.completed = [NSNumber numberWithInteger:APCScheduledTaskNotComplete];
        scheduledTask.dueOn = date;
        scheduledTask.task = schedule.task;
        
        //Get the APCScheduledTask ID to reference
        NSString *objectId = [[scheduledTask.objectID URIRepresentation] absoluteString];
        
        //Set a local notification at time of event
        [self scheduleLocalNotification:schedule.notificationMessage withDate:date withTaskType:schedule.task.taskType withAPCScheduleTaskId:objectId andReminder:APCScheduleReminderNo];
        
        //TODO may have to interpret a cron expression, however, for now I'll just set reminders 15 mintues before
        if (schedule.reminder) {

            //Set a local reminder notification at time of event
            [self scheduleLocalNotification:schedule.notificationMessage withDate:date withTaskType:schedule.task.taskType withAPCScheduleTaskId:objectId andReminder:APCScheduleReminderYES];
        }
        
        [scheduledTask saveToPersistentStore:NULL];
    }
}


- (void)scheduleLocalNotification:(NSString *)message withDate:(NSDate *)dueOn withTaskType:(NSString *)taskType withAPCScheduleTaskId:(NSString *)APCScheduledTaskId andReminder:(int)reminder  {

    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = dueOn;
    localNotification.alertBody = message;
    
    //TODO: figure out how the badge numbers are going to be set.
    //localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    NSMutableDictionary *notificationInfo = [[NSMutableDictionary alloc] init];
    notificationInfo[@"taskType"] = taskType;
    notificationInfo[@"APCScheduledTaskId"] = APCScheduledTaskId;
    
    if (reminder) {
        
        NSTimeInterval reminderInterval = reminder_minutes_before_task * kMinutes;
        
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
