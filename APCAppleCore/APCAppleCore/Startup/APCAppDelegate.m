//
//  APCAppDelegate.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppDelegate.h"
#import "APCAppleCore.h"
#import "APCDebugWindow.h"
#import "APCPassiveLocationTracking.h"

@interface APCAppDelegate ()
@property (strong,nonatomic) APCPassiveLocationTracking *passiveLocationTracking;

@end
@implementation APCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    //TODO: Figure out where this is actually going.
    self.passiveLocationTracking = [[APCPassiveLocationTracking alloc] initWithTimeInterval:60];
    [self.passiveLocationTracking start];
    
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

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[NSNotificationCenter defaultCenter] postNotificationName:APCAppDidRegisterUserNotification object:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:APCAppDidFailToRegisterForRemoteNotification object:nil];
}

- (APCDebugWindow *)window
{
    static APCDebugWindow *customWindow = nil;
    if (!customWindow) customWindow = [[APCDebugWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //TODO: remember to turn this off for production.
    customWindow.enableDebuggerWindow = YES;
    
    return customWindow;
}

@end
