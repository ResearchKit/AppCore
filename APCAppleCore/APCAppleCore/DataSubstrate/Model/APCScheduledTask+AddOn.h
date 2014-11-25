//
//  APCScheduledTask+AddOn.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCScheduledTask.h"
@interface APCScheduledTask (AddOn)

- (void) completeScheduledTask;
- (void) createLocalNotification;
- (void) deleteLocalNotification;
- (void) deleteScheduledTask; //Also clears local notification

+ (NSArray *)allScheduledTasksForTodayInContext: (NSManagedObjectContext*) context;
+ (instancetype) scheduledTaskForStartOnDate: (NSDate *) startOn schedule: (APCSchedule*) schedule inContext: (NSManagedObjectContext*) context;

@end
