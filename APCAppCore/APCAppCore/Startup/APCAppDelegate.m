// 
//  APCAppDelegate.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCAppDelegate.h"
#import "APCAppCore.h"
#import "APCDebugWindow.h"
#import "APCPasscodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "APCOnboarding.h"
#import "APCTasksReminderManager.h"
#import "UIView+Helper.h"
#import "APCTabBarViewController.h"
#import "UIAlertController+Helper.h"

/*********************************************************************************/
#pragma mark - Initializations Option Defaults
/*********************************************************************************/
static NSString *const kDataSubstrateClassName = @"APHDataSubstrate";
static NSString *const kDatabaseName = @"db.sqlite";
static NSString *const kTasksAndSchedulesJSONFileName = @"APHTasksAndSchedules";
static NSString *const kConsentSectionFileName = @"APHConsentSection";

static NSString *const kDBStatusCurrentVersion = @"v1.0";

/*********************************************************************************/
#pragma mark - Tab bar Constants
/*********************************************************************************/
static NSString *const kDashBoardStoryBoardKey     = @"APHDashboard";
static NSString *const kLearnStoryBoardKey         = @"APCLearn";
static NSString *const kActivitiesStoryBoardKey    = @"APCActivities";
static NSString *const kHealthProfileStoryBoardKey = @"APCProfile";

static NSString *const kLastUsedTimeKey = @"APHLastUsedTime";
static NSUInteger const kIndexOfActivitesTab = 0;
static NSUInteger const kIndexOfProfileTab = 3;


@interface APCAppDelegate  ( )  <UITabBarControllerDelegate>

@property (nonatomic) BOOL isPasscodeShowing;
@property (nonatomic, strong) UIView *secureView;
@property (nonatomic, strong) NSError *catastrophicStartupError;

@end


@implementation APCAppDelegate
/*********************************************************************************/
#pragma mark - App Delegate Methods
/*********************************************************************************/
- (BOOL)               application: (UIApplication *) __unused application
    willFinishLaunchingWithOptions: (NSDictionary *) __unused launchOptions
{
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [self setUpInitializationOptions];
    NSAssert(self.initializationOptions, @"Please set up initialization options");

    [self doGeneralInitialization];
    [self initializeBridgeServerConnection];
    [self initializeAppleCoreStack];
    [self loadStaticTasksAndSchedulesIfNecessary];
    [self registerNotifications];
    [self setUpHKPermissions];
    [self setUpAppAppearance];
    [self setUpTasksReminder];
    [self showAppropriateVC];
    
    [self.dataMonitor appFinishedLaunching];

	// Setup analytics options (and, conceptually, all logging options).
	[APCLog setupTurningFlurryOn: [self.initializationOptions [kAnalyticsOnOffKey] boolValue]
					flurryApiKey: self.initializationOptions [kAnalyticsFlurryAPIKeyKey]
	 ];
    
    return YES;
}

- (BOOL)application:(UIApplication *) __unused application didFinishLaunchingWithOptions:(NSDictionary *) __unused launchOptions
{
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *) __unused application
{
    [self showSecureView];
}

- (void)applicationDidBecomeActive:(UIApplication *) __unused application
{
#ifndef DEVELOPMENT
    if (self.dataSubstrate.currentUser.signedIn) {
        [SBBComponent(SBBAuthManager) ensureSignedInWithCompletion: ^(NSURLSessionDataTask * __unused task,
																	  id  __unused responseObject,
																	  NSError *error) {
            APCLogError2 (error);
        }];
    }
#endif
    
    [self hideSecureView];
    [self showPasscodeIfNecessary];
    [self.dataMonitor appBecameActive];
}

- (void)application:(UIApplication *) __unused application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)applicationWillTerminate:(UIApplication *) __unused application
{
    if (self.dataSubstrate.currentUser.signedIn && !self.isPasscodeShowing) {
        NSDate *currentTime = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:currentTime forKey:kLastUsedTimeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (void)applicationDidEnterBackground:(UIApplication *) __unused application
{
    if (self.dataSubstrate.currentUser.signedIn && !self.isPasscodeShowing) {
        NSDate *currentTime = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:currentTime forKey:kLastUsedTimeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.dataSubstrate.currentUser.sessionToken = nil;
    
    [self showSecureView];
}

- (void)applicationWillEnterForeground:(UIApplication *) __unused application
{
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self hideSecureView];
    [self showPasscodeIfNecessary];
}

- (void)                    application: (UIApplication *) __unused application
    didRegisterUserNotificationSettings: (UIUserNotificationSettings *) __unused notificationSettings
{

}

- (void)                                 application: (UIApplication *) __unused application
    didRegisterForRemoteNotificationsWithDeviceToken: (NSData *) __unused deviceToken
{
    [[NSNotificationCenter defaultCenter] postNotificationName:APCAppDidRegisterUserNotification object:nil];
}

- (void)                                 application: (UIApplication *) __unused application
    didFailToRegisterForRemoteNotificationsWithError: (NSError *) __unused error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:APCAppDidFailToRegisterForRemoteNotification object:nil];
}

/*********************************************************************************/
#pragma mark - General initialization
/*********************************************************************************/
- (void) doGeneralInitialization
{
    self.catastrophicStartupError = nil;
}

/*********************************************************************************/
#pragma mark - State Restoration
/*********************************************************************************/

- (BOOL)application:(UIApplication *) __unused application shouldSaveApplicationState:(NSCoder *) __unused coder
{
    [[UIApplication sharedApplication] ignoreSnapshotOnNextApplicationLaunch];
    return self.dataSubstrate.currentUser.isSignedIn;
}

- (BOOL)application:(UIApplication *) __unused application shouldRestoreApplicationState:(NSCoder *) __unused coder
{
    return self.dataSubstrate.currentUser.isSignedIn;
}

- (UIViewController *)application:(UIApplication *) __unused application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *) __unused coder
{
    if ([identifierComponents.lastObject isEqualToString:@"AppTabbar"]) {
        return self.window.rootViewController;
    }
    else if ([identifierComponents.lastObject isEqualToString:@"ActivitiesNavController"])
    {
        return self.tabster.viewControllers[kIndexOfActivitesTab];
    }
    else if ([identifierComponents.lastObject isEqualToString:@"APCActivityVC"])
    {
        if ( [self.tabster.viewControllers[kIndexOfActivitesTab] respondsToSelector:@selector(topViewController)]) {
            return [(UINavigationController*) self.tabster.viewControllers[kIndexOfActivitesTab] topViewController];
        }
    }
    
    return nil;
}

/*********************************************************************************/
#pragma mark - Did Finish Launch Methods
/*********************************************************************************/
- (void) initializeBridgeServerConnection
{
//If in DEBUG mode, automatically point to staging environment. In release mode read from intializationOptions dictionary.
//#if DEBUG
//    [BridgeSDK setupWithAppPrefix:self.initializationOptions[kAppPrefixKey] environment: SBBEnvironmentStaging];
//#else
    [BridgeSDK setupWithAppPrefix:self.initializationOptions[kAppPrefixKey] environment:(SBBEnvironment)[self.initializationOptions[kBridgeEnvironmentKey] integerValue]];
//#endif
}

- (void) initializeAppleCoreStack
{
    self.dataSubstrate = [[APCDataSubstrate alloc] initWithPersistentStorePath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:self.initializationOptions[kDatabaseNameKey]] additionalModels: nil studyIdentifier:self.initializationOptions[kStudyIdentifierKey]];
    self.scheduler = [[APCScheduler alloc] initWithDataSubstrate:self.dataSubstrate];
    self.dataMonitor = [[APCDataMonitor alloc] initWithDataSubstrate:self.dataSubstrate scheduler:self.scheduler];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.passiveDataCollector = [[APCPassiveDataCollector alloc] init];
    });

    
    //Setup AuthDelegate for SageSDK
    SBBAuthManager * manager = (SBBAuthManager*) SBBComponent(SBBAuthManager);
    manager.authDelegate = self.dataSubstrate.currentUser;
}

- (void)loadStaticTasksAndSchedulesIfNecessary
{
    if (![APCDBStatus isSeedLoadedWithContext:self.dataSubstrate.persistentContext]) {
        [APCDBStatus setSeedLoaded:self.initializationOptions[kDBStatusVersionKey] WithContext:self.dataSubstrate.persistentContext];
        NSString *resource = [[NSBundle mainBundle] pathForResource:self.initializationOptions[kTasksAndSchedulesJSONFileNameKey] ofType:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfFile:resource];
        NSError * error;
        NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        APCLogError2 (error);
        
        NSDictionary *manipulatedDictionary = [(APCAppDelegate*)[UIApplication sharedApplication].delegate tasksAndSchedulesWillBeLoaded];
        
        if (manipulatedDictionary != nil) {
            dictionary = manipulatedDictionary;
        }
        
        [self.dataSubstrate loadStaticTasksAndSchedules:dictionary];
        [self clearNSUserDefaults];
        [APCKeychainStore resetKeyChain];
    }
    else
    {
        NSString * dbVersionStr = [APCDBStatus dbStatusVersionwithContext:self.dataSubstrate.persistentContext];
        if (![dbVersionStr isEqualToString:self.initializationOptions[kDBStatusVersionKey]]) {
            [self updateDBVersionStatus];
        }
    }
}

//This method is overridable from each app
- (void) updateDBVersionStatus
{
    NSString *resource = [[NSBundle mainBundle] pathForResource:self.initializationOptions[kTasksAndSchedulesJSONFileNameKey] ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:resource];
    NSError * error;
    NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    APCLogError2 (error);
    
    //Deeper investigation needed for enabling tasksAndSchedulesWillBeLoaded
    /*NSDictionary *manipulatedDictionary = [(APCAppDelegate*)[UIApplication sharedApplication].delegate tasksAndSchedulesWillBeLoaded];
    
    if (manipulatedDictionary != nil) {
        dictionary = manipulatedDictionary;
    }*/
    
    //Enabling refreshing of tasks JSON only. Schedules might be tricky as Apps could manipulate schedules after creation.
    //More investigation needed
    [APCTask updateTasksFromJSON:dictionary[@"tasks"] inContext:self.dataSubstrate.persistentContext];
    //[APCSchedule updateSchedulesFromJSON:dictionary[@"schedules"] inContext:self.dataSubstrate.persistentContext];
    [APCDBStatus updateSeedLoaded:self.initializationOptions[kDBStatusVersionKey] WithContext:self.dataSubstrate.persistentContext];
}

- (NSMutableArray*)consentSectionsAndHtmlContent:(NSString**)htmlContent
{
    ORKConsentSectionType(^toSectionType)(NSString*) = ^(NSString* sectionTypeName)
    {
        ORKConsentSectionType   sectionType = ORKConsentSectionTypeCustom;
        
        if ([sectionTypeName isEqualToString:@"overview"])
        {
            sectionType = ORKConsentSectionTypeOverview;
        }
        else if ([sectionTypeName isEqualToString:@"privacy"])
        {
            sectionType = ORKConsentSectionTypePrivacy;
        }
        else if ([sectionTypeName isEqualToString:@"dataGathering"])
        {
            sectionType = ORKConsentSectionTypeDataGathering;
        }
        else if ([sectionTypeName isEqualToString:@"dataUse"])
        {
            sectionType = ORKConsentSectionTypeDataUse;
        }
        else if ([sectionTypeName isEqualToString:@"timeCommitment"])
        {
            sectionType = ORKConsentSectionTypeTimeCommitment;
        }
        else if ([sectionTypeName isEqualToString:@"studySurvey"])
        {
            sectionType = ORKConsentSectionTypeStudySurvey;
        }
        else if ([sectionTypeName isEqualToString:@"studyTasks"])
        {
            sectionType = ORKConsentSectionTypeStudyTasks;
        }
        else if ([sectionTypeName isEqualToString:@"withdrawing"])
        {
            sectionType = ORKConsentSectionTypeWithdrawing;
        }
        else if ([sectionTypeName isEqualToString:@"custom"])
        {
            sectionType = ORKConsentSectionTypeCustom;
        }
        else if ([sectionTypeName isEqualToString:@"onlyInDocument"])
        {
            sectionType = ORKConsentSectionTypeOnlyInDocument;
        }

        return sectionType;
    };
    NSString*   kDocumentHtml           = @"htmlDocument";
    NSString*   kConsentSections        = @"sections";
    NSString*   kSectionType            = @"sectionType";
    NSString*   kSectionTitle           = @"sectionTitle";
    NSString*   kSectionFormalTitle     = @"sectionFormalTitle";
    NSString*   kSectionSummary         = @"sectionSummary";
    NSString*   kSectionContent         = @"sectionContent";
    NSString*   kSectionHtmlContent     = @"sectionHtmlContent";
    NSString*   kSectionImage           = @"sectionImage";
    NSString*   kSectionAnimationUrl    = @"sectionAnimationUrl";
    
    NSString*       resource = [[NSBundle mainBundle] pathForResource:self.initializationOptions[kConsentSectionFileNameKey] ofType:@"json"];
    NSAssert(resource != nil, @"Unable to location file with Consent Section in main bundle");
    
    NSData*         consentSectionData = [NSData dataWithContentsOfFile:resource];
    NSAssert(consentSectionData != nil, @"Unable to create NSData with Consent Section data");
    
    NSError*        error             = nil;
    NSDictionary*   consentParameters = [NSJSONSerialization JSONObjectWithData:consentSectionData options:NSJSONReadingMutableContainers error:&error];
    NSAssert(consentParameters != nil, @"badly formed Consent Section data - error", error);
    
    NSString*       documentHtmlContent = [consentParameters objectForKey:kDocumentHtml];
    NSAssert(documentHtmlContent == nil || documentHtmlContent != nil && [documentHtmlContent isKindOfClass:[NSString class]], @"Improper Document HTML Content type");
    
    if (documentHtmlContent != nil && htmlContent != nil)
    {
        NSString*   path    = [[NSBundle mainBundle] pathForResource:documentHtmlContent ofType:@"html" inDirectory:@"HTMLContent"];
        NSAssert(path != nil, @"Unable to locate HTML file: %@", documentHtmlContent);
        
        NSError*    error   = nil;
        NSString*   content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        
        NSAssert(content != nil, @"Unable to load content of file \"%@\": %@", path, error);
        
        *htmlContent = content;
    }
    
    NSArray*        parametersConsentSections = [consentParameters objectForKey:kConsentSections];
    NSAssert(parametersConsentSections != nil && [parametersConsentSections isKindOfClass:[NSArray class]], @"Badly formed Consent Section data");
    
    NSMutableArray* consentSections = [NSMutableArray arrayWithCapacity:parametersConsentSections.count];
    
    for (NSDictionary* section in parametersConsentSections)
    {
        //  Custom typesdo not have predefiend title, summary, content, or animation
        NSAssert([section isKindOfClass:[NSDictionary class]], @"Improper section type");
        
        NSString*   typeName     = [section objectForKey:kSectionType];
        NSAssert(typeName != nil && [typeName isKindOfClass:[NSString class]],    @"Missing Section Type or improper type");
        
        ORKConsentSectionType   sectionType = toSectionType(typeName);
        
        NSString*   title        = [section objectForKey:kSectionTitle];
        NSString*   formalTitle  = [section objectForKey:kSectionFormalTitle];
        NSString*   summary      = [section objectForKey:kSectionSummary];
        NSString*   content      = [section objectForKey:kSectionContent];
        NSString*   htmlContent  = [section objectForKey:kSectionHtmlContent];
        NSString*   image        = [section objectForKey:kSectionImage];
        NSString*   animationUrl = [section objectForKey:kSectionAnimationUrl];
        
        NSAssert(title        == nil || title         != nil && [title isKindOfClass:[NSString class]],        @"Missing Section Title or improper type");
        NSAssert(formalTitle  == nil || formalTitle   != nil && [formalTitle isKindOfClass:[NSString class]],  @"Missing Section Formal title or improper type");
        NSAssert(summary      == nil || summary       != nil && [summary isKindOfClass:[NSString class]],      @"Missing Section Summary or improper type");
        NSAssert(content      == nil || content       != nil && [content isKindOfClass:[NSString class]],      @"Missing Section Content or improper type");
        NSAssert(htmlContent  == nil || htmlContent   != nil && [htmlContent isKindOfClass:[NSString class]],  @"Missing Section HTML Content or improper type");
        NSAssert(image        == nil || image         != nil && [image isKindOfClass:[NSString class]],        @"Missing Section Image or improper typte");
        NSAssert(animationUrl == nil || animationUrl  != nil && [animationUrl isKindOfClass:[NSString class]], @"Missing Animation URL or improper type");
        
        
        ORKConsentSection*  section = [[ORKConsentSection alloc] initWithType:sectionType];
        
        if (title != nil)
        {
            section.title = title;
        }
        
        if (formalTitle != nil)
        {
            section.formalTitle = formalTitle;
        }
        
        if (summary != nil)
        {
            section.summary = summary;
        }
        
        if (content != nil)
        {
            section.content = content;
        }
        
        if (htmlContent != nil)
        {
            NSString*   path    = [[NSBundle mainBundle] pathForResource:htmlContent ofType:@"html" inDirectory:@"HTMLContent"];
            NSAssert(path != nil, @"Unable to locate HTML file: %@", htmlContent);
            
            NSError*    error   = nil;
            NSString*   content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];

            NSAssert(content != nil, @"Unable to load content of file \"%@\": %@", path, error);
            
            section.htmlContent = content;
        }
        
        if (image != nil)
        {
            section.customImage = [UIImage imageNamed:image];
            NSAssert(section.customImage != nil, @"Unable to load image: %@", image);
        }
        
        if (animationUrl != nil)
        {
            NSString * nameWithScaleFactor = animationUrl;
            if ([[UIScreen mainScreen] scale] >= 3) {
                nameWithScaleFactor = [nameWithScaleFactor stringByAppendingString:@"@3x"];
            } else {
                nameWithScaleFactor = [nameWithScaleFactor stringByAppendingString:@"@2x"];
            }
            NSURL*      url   = [[NSBundle mainBundle] URLForResource:nameWithScaleFactor withExtension:@"m4v"];
            NSError*    error = nil;
            
            NSAssert([url checkResourceIsReachableAndReturnError:&error] == YES, @"Animation file--%@--not reachable: %@", animationUrl, error);
            section.customAnimationURL = url;
        }
        
        [consentSections addObject:section];
    }
    
    return consentSections;
}

- (void) setUpHKPermissions
{
    [APCPermissionsManager setHealthKitTypesToRead:self.initializationOptions[kHKReadPermissionsKey]];
    [APCPermissionsManager setHealthKitTypesToWrite:self.initializationOptions[kHKWritePermissionsKey]];
}

- (void) setUpTasksReminder {
    self.tasksReminder = [APCTasksReminderManager new];
}

- (NSArray *)offsetForTaskSchedules
{
    return nil;
}

- (void)afterOnBoardProcessIsFinished
{
    /* Abstract implementation. Subclass to override 
     *
     * Use this as a hook to post-process anything that is needed
     * to be processed right after the 'finishOnboarding' method
     * is invoked.
     */
}

// Review Consent Actions
- (NSArray *)reviewConsentActions
{
    return nil;
}

/*********************************************************************************/
#pragma mark - Catastrophic startup errors
/*********************************************************************************/
- (void) registerCatastrophicStartupError: (NSError *) error
{
    self.catastrophicStartupError = error;
}

- (BOOL) hadCatastrophicStartupError
{
    return self.catastrophicStartupError != nil;
}

- (void) showCatastrophicStartupError
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName: @"CatastrophicError"
                                                         bundle: [NSBundle appleCoreBundle]];

    UIViewController *errorViewController = [storyBoard instantiateInitialViewController];

    self.window.rootViewController = errorViewController;
    NSError *error = self.catastrophicStartupError;

    __block APCAppDelegate *blockSafeSelf = self;

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        UIAlertController *alert = [UIAlertController simpleAlertWithTitle: error.userInfo [NSLocalizedFailureReasonErrorKey]
                                                                   message: error.userInfo [NSLocalizedRecoverySuggestionErrorKey]];

        [blockSafeSelf.window.rootViewController presentViewController: alert animated: YES completion: nil];
    }];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) signedUpNotification: (NSNotification*) __unused notification
{
    [self showNeedsEmailVerification];
}

- (void) signedInNotification: (NSNotification*) __unused notification
{
    [self.dataMonitor userConsented];
    [self.tasksReminder updateTasksReminder];
    [self showTabBar];
}

- (void) userConsented: (NSNotification*) __unused notification
{

}

- (void) logOutNotification: (NSNotification*) __unused notification
{
    self.dataSubstrate.currentUser.signedUp = NO;
    self.dataSubstrate.currentUser.signedIn = NO;
    [APCKeychainStore removeValueForKey:kPasswordKey];
    [self.tasksReminder updateTasksReminder];
    [self showOnBoarding];
}

- (void) withdrawStudy: (NSNotification *) __unused notification
{
    [self clearNSUserDefaults];
    [APCKeychainStore resetKeyChain];
    [self.dataSubstrate resetCoreData];
    [self.tasksReminder updateTasksReminder];
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
- (id <APCProfileViewControllerDelegate>) profileExtenderDelegate {
    return nil;
}

- (NSDictionary *) tasksAndSchedulesWillBeLoaded {
    return nil;
}

/*********************************************************************************/
#pragma mark - Public Helpers
/*********************************************************************************/
- (NSMutableDictionary *)defaultInitializationOptions
{
    //Return Default Dictionary
    return [@{
              kDatabaseNameKey                     : kDatabaseName,
              kTasksAndSchedulesJSONFileNameKey    : kTasksAndSchedulesJSONFileName,
              kConsentSectionFileNameKey           : kConsentSectionFileName,
              kDBStatusVersionKey                  : kDBStatusCurrentVersion
              } mutableCopy];
}

- (APCDebugWindow *)window
{
    static APCDebugWindow *customWindow = nil;
    if (!customWindow) customWindow = [[APCDebugWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
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
                            @{@"name": kActivitiesStoryBoardKey, @"bundle" : [NSBundle appleCoreBundle]},
                            @{@"name": kDashBoardStoryBoardKey, @"bundle" : [NSBundle mainBundle]},
                            @{@"name": kLearnStoryBoardKey, @"bundle" : [NSBundle appleCoreBundle]},
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
    
    NSUInteger     selectedItemIndex = kIndexOfActivitesTab;
    
    NSArray  *deselectedImageNames = @[ @"tab_activities", @"tab_dashboard", @"tab_learn", @"tab_profile" ];
    NSArray  *selectedImageNames   = @[ @"tab_activities_selected", @"tab_dashboard_selected", @"tab_learn_selected",  @"tab_profile_selected" ];
    NSArray  *tabBarTitles         = @[ @"Activities", @"Dashboard", @"Learn",  @"Profile"];
    
    for (NSUInteger i=0; i<items.count; i++) {
        UITabBarItem  *item = items[i];
        item.image = [UIImage imageNamed:deselectedImageNames[i]];
        item.selectedImage = [[UIImage imageNamed:selectedImageNames[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        item.title = tabBarTitles[i];
        
        if (i == kIndexOfActivitesTab) {
            NSUInteger allScheduledTasks = self.dataSubstrate.countOfAllScheduledTasksForToday;
            NSUInteger completedScheduledTasks = self.dataSubstrate.countOfCompletedScheduledTasksForToday;
            
            NSNumber *activitiesBadgeValue = (completedScheduledTasks < allScheduledTasks) ? @(allScheduledTasks - completedScheduledTasks) : @(0);
            
            if ([activitiesBadgeValue integerValue] != 0) {
                item.badgeValue = [activitiesBadgeValue stringValue];
            } else {
                item.badgeValue = nil;
            }
        }
    }
    
    NSArray  *controllers = tabBarController.viewControllers;
    
    //These need to be "Selected" one by one it silly but I remember this from a pass issue.
    //We can hard code this as long as it matches the tab count above
    // Might want to refactor this more hwne we have time
    [tabBarController setSelectedIndex:selectedItemIndex + 1];
    [tabBarController setSelectedIndex:selectedItemIndex + 2];
    [tabBarController setSelectedIndex:selectedItemIndex + 3];
    [tabBarController setSelectedIndex:selectedItemIndex];
    
    [self tabBarController:tabBarController didSelectViewController:controllers[selectedItemIndex]];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    self.tabster = (UITabBarController  *)self.window.rootViewController;
    NSArray  *deselectedImageNames = @[ @"tab_activities",          @"tab_dashboard",           @"tab_learn",           @"tab_profile" ];
    NSArray  *selectedImageNames   = @[ @"tab_activities_selected", @"tab_dashboard_selected",  @"tab_learn_selected",  @"tab_profile_selected" ];
    NSArray  *tabBarTitles         = @[ @"Activities",              @"Dashboard",               @"Learn",               @"Profile"];
    
    if ([viewController isMemberOfClass: [UIViewController class]] == YES) {
        
        NSMutableArray  *controllers = [tabBarController.viewControllers mutableCopy];
        NSUInteger  controllerIndex = [controllers indexOfObject:viewController];
        
        NSString  *name = [self.storyboardIdInfo objectAtIndex:controllerIndex][@"name"];
        UIStoryboard  *storyboard = [UIStoryboard storyboardWithName:name bundle:[self.storyboardIdInfo objectAtIndex:controllerIndex][@"bundle"]];
        UIViewController  *controller = [storyboard instantiateInitialViewController];
        [controllers replaceObjectAtIndex:controllerIndex withObject:controller];
        
        [self.tabster setViewControllers:controllers animated:NO];
        self.tabster.tabBar.tintColor = [UIColor appPrimaryColor];
        UITabBarItem  *item = self.tabster.tabBar.selectedItem;
        item.image = [UIImage imageNamed:deselectedImageNames[controllerIndex]];
        item.selectedImage = [[UIImage imageNamed:selectedImageNames[controllerIndex]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        item.title = tabBarTitles[controllerIndex];
        
        if (controllerIndex == kIndexOfProfileTab)
        {
            
            UINavigationController * profileNavigationController = (UINavigationController *) controller;
            
            if ( [profileNavigationController.childViewControllers[0] isKindOfClass:[APCProfileViewController class]])
            {
                
                self.profileViewController = (APCProfileViewController *) profileNavigationController.childViewControllers[0];
                
                self.profileViewController.delegate = [self profileExtenderDelegate];
            }
        }
        
        if (controllerIndex == kIndexOfActivitesTab) {
            NSUInteger allScheduledTasks = self.dataSubstrate.countOfAllScheduledTasksForToday;
            NSUInteger completedScheduledTasks = self.dataSubstrate.countOfCompletedScheduledTasksForToday;
            
            NSNumber *remainingTasks = (completedScheduledTasks < allScheduledTasks) ? @(allScheduledTasks - completedScheduledTasks) : @(0);
            
            if ([remainingTasks integerValue] != 0) {
                item.badgeValue = [remainingTasks stringValue];
            } else {
                item.badgeValue = nil;
            }
        }
    }
}

/*********************************************************************************/
#pragma mark - Show Methods
/*********************************************************************************/
- (void) showAppropriateVC
{
    if (self.hadCatastrophicStartupError)
    {
        [self showCatastrophicStartupError];
    }
    else if (self.dataSubstrate.currentUser.isSignedIn)
    {
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
    if (self.dataSubstrate.currentUser.isSignedIn && !self.isPasscodeShowing) {
        NSDate *lastUsedTime = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUsedTimeKey];
        
        if (lastUsedTime) {
            NSTimeInterval timeDifference = [lastUsedTime timeIntervalSinceNow];
            NSInteger numberOfMinutes = [self.dataSubstrate.parameters integerForKey:kNumberOfMinutesForPasscodeKey];
            
            if (timeDifference * -1 > numberOfMinutes * 60) {

                [self showPasscode];
            }
        }
    } else {
        self.isPasscodeShowing = NO;
    }
}

- (void)showPasscode
{
    if ([self.window.rootViewController isKindOfClass:[APCTabBarViewController class]]) {
        APCTabBarViewController * tvc = (APCTabBarViewController*) self.window.rootViewController;
        self.isPasscodeShowing = YES;
        tvc.showPasscodeScreen = YES;
    }
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
                       options:UIViewAnimationOptionTransitionNone
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

- (ORKTaskViewController *)consentViewController
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

- (APCScene *) inclusionCriteriaSceneForOnboarding: (APCOnboarding *) __unused onboarding
{
    NSAssert(FALSE, @"Cannot retun nil. Override this delegate method to return a valid APCScene.");
    
    return nil;
}

#pragma mark - APCOnboardingTaskDelegate methods

- (APCUser *) userForOnboardingTask: (APCOnboardingTask *) __unused task
{
    return self.dataSubstrate.currentUser;
}

- (NSInteger) numberOfServicesInPermissionsListForOnboardingTask: (APCOnboardingTask *) __unused task
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

#pragma mark - Secure View

- (void)showSecureView
{
    UIView *viewForSnapshot = self.window.rootViewController.presentedViewController ? self.window.rootViewController.presentedViewController.view : self.window.rootViewController.view;
    if (self.secureView == nil) {
        self.secureView = [[UIView alloc] initWithFrame:self.window.rootViewController.view.bounds];
        
        UIImage *blurredImage = [self.window.rootViewController.view blurredSnapshot];
        UIImage *appIcon = [UIImage imageNamed:@"logo_disease_large" inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
        UIImageView *blurredImageView = [[UIImageView alloc] initWithImage:blurredImage];
        UIImageView *appIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 180, 180)];

        appIconImageView.image = appIcon;
        appIconImageView.center = blurredImageView.center;
        appIconImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.secureView addSubview:blurredImageView];
        [self.secureView addSubview:appIconImageView];
        
        [viewForSnapshot insertSubview:self.secureView atIndex:NSIntegerMax];
    }
}

- (void)hideSecureView
{
    if (self.secureView) {
        [self.secureView removeFromSuperview];
        self.secureView = nil;
    }
}


@end
