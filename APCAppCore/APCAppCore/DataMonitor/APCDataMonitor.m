// 
//  APCDataMonitor.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCAppCore.h"
#import "APCSchedule+Bridge.h"
#import "APCDataMonitor+Bridge.h"

@interface APCDataMonitor ()

@end

@implementation APCDataMonitor

- (instancetype)initWithDataSubstrate:(APCDataSubstrate *)dataSubstrate  scheduler:(APCScheduler *)scheduler
{
    self = [super init];
    if (self) {
        self.dataSubstrate = dataSubstrate;
        self.scheduler = scheduler;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScheduledTasks) name:APCScheduleUpdatedNotification object:nil];
    }
    return self;
}

- (void) appFinishedLaunching
{
    if (self.dataSubstrate.currentUser.isConsented) {
        [(APCAppDelegate*)[UIApplication sharedApplication].delegate setUpCollectors];
    }
}
- (void)appBecameActive
{
    [self refreshFromBridgeOnCompletion:^(NSError *error) {
        [error handle];
        [self batchUploadDataToBridgeOnCompletion:^(NSError *error) {
            [error handle];
        }];
    }];
}

- (void) userConsented
{
    [(APCAppDelegate*)[UIApplication sharedApplication].delegate setUpCollectors];
    [self.dataSubstrate joinStudy];
    [self.scheduler updateScheduledTasksIfNotUpdating:YES OnCompletion:^(NSError *error) {
        [self refreshFromBridgeOnCompletion:^(NSError *error) {
            [error handle];
            [self batchUploadDataToBridgeOnCompletion:NULL];
        }];
    }];
}

- (void) updateScheduledTasks
{
    [self.scheduler updateScheduledTasksIfNotUpdating:YES OnCompletion:^(NSError *error) {
        [self.scheduler updateScheduledTasksIfNotUpdating:NO OnCompletion:NULL];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
