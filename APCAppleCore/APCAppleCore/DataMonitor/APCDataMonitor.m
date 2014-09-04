//
//  APCDataMonitor.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppleCore.h"

@interface APCDataMonitor ()

//Declaring as weak so as not to hold on to below objects
@property (weak, nonatomic) APCDataSubstrate * dataSubstrate;
@property (weak, nonatomic) APCSageNetworkManager * networkManager;
@property (weak, nonatomic) APCScheduler * scheduler;

@end

@implementation APCDataMonitor

- (instancetype)initWithDataSubstrate:(APCDataSubstrate *)dataSubstrate networkManager:(APCSageNetworkManager *)networkManager scheduler:(APCScheduler *)scheduler
{
    self = [super init];
    if (self) {
        self.dataSubstrate = dataSubstrate;
        self.networkManager = networkManager;
        self.scheduler = scheduler;
    }
    return self;
}

- (void)appBecameActive
{
    APCSchedule * sampleSchedule = [APCSchedule newObjectForContext:self.dataSubstrate.mainContext];
    sampleSchedule.scheduleExpression = @"0:1,2,3";
    [sampleSchedule saveToPersistentStore:NULL];
    [self.scheduler updateScheduledTasks:@[sampleSchedule]];
}

- (void)backgroundFetch:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNoData);
}



@end
