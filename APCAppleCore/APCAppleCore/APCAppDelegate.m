//
//  APCAppDelegate.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppDelegate.h"
#import "APCAppleCore.h"

@implementation APCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.scheduler = [[APCScheduler alloc] initWithDataSubstrate:self.dataSubstrate networkManager:(APCSageNetworkManager*)self.networkManager];
    self.dataMonitor = [[APCDataMonitor alloc] initWithDataSubstrate:self.dataSubstrate networkManager:(APCSageNetworkManager*)self.networkManager scheduler:self.scheduler];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.dataMonitor appBecameActive];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self.dataMonitor backgroundFetch:completionHandler];
}

@end
