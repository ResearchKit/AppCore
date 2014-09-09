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


@interface APCScheduler()

@property  (nonatomic, strong)   NSArray                 *schedules;
@property  (weak, nonatomic)     APCDataSubstrate        *dataSubstrate;
@property  (strong, nonatomic)   APCScheduleInterpreter  *scheduleInterpreter;

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


- (BOOL)scheduleUpdated:(APCSchedule *)schedule {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];

    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc]
                                   initWithConcurrencyType:NSConfinementConcurrencyType];
    
    moc.parentContext = self.dataSubstrate.mainContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"APCScheduledTask"
                                              inManagedObjectContext:self.dataSubstrate.persistentContext ];
    [request setEntity:entity];
    
    NSMutableArray *dates = [self.scheduleInterpreter taskDates:schedule.scheduleExpression];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dueOn == %@ AND task == %@", [dates objectAtIndex:0], schedule.task];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];

    if (!array.count) {
        return NO;
    }
    
    return YES;
}


- (NSArray *)schedule {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc]
                                   initWithConcurrencyType:NSConfinementConcurrencyType];
    
    moc.parentContext = self.dataSubstrate.mainContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"APCSchedule"
                                              inManagedObjectContext:self.dataSubstrate.persistentContext ];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    
    return array;
}


- (void)updateScheduledTasks {
    
//    //Get APCSchedules from Core Data
//    self.schedules = [self schedule];
//    
//    for(APCSchedule *schedule in self.schedules) {
//
//        //Make sure scheduled task is not already created and then create scheduled task
//        if (![self scheduleUpdated:schedule]) {
//            [self createScheduledTask:schedule];
//        }
//    }
}


- (void)createScheduledTask:(APCSchedule *)schedule {
    
    NSString *scheduleExpression = schedule.scheduleExpression;
    
    NSMutableArray *dates = [self.scheduleInterpreter taskDates:scheduleExpression];
    
    for (NSDate *date in dates) {
     
        APCScheduledTask * scheduledTask = [APCScheduledTask newObjectForContext:self.dataSubstrate.mainContext];
        
        scheduledTask.completed = [NSNumber numberWithInt:0];
        scheduledTask.dueOn = date;
        scheduledTask.task = schedule.task;
        
        //Get the APCScheduledTask ID to reference
        NSString *objectId = [[scheduledTask.objectID URIRepresentation] absoluteString];
        
        //Set a local notification at time of event
        [self scheduleLocalNotification:schedule.notificationMessage withDate:date withTaskType:schedule.task.taskType withAPCScheduleTaskId:objectId andReminder:0];
        
        //TODO may have to interpret a cron expression, however, for now I'll just set reminders 15 mintues before
        if (schedule.reminder) {

            //Set a local reminder notification at time of event
            [self scheduleLocalNotification:schedule.notificationMessage withDate:date withTaskType:schedule.task.taskType withAPCScheduleTaskId:objectId andReminder:1];
        }
        
        [scheduledTask saveToPersistentStore:NULL];
    }
}


- (void)scheduleLocalNotification:(NSString *)message withDate:(NSDate *)dueOn withTaskType:(NSString *)taskType withAPCScheduleTaskId:(NSString *)objectUID andReminder:(int)reminder  {

    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = dueOn;
    localNotification.alertBody = message;
    
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    NSDictionary *notificationInfo = @{@"scheduledTaskId" : objectUID};
  
    //TODO Save the activity type in the local notification later so it's accessible by a view controller later.
    //@{@"taskType" : taskType, @"scheduledTaskId" : objectUID};
    
    if (reminder) {
        
        NSTimeInterval reminderInterval = -15 * 60;
        
        [dueOn dateByAddingTimeInterval:reminderInterval];
        [notificationInfo setValue:@"reminder" forKey:@"reminder"];
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
        if ([userInfoCurrent objectForKey:@"scheduledTaskId"] ) {
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
        if ([[userInfoCurrent objectForKey:@"taskType"] isEqualToString:taskType]) {
            [app cancelLocalNotification:oneEvent];
        }
    }
}

@end
