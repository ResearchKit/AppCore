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

@implementation APCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    NSAssert(self.initializationOptions, @"Please set up initialization options");
    
    [self initializeBridgeServerConnection];
    [self initializeAppleCoreStack];
    [self loadStaticTasksAndSchedulesIfNecessary];
    [self registerNotifications];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
#ifndef DEVELOPMENT
    if (self.dataSubstrate.currentUser.signedIn) {
        [SBBComponent(SBBAuthManager) ensureSignedInWithCompletion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
            [error handle];
        }];
    }
#endif

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

/*********************************************************************************/
#pragma mark - Helpers
/*********************************************************************************/

- (void) initializeBridgeServerConnection
{
    [BridgeSDK setupWithAppPrefix:self.initializationOptions[kAppPrefixKey]];
    SBBNetworkManager *myNetworkManager = [[SBBNetworkManager alloc] initWithBaseURL:self.initializationOptions[kBaseURLKey]];
    [SBBComponentManager registerComponent:myNetworkManager forClass:[SBBNetworkManager class]];
}

- (void) initializeAppleCoreStack
{
    self.dataSubstrate = [[NSClassFromString(self.initializationOptions[kDataSubstrateClassNameKey]) alloc] initWithPersistentStorePath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:self.initializationOptions[kDatabaseNameKey]] additionalModels: nil studyIdentifier:self.initializationOptions[kStudyIdentifierKey]];
    self.scheduler = [[APCScheduler alloc] initWithDataSubstrate:self.dataSubstrate];
    self.dataMonitor = [[APCDataMonitor alloc] initWithDataSubstrate:self.dataSubstrate scheduler:self.scheduler];
    
    //Setup AuthDelegate for SageSDK
    SBBAuthManager * manager = (SBBAuthManager*) SBBComponent(SBBAuthManager);
    manager.authDelegate = self.dataSubstrate.currentUser;
}

- (void)loadStaticTasksAndSchedulesIfNecessary
{
    if (![APCDBStatus isSeedLoadedWithContext:self.dataSubstrate.persistentContext]) {
        [APCDBStatus setSeedLoadedWithContext:self.dataSubstrate.persistentContext];
        NSString *resource = [[NSBundle mainBundle] pathForResource:self.initializationOptions[kTasksAndSchedulesJSONFileNameKey] ofType:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfFile:resource];
        NSError * error;
        NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        [error handle];
        [self.dataSubstrate loadStaticTasksAndSchedules:dictionary];
        [self clearNSUserDefaults];
        [APCKeychainStore resetKeyChain];
    }
}

- (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    return basePath;
}

- (void) registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signedUpNotification:) name:(NSString *)APCUserSignedUpNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signedInNotification:) name:(NSString *)APCUserSignedInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOutNotification:) name:(NSString *)APCUserLogOutNotification object:nil];
}

/*********************************************************************************/
#pragma mark - Helper Methods
/*********************************************************************************/
- (void) clearNSUserDefaults
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

#pragma mark - Notifications
- (void) signedUpNotification:(NSNotification*) notification { /*Abstract Implementation*/ }

- (void) signedInNotification:(NSNotification*) notification { /*Abstract Implementation*/ }

- (void) logOutNotification:(NSNotification*) notification
{
    self.dataSubstrate.currentUser.signedUp = NO;
    self.dataSubstrate.currentUser.signedIn = NO;
    [APCKeychainStore removeValueForKey:kPasswordKey];
}



@end
