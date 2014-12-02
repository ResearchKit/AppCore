//
//  APCDataMonitor.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppleCore.h"
#import "APCSchedule+Bridge.h"

@interface APCDataMonitor ()

//Declaring as weak so as not to hold on to below objects
@property (weak, nonatomic) APCDataSubstrate * dataSubstrate;
@property (weak, nonatomic) APCScheduler * scheduler;

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
    [self refreshFromServer];
}

- (void) refreshFromServer
{
    if (self.dataSubstrate.currentUser.isConsented) {
        [APCSchedule updateSchedulesOnCompletion:^(NSError *error) {
            [APCTask refreshSurveys];
            [self.scheduler updateScheduledTasksIfNotUpdating:NO];
        }];
    }
}

- (void)backgroundFetch:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNoData);
}


- (void) userConsented
{
    [self.dataSubstrate.delegate setUpCollectors];
    [self.dataSubstrate joinStudy];
    [self refreshFromServer];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
