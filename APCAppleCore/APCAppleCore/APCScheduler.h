//
//  Scheduler.h
//  APCAppleCore
//
//  Created by Justin Warmkessel on 8/27/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class APCDataSubstrate, APCSageNetworkManager;
@class APCSchedule;

@interface APCScheduler : NSObject

- (void)updateScheduledTasks:(NSArray *)schedules;
- (instancetype)initWithDataSubstrate: (APCDataSubstrate*) dataSubstrate networkManager: (APCSageNetworkManager*) networkManager;

- (void)clearNotificationActivityType:(NSString *)taskType;
- (void)clearAllScheduledTaskNotifications;
- (BOOL)scheduleUpdated:(APCSchedule *)schedule;
@end

