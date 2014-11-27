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
#import "APCPasscodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

/*********************************************************************************/
#pragma mark - Initializations Option Defaults
/*********************************************************************************/
static NSString *const kDataSubstrateClassName = @"APHDataSubstrate";
static NSString *const kDatabaseName = @"db.sqlite";
static NSString *const kTasksAndSchedulesJSONFileName = @"APHTasksAndSchedules";

/*********************************************************************************/
#pragma mark - Tab bar Constants
/*********************************************************************************/
static NSString *const kDashBoardStoryBoardKey     = @"APHDashboard";
static NSString *const kLearnStoryBoardKey         = @"APHLearn";
static NSString *const kActivitiesStoryBoardKey    = @"APHActivities";
static NSString *const kHealthProfileStoryBoardKey = @"APHProfile";

static NSString *const kLastUsedTimeKey = @"APHLastUsedTime";

@interface APCAppDelegate  ( )  <UITabBarControllerDelegate>
@property  (nonatomic, strong)  NSArray  *storyboardIdInfo;
@end

@implementation APCAppDelegate
/*********************************************************************************/
#pragma mark - App Delegate Methods
/*********************************************************************************/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.healthKitTracker = [[APCHealthKitQuantityTracker alloc] initWithIdentifier:HKQuantityTypeIdentifierHeartRate withNotificationName:@"APCHeartRateUpdated"];
    
    [self.healthKitTracker start];
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    
    //Setting the Audio Session Category for voice prompts when device is locked
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!success) { /* handle the error condition */ }
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    
    
    [self setUpInitializationOptions];
    NSAssert(self.initializationOptions, @"Please set up initialization options");

    [self initializeBridgeServerConnection];
    [self initializeAppleCoreStack];
    [self loadStaticTasksAndSchedulesIfNecessary];
    [self registerNotifications];
    [self setUpHKPermissions];
    [self setUpAppAppearance];
    [self showAppropriateVC];
    
    //set default 
    NSNumber *numberOfMinutes = [self.dataSubstrate.parameters numberForKey:kNumberOfMinutesForPasscodeKey];
    if (!numberOfMinutes) {
        [self.dataSubstrate.parameters setNumber:[APCParameters autoLockValues][0] forKey:kNumberOfMinutesForPasscodeKey];
    }
    
    [self showPasscodeIfNecessary];
    
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

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSDate *currentTime = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:currentTime forKey:kLastUsedTimeKey];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self showPasscodeIfNecessary];
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

/*********************************************************************************/
#pragma mark - Did Finish Launch Methods
/*********************************************************************************/
- (void) initializeBridgeServerConnection
{
    [BridgeSDK setupWithAppPrefix:self.initializationOptions[kAppPrefixKey]];
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

- (void) setUpHKPermissions
{
    [APCPermissionsManager setHealthKitTypesToRead:self.initializationOptions[kHKReadPermissionsKey]];
    [APCPermissionsManager setHealthKitTypesToWrite:self.initializationOptions[kHKWritePermissionsKey]];
}

#pragma mark - Notifications
- (void) registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signedUpNotification:) name:(NSString *)APCUserSignedUpNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signedInNotification:) name:(NSString *)APCUserSignedInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOutNotification:) name:(NSString *)APCUserLogOutNotification object:nil];
}

- (void) signedUpNotification:(NSNotification*) notification
{
    [self showNeedsEmailVerification];
}

- (void) signedInNotification:(NSNotification*) notification
{
    [self showTabBar];
}

- (void) logOutNotification:(NSNotification*) notification
{
    self.dataSubstrate.currentUser.signedUp = NO;
    self.dataSubstrate.currentUser.signedIn = NO;
    [APCKeychainStore removeValueForKey:kPasswordKey];
    
    [self showOnBoarding];
}

#pragma mark - Other Abstract Implmentations
- (void) setUpInitializationOptions {/*Abstract Implementation*/}
- (void) setUpAppAppearance {/*Abstract Implementation*/}

/*********************************************************************************/
#pragma mark - Public Helpers
/*********************************************************************************/
- (NSMutableDictionary *)defaultInitializationOptions
{
    //Return Default Dictionary
    return [@{
              kDatabaseNameKey                     : kDatabaseName,
              kTasksAndSchedulesJSONFileNameKey    : kTasksAndSchedulesJSONFileName,
              kDataSubstrateClassNameKey           : kDataSubstrateClassName
              } mutableCopy];
}

- (APCDebugWindow *)window
{
    static APCDebugWindow *customWindow = nil;
    if (!customWindow) customWindow = [[APCDebugWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //TODO: remember to turn this off for production.
    customWindow.enableDebuggerWindow = YES;
    
    return customWindow;
}

- (void) clearNSUserDefaults
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

/*********************************************************************************/
#pragma mark - Tab Bar Stuff
/*********************************************************************************/
- (NSArray *)storyboardIdInfo
{
    if (!_storyboardIdInfo) {
        _storyboardIdInfo = @[
                              kDashBoardStoryBoardKey,
                              kLearnStoryBoardKey,
                              kActivitiesStoryBoardKey,
                              kHealthProfileStoryBoardKey
                              ];
    }
    return _storyboardIdInfo;
}

- (void)showTabBar
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"TabBar" bundle:[NSBundle appleCoreBundle]];
    
    UITabBarController *tabBarController = (UITabBarController *)[storyBoard instantiateInitialViewController];
    self.window.rootViewController = tabBarController;
    tabBarController.delegate = self;
    
    NSArray       *items = tabBarController.tabBar.items;
    UITabBarItem  *selectedItem = tabBarController.tabBar.selectedItem;
    
    NSUInteger     selectedItemIndex = 0;
    if (selectedItem != nil) {
        selectedItemIndex = [items indexOfObject:selectedItem];
    }
    
    NSArray  *deselectedImageNames = @[ @"tab_dashboard",          @"tab_learn",          @"tab_activities",          @"tab_profile" ];
    NSArray  *selectedImageNames   = @[ @"tab_dashboard_selected", @"tab_learn_selected", @"tab_activities_selected", @"tab_profile_selected" ];
    NSArray  *tabBarTitles         = @[ @"Dashboard", @"Learn", @"Activities", @"Profile"];
    
    for (int i=0; i<items.count; i++) {
        UITabBarItem  *item = items[i];
        item.image = [UIImage imageNamed:deselectedImageNames[i]];
        item.selectedImage = [[UIImage imageNamed:selectedImageNames[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        item.title = tabBarTitles[i];
    }
    
    NSArray  *controllers = tabBarController.viewControllers;
    [self tabBarController:tabBarController didSelectViewController:controllers[selectedItemIndex]];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    UITabBarController  *tabster = (UITabBarController  *)self.window.rootViewController;
    NSArray  *deselectedImageNames = @[ @"tab_dashboard",          @"tab_learn",          @"tab_activities",          @"tab_profile" ];
    NSArray  *selectedImageNames   = @[ @"tab_dashboard_selected", @"tab_learn_selected", @"tab_activities_selected", @"tab_profile_selected" ];
    NSArray  *tabBarTitles         = @[ @"Dashboard", @"Learn", @"Activities", @"Profile"];
    
    if ([viewController isMemberOfClass: [UIViewController class]] == YES) {
        
        NSMutableArray  *controllers = [tabBarController.viewControllers mutableCopy];
        NSUInteger  controllerIndex = [controllers indexOfObject:viewController];
        
        NSString  *name = [self.storyboardIdInfo objectAtIndex:controllerIndex];
        UIStoryboard  *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
        UIViewController  *controller = [storyboard instantiateInitialViewController];
        [controllers replaceObjectAtIndex:controllerIndex withObject:controller];
        
        [tabster setViewControllers:controllers animated:NO];
        tabster.tabBar.tintColor = [UIColor appPrimaryColor];
        UITabBarItem  *item = tabster.tabBar.selectedItem;
        item.image = [UIImage imageNamed:deselectedImageNames[controllerIndex]];
        item.selectedImage = [[UIImage imageNamed:selectedImageNames[controllerIndex]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        item.title = tabBarTitles[controllerIndex];
    }
}

/*********************************************************************************/
#pragma mark - Show Methods
/*********************************************************************************/
- (void) showAppropriateVC
{
    if (self.dataSubstrate.currentUser.isSignedIn) {
        [self showTabBar];
        
    }
    else if (self.dataSubstrate.currentUser.isSignedUp)
    {
        [self showNeedsEmailVerification];
    }
    else
    {
        [self showOnBoarding];
    }
}

- (void)showPasscodeIfNecessary
{
    if (self.dataSubstrate.currentUser.isSignedIn) {
        NSDate *lastUsedTime = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUsedTimeKey];
        
        if (lastUsedTime) {
            NSTimeInterval timeDifference = [lastUsedTime timeIntervalSinceNow];
            NSInteger numberOfMinutes = [self.dataSubstrate.parameters integerForKey:kNumberOfMinutesForPasscodeKey];
            
            if (fabs(timeDifference) > numberOfMinutes * 60) {
                
                [self showPasscode];
            }
        }
    }
}

- (void)showPasscode
{
    APCPasscodeViewController *passcodeViewController = [[APCPasscodeViewController alloc] initWithNibName:@"APCPasscodeViewController" bundle:[NSBundle appleCoreBundle]];
    [self.window.rootViewController presentViewController:passcodeViewController animated:YES completion:nil];
}

- (void) showOnBoarding {/*Abstract Implementation*/ }

- (void) showNeedsEmailVerification
{
    APCEmailVerifyViewController * viewController = (APCEmailVerifyViewController*)[[UIStoryboard storyboardWithName:@"APCEmailVerify" bundle:[NSBundle appleCoreBundle]] instantiateInitialViewController];
    [self setUpRootViewController:viewController];
}

- (void) setUpRootViewController: (UIViewController*) viewController
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.navigationBar.translucent = NO;
    self.window.rootViewController = navController;
}

/*********************************************************************************/
#pragma mark - Private Helper Methods
/*********************************************************************************/
- (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    return basePath;
}

@end
