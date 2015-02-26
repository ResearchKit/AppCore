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
    APCLogEventWithData(kAppStateChangedEvent, @{@"state":@"App Launched"});
}
- (void)appBecameActive
{
    [self refreshFromBridgeOnCompletion:^(NSError *error) {
        APCLogError2 (error);
        [self batchUploadDataToBridgeOnCompletion:^(NSError *error) {
            APCLogError2 (error);
        }];
    }];
    APCLogEventWithData(kAppStateChangedEvent, @{@"state":@"App Became Active"});
}

- (void) addDidEnterBackground
{
    APCLogEventWithData(kAppStateChangedEvent, @{@"state":@"App Did Enter Background"});
}

- (void) userConsented
{
    [(APCAppDelegate*)[UIApplication sharedApplication].delegate setUpCollectors];
    [self.scheduler updateScheduledTasksIfNotUpdatingWithRange:kAPCSchedulerDateRangeToday];
    [self.scheduler updateScheduledTasksIfNotUpdatingWithRange:kAPCSchedulerDateRangeTomorrow];
    [self refreshFromBridgeOnCompletion:^(NSError *error) {
        APCLogError2 (error);
        [self batchUploadDataToBridgeOnCompletion:NULL];
    }];
}

- (void) updateScheduledTasks
{
    [self.scheduler updateScheduledTasksIfNotUpdatingWithRange:kAPCSchedulerDateRangeToday];
    [self.scheduler updateScheduledTasksIfNotUpdatingWithRange:kAPCSchedulerDateRangeTomorrow];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)performCoreDataBlockInBackground:(void (^)(NSManagedObjectContext *))coreDataBlock
{
    NSManagedObjectContext * privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateContext.parentContext = self.dataSubstrate.persistentContext;
    [privateContext performBlock:^{
        if (coreDataBlock) {
            coreDataBlock(privateContext);
        }
    }];
}

@end
