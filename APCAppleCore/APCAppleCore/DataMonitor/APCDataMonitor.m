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

@end

@implementation APCDataMonitor

- (instancetype)initWithDataSubstrate:(APCDataSubstrate *)dataSubstrate networkManager:(APCSageNetworkManager *)networkManager
{
    self = [super init];
    if (self) {
        self.dataSubstrate = dataSubstrate;
        self.networkManager = networkManager;
    }
    return self;
}

- (void)appBecameActive
{
    APCTask * task = [APCTask newObjectForContext:self.dataSubstrate.mainContext];
    task.taskType = @"taskType";
    [task saveToPersistentStore:NULL];
}

- (void)backgroundFetch:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNoData);
}



@end
