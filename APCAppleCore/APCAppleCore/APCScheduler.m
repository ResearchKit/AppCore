//
//  Scheduler.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 8/27/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//


#import "APCScheduler.h"
#import "APCDataSubstrate.h"
#import "NSManagedObject+APCHelper.h"
#import "APCSchedule.h"
#import "APCScheduledTask.h"
#import "APCTask.h"
#import "APCSageNetworkManager.h"
#import "APCScheduleInterpreter.h"

@interface APCScheduler()

@property  (nonatomic, strong)  NSArray                 *schedules;

//Declaring as weak so as not to hold on to below objects
@property  (weak, nonatomic)    APCDataSubstrate        *dataSubstrate;
@property (weak, nonatomic)     APCSageNetworkManager   *networkManager;

@property (strong, nonatomic) APCScheduleInterpreter *scheduleInterpreter;

@end

@implementation APCScheduler

- (instancetype)initWithDataSubstrate: (APCDataSubstrate*) dataSubstrate networkManager: (APCSageNetworkManager*) networkManager {
    
    self = [super init];
    if (self) {
        self.dataSubstrate = dataSubstrate;
        self.networkManager = networkManager;
        
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dueOn = %@, task = %@", [dates objectAtIndex:0], schedule.task];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];

    if (!array.count) {
        return NO;
    }
    
    return YES;
}

- (void)updateScheduledTasks:(NSArray *)schedules {
    
    self.schedules = schedules;
    
    for(APCSchedule *schedule in schedules) {

        if (![self scheduleUpdated:schedule]) [self setScheduledTask:schedule];

    }
}

- (void)setScheduledTask:(APCSchedule *)schedule {
    
    NSString *scheduleExpression = schedule.scheduleExpression;
    
    NSMutableArray *dates = [self.scheduleInterpreter taskDates:scheduleExpression];
    
    for (NSDate *date in dates) {
     
        APCScheduledTask * scheduledTask = [APCScheduledTask newObjectForContext:self.dataSubstrate.mainContext];
        
        scheduledTask.completed = [NSNumber numberWithInt:0];
        scheduledTask.createdAt = [NSDate date];
        scheduledTask.dueOn = date;
        scheduledTask.updatedAt = [NSDate date];
        scheduledTask.task = schedule.task;
        
        [scheduledTask saveToPersistentStore:NULL];
        
        //Get the APCScheduledTask ID to reference
        NSString *objectId = [[scheduledTask.objectID URIRepresentation] absoluteString];
        
        //Set a local notification at time of event
        [self scheduleLocalNotification:schedule.notificationMessage withDate:date withTaskType:schedule.task.taskType withAPCScheduleTaskId:objectId andReminder:0];
    }
}


- (void)scheduleLocalNotification:(NSString *)message withDate:(NSDate *)dueOn withTaskType:(NSString *)taskType withAPCScheduleTaskId:(NSString *)objectUID andReminder:(int)reminder  {

    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = dueOn;
    localNotification.alertBody = message;
    
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    NSDictionary *notificationInfo =     @{
                                           @"taskType" : taskType,
                                           @"scheduledTaskId" : objectUID
                                           };
    
    if (reminder) {
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
