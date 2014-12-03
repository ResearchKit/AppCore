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
