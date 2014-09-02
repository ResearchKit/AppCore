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

@interface APCScheduler()

@property  (nonatomic, strong)  NSArray                 *schedules;

//Declaring as weak so as not to hold on to below objects
@property  (weak, nonatomic)    APCDataSubstrate        *dataSubstrate;
@property (weak, nonatomic)     APCSageNetworkManager   *networkManager;

@end

@implementation APCScheduler

enum {MIDNIGHT, TWILIGHT, MORNING, NOON, MIDNOON, EVENING};

- (instancetype)initWithDataSubstrate: (APCDataSubstrate*) dataSubstrate networkManager: (APCSageNetworkManager*) networkManager {
    
    self = [super init];
    if (self) {
        self.dataSubstrate = dataSubstrate;
        self.networkManager = networkManager;
    }
    return self;
}

- (void)updateScheduledTasks:(NSArray *)schedules {
    
    self.schedules = schedules;
    
    for(APCSchedule *schedule in schedules) {

        [self setScheduledTask:schedule];
    }
}

- (void)setScheduledTask:(APCSchedule *)schedule {
    
    NSString *scheduleExpression = schedule.scheduleExpression;
    
    NSArray* tasks = [scheduleExpression componentsSeparatedByString: @","];
    
    for(NSString *task in tasks) {
        
        APCScheduledTask * scheduledTask = [APCScheduledTask newObjectForContext:self.dataSubstrate.mainContext];
        
        scheduledTask.completed = 0;
        scheduledTask.createdAt = schedule.createdAt;
        scheduledTask.updatedAt = schedule.updatedAt;
        scheduledTask.task = schedule.task;
        
        NSDate *dueOn = [self setTimeWithInterval:task];
        
        scheduledTask.dueOn = dueOn;
        
        [scheduledTask saveToPersistentStore:NULL];
        
        //Get the APCScheduledTask ID to reference
        NSString *objectId = [[scheduledTask.objectID URIRepresentation] absoluteString];
        
        //Set a local notification at time of event
        [self scheduleLocalNotification:schedule.notificationMessage withDate:dueOn withTaskType:schedule.task.taskType withAPCScheduleTaskId:objectId andReminder:0];
    }
}

- (NSDate *)setTimeWithInterval:(NSString *)expression {
    
    //Period or Interval : Time of day : Interval within 4 hours : min, hourly, daily, weekly, monthly : whether a reminder is set
    //0 - 1              : 0-5         : 0 0 0 0 0               : 0 - 4                               : 0 - 1 25% of time interval

    
    NSArray* timeComponents = [expression componentsSeparatedByString: @":"];
    
    [timeComponents objectAtIndex:1];
    
    [timeComponents objectAtIndex:1];
    
    [timeComponents objectAtIndex:1];
    
    
    NSInteger *number;
    
    switch ([[timeComponents objectAtIndex:2]  intValue]) {
        case MIDNIGHT:  break;
        case TWILIGHT:  break;
        case MORNING:   break;
        case NOON:      break;
        case MIDNOON:   break;
        case EVENING:   break;
        default: ;
    }
    
    
    NSDate *now = [NSDate date];
    
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitDay    |
                                                        NSCalendarUnitMonth  |
                                                        NSCalendarUnitYear   |
                                                        NSCalendarUnitEra    |
                                                        NSCalendarUnitSecond |
                                                        NSCalendarUnitMinute |
                                                        NSCalendarUnitHour   |
                                                        NSCalendarUnitWeekday
                                               fromDate:now];
    
    [components setHour:10];
    NSDate *today10am = [calendar dateFromComponents:components];

    [today10am dateByAddingTimeInterval:123124];
    
    return today10am;
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
