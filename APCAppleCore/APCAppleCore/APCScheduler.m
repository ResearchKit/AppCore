//
//  Scheduler.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 8/27/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//


#import "APCScheduler.h"
#import "APCAppDelegate.h"
#import "APCDataSubstrate.h"

@implementation APCScheduler

- (void)updateScheduledTasks {
    [self fetchSchedule];    
}

/* Fetches Notification Entities */
- (NSArray *)fetchSchedule {

    //Fetch Schedule
    APCAppDelegate *appDelegate = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
    APCDataSubstrate *dataSubstrate = appDelegate.dataSubstrate;
    
    //Persistent context used for background threads.
    NSManagedObjectContext *context = dataSubstrate.persistentContext;
    context.persistentStoreCoordinator = dataSubstrate.persistentStoreCoordinator;

    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"APCSchedule" inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *schedules = [context executeFetchRequest:fetchRequest error:&error];
    
    if (schedules == nil) {
        // Deal with error...
        return schedules;
    }

    
//    @{@"href" : @"applicationURLForActivity",
//      @"type" : @"NSCalendarUnit Representative of recurrence or ONE_TIME or IMMEDIATE",
//      @"dueOn" : @"",
//      @"Task" : @"TASK_NAME",
//      @"notificationUID" : @"stringRepresentationOfUID",
//      @"UUID" : @"Represent scheduled object from server",
//      @"message" : @"Message",
//      }
    
    NSArray *scheduless = @[
                           @{
                               @"taskGUID" : @"12345",
                               @"dueOn" : @"30",
                               @"createdAt" : @"12345",
                               @"updatedAt" : @"12345",
                               @"reminder" : @true
                             },
                           @{
                               @"taskGUID" : @"12345",
                               @"dueOn" : @"60",
                               @"createdAt" : @"12345",
                               @"updatedAt" : @"12345",
                               @"reminder" : @false
                             },
                           @{
                               @"taskGUID" : @"12345",
                               @"dueOn" : @"90",
                               @"createdAt" : @"12345",
                               @"updatedAt" : @"12345",
                               @"reminder" : @true
                             }
                           ];
    
    //TODO returning schedules but I should be returning just 'schedule'
    return scheduless;
}

- (void)scheduleLocalNotification:(NSString *)schedule {
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    

    //notif.repeatInterval =;
}

- (void)clearAllLocalNotifications {
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)cancelLocationNotifications:(NSString *)notificationUID {
    
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    NSLog(@"Get array of notifs");
    
    for (UILocalNotification *notif in notifications) {
        
        NSDictionary *userInfoCurrent = notif.userInfo;
        NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"uid"]];
        
        if ([uid isEqualToString:notificationUID]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notif];
            break;
        }
    }
}


@end
