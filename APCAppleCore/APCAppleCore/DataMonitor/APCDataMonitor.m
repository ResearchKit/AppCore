//
//  APCDataMonitor.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppleCore.h"
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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userConsented)
                                                     name:APCUserDidConsentNotification
                                                   object:nil];
    }
    return self;
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

- (void)backgroundFetch:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void) userConsented
{
    [self.dataSubstrate.delegate setUpCollectors];
    [self.dataSubstrate joinStudy];
    [self refreshFromBridgeOnCompletion:^(NSError *error) {
        [error handle];
        [self batchUploadDataToBridgeOnCompletion:^(NSError *error) {
            [error handle];
        }];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
