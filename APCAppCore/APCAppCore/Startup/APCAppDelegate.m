// 
//  APCAppDelegate.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCAppDelegate.h"
#import "APCAppCore.h"
#import "APCDebugWindow.h"
#import "APCPasscodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "APCOnboarding.h"

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
static NSString *const kLearnStoryBoardKey         = @"APCLearn";
static NSString *const kActivitiesStoryBoardKey    = @"APCActivities";
static NSString *const kHealthProfileStoryBoardKey = @"APCProfile";

static NSString *const kLastUsedTimeKey = @"APHLastUsedTime";

@interface APCAppDelegate  ( )  <UITabBarControllerDelegate>
@property  (nonatomic, strong)  NSArray  *storyboardIdInfo;
@property (nonatomic) BOOL isPasscodeShowing;

@end

@implementation APCAppDelegate
/*********************************************************************************/
#pragma mark - App Delegate Methods
/*********************************************************************************/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [self setUpInitializationOptions];
    NSAssert(self.initializationOptions, @"Please set up initialization options");

    [self initializeBridgeServerConnection];
    [self initializeAppleCoreStack];
    [self loadStaticTasksAndSchedulesIfNecessary];
    [self registerNotifications];
    [self setUpHKPermissions];
    [self setUpAppAppearance];
    [self showAppropriateVC];
    
    [self.dataMonitor appFinishedLaunching];
    
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
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if (self.dataSubstrate.currentUser.signedIn && !self.isPasscodeShowing) {
        NSDate *currentTime = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:currentTime forKey:kLastUsedTimeKey];
    }
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (self.dataSubstrate.currentUser.signedIn && !self.isPasscodeShowing) {
        NSDate *currentTime = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:currentTime forKey:kLastUsedTimeKey];
    }
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
    [BridgeSDK setupWithAppPrefix:self.initializationOptions[kAppPrefixKey] environment:(SBBEnvironment)[self.initializationOptions[kBridgeEnvironmentKey] integerValue]];
}

- (void) initializeAppleCoreStack
{
    self.dataSubstrate = [[APCDataSubstrate alloc] initWithPersistentStorePath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:self.initializationOptions[kDatabaseNameKey]] additionalModels: nil studyIdentifier:self.initializationOptions[kStudyIdentifierKey]];
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

/*********************************************************************************/
#pragma mark - Respond to Notifications
/*********************************************************************************/
- (void) registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signedUpNotification:) name:(NSString *)APCUserSignedUpNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signedInNotification:) name:(NSString *)APCUserSignedInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOutNotification:) name:(NSString *)APCUserLogOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userConsented:) name:APCUserDidConsentNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(withdrawStudy:) name:APCUserWithdrawStudyNotification object:nil];
}

- (void) signedUpNotification:(NSNotification*) notification
{
    [self showNeedsEmailVerification];
}

- (void) signedInNotification:(NSNotification*) notification
{
    [self.dataMonitor userConsented];
    [self showTabBar];
}

- (void) userConsented:(NSNotification*) notification
{

}

- (void) logOutNotification:(NSNotification*) notification
{
    self.dataSubstrate.currentUser.signedUp = NO;
    self.dataSubstrate.currentUser.signedIn = NO;
    [APCKeychainStore removeValueForKey:kPasswordKey];
    [APCKeychainStore removeValueForKey:kSessionTokenKey];
    
    [self showOnBoarding];
}

- (void)withdrawStudy:(NSNotification *)notification
{
    [self clearNSUserDefaults];
    [APCKeychainStore resetKeyChain];
    [self.dataSubstrate resetCoreData];
    
    [self showOnBoarding];
}

#pragma mark - Misc
- (NSString *)certificateFileName
{
    return ([self.initializationOptions[kBridgeEnvironmentKey] integerValue] == SBBEnvironmentStaging) ? [self.initializationOptions[kAppPrefixKey] stringByAppendingString:@"-staging"] :self.initializationOptions[kAppPrefixKey];
}

#pragma mark - Other Abstract Implmentations
- (void) setUpInitializationOptions {/*Abstract Implementation*/}
- (void) setUpAppAppearance {/*Abstract Implementation*/}
- (void) setUpCollectors {/*Abstract Implementation*/}

/*********************************************************************************/
#pragma mark - Public Helpers
/*********************************************************************************/
- (NSMutableDictionary *)defaultInitializationOptions
{
    //Return Default Dictionary
    return [@{
              kDatabaseNameKey                     : kDatabaseName,
              kTasksAndSchedulesJSONFileNameKey    : kTasksAndSchedulesJSONFileName,
              } mutableCopy];
}

- (APCDebugWindow *)window
{
    static APCDebugWindow *customWindow = nil;
    if (!customWindow) customWindow = [[APCDebugWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //TODO: remember to turn this off for production.
    customWindow.enableDebuggerWindow = NO;
    
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
                              @{@"name": kDashBoardStoryBoardKey, @"bundle" : [NSBundle mainBundle]},
                              @{@"name": kLearnStoryBoardKey, @"bundle" : [NSBundle appleCoreBundle]},
                              @{@"name": kActivitiesStoryBoardKey, @"bundle" : [NSBundle appleCoreBundle]},
                              @{@"name": kHealthProfileStoryBoardKey, @"bundle" : [NSBundle appleCoreBundle]}
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
        
        NSString  *name = [self.storyboardIdInfo objectAtIndex:controllerIndex][@"name"];
        UIStoryboard  *storyboard = [UIStoryboard storyboardWithName:name bundle:[self.storyboardIdInfo objectAtIndex:controllerIndex][@"bundle"]];
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
    APCPasscodeViewController *passcodeViewController = [[UIStoryboard storyboardWithName:@"APCPasscode" bundle:[NSBundle appleCoreBundle]] instantiateInitialViewController];
    passcodeViewController.delegate = self;
    
    [self.window.rootViewController presentViewController:passcodeViewController animated:YES completion:nil];
    self.isPasscodeShowing = YES;
}

- (void) showOnBoarding
{
}

- (void) showNeedsEmailVerification
{
    APCEmailVerifyViewController * viewController = (APCEmailVerifyViewController*)[[UIStoryboard storyboardWithName:@"APCEmailVerify" bundle:[NSBundle appleCoreBundle]] instantiateInitialViewController];
    [self setUpRootViewController:viewController];
}

- (void) setUpRootViewController: (UIViewController*) viewController
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.navigationBar.translucent = NO;
    
    [UIView transitionWithView:self.window
                      duration:0.6
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.window.rootViewController = navController;
                    }
                    completion:nil];
}

- (void)instantiateOnboardingForType:(APCOnboardingTaskType)type
{
    if (self.onboarding) {
        self.onboarding = nil;
        self.onboarding.delegate = nil;
    }
    
    self.onboarding = [[APCOnboarding alloc] initWithDelegate:self taskType:type];
}

- (RKSTTaskViewController *)consentViewController
{
     NSAssert(FALSE, @"Override this method to return a valid Consent Task View Controller.");
    return nil;
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

#pragma mark - APCOnboardingDelegate methods

- (APCScene *)inclusionCriteriaSceneForOnboarding:(APCOnboarding *)onboarding
{
    NSAssert(FALSE, @"Cannot retun nil. Override this delegate method to return a valid APCScene.");
    
    return nil;
}

#pragma mark - APCOnboardingTaskDelegate methods

- (APCUser *)userForOnboardingTask:(APCOnboardingTask *)task
{
    return self.dataSubstrate.currentUser;
}

- (NSInteger)numberOfServicesInPermissionsListForOnboardingTask:(APCOnboardingTask *)task
{
    NSDictionary *initialOptions = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).initializationOptions;
    NSArray *servicesArray = initialOptions[kAppServicesListRequiredKey];
    
    return servicesArray.count;
}

#pragma mark - APCPasscodeViewControllerDelegate methods

- (void)passcodeViewControllerDidSucceed:(APCPasscodeViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
    self.isPasscodeShowing = NO;
}

@end
