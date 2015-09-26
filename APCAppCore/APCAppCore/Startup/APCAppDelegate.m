//
//  APCAppDelegate.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCAppDelegate.h"
#import "APCAppCore.h"
#import "APCDebugWindow.h"
#import "APCPasscodeViewController.h"
#import "APCTasksReminderManager.h"
#import "UIView+Helper.h"
#import "UIAlertController+Helper.h"
#import "APCDemographicUploader.h"
#import "APCConstants.h"
#import "APCUtilities.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

/*
 Be sure to set the CORRECT current version before releasing to production
 */
NSUInteger   const kTheEntireDataModelOfTheApp              = 3;

/*********************************************************************************/
#pragma mark - Initializations Option Defaults
/*********************************************************************************/
static NSString*    const kDataSubstrateClassName           = @"APHDataSubstrate";
static NSString*    const kTasksAndSchedulesJSONFileName    = @"APHTasksAndSchedules";
static NSString*    const kConsentSectionFileName           = @"APHConsentSection";

static NSString*    const kDBStatusCurrentVersion           = @"v1.0";

/*********************************************************************************/
#pragma mark - Tab bar Constants
/*********************************************************************************/
static NSString *const kDashBoardStoryBoardKey     = @"APHDashboard";
static NSString *const kLearnStoryBoardKey         = @"APCLearn";
static NSString *const kActivitiesStoryBoardKey    = @"APCActivities";
static NSString *const kHealthProfileStoryBoardKey = @"APCProfile";
static NSString *const kNewsFeedStoryBoardKey      = @"APCNewsFeed";

/*********************************************************************************/
#pragma mark - User Defaults Keys
/*********************************************************************************/

static NSString*    const kDemographicDataWasUploadedKey    = @"kDemographicDataWasUploadedKey";
static NSString*    const kLastUsedTimeKey                  = @"APHLastUsedTime";
static NSString*    const kAppWillEnterForegroundTimeKey    = @"APCWillEnterForegroundTime";

@interface APCAppDelegate  ( )  <UITabBarControllerDelegate>

@property (nonatomic) BOOL isPasscodeShowing;
@property (nonatomic, strong) UIView *secureView;
@property (nonatomic, strong) NSError *catastrophicStartupError;
@property (nonatomic, strong) NSOperationQueue *healthKitCollectorQueue;
@property (nonatomic, strong) APCDemographicUploader  *demographicUploader;
@property (nonatomic, strong) APCPasscodeViewController *passcodeViewController;

@property (nonatomic, strong, readwrite) APCOnboardingManager *onboardingManager;

@end

@implementation APCAppDelegate

+ (instancetype)sharedAppDelegate
{
    APCAppDelegate *appDelegate = (APCAppDelegate *) [[UIApplication sharedApplication] delegate];
    return appDelegate;
}


/*********************************************************************************/
#pragma mark - App Delegate Methods
/*********************************************************************************/
- (BOOL)               application: (UIApplication *) __unused application
    willFinishLaunchingWithOptions: (NSDictionary *) __unused launchOptions
{
    NSUInteger  previousVersion = [self obtainPreviousVersion];
    [self performMigrationFrom:previousVersion currentVersion:kTheEntireDataModelOfTheApp];
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [self setUpInitializationOptions];
    NSAssert(self.initializationOptions, @"Please set up initialization options");

    [self doGeneralInitialization];
    [self initializeBridgeServerConnection];
    [self initializeAppleCoreStack];

    [self registerNotifications];
    [self setUpAppAppearance];
    [self setUpTasksReminder];
    [self performDemographicUploadIfRequired];
    [self showAppropriateVC];
    
    return YES;
}

- (void)performDemographicUploadIfRequired
{
    NSUserDefaults  *defaults = [NSUserDefaults standardUserDefaults];
    
        //
        //    the Boolean will be NO if:
        //        the user defaults value was never set
        //        the actual value is NO (which should never happen)
        //    in which case, we upload the (non-identifiable) Demographic data
        //    Age, Sex, Height, Weight, Sleep Time, Wake Time, et al
        //
        //    otherwise, the value should have been set to YES, to
        //    indicate that the Demographic data was previously uploaded
        //
    
        //
        //    we run this code iff the user has previously consented,
        //    indicating that this is an update to a previously installed version of the application
        //
    APCUser  *user = self.dataSubstrate.currentUser;
    if (user.isConsented) {
        BOOL  demographicDataWasUploaded = [defaults boolForKey:kDemographicDataWasUploadedKey];
        if (demographicDataWasUploaded == NO) {
            self.demographicUploader = [[APCDemographicUploader alloc] initWithUser:user];
            [defaults setBool:YES forKey:kDemographicDataWasUploadedKey];
            [defaults synchronize];
            [self.demographicUploader uploadNonIdentifiableDemographicData];
        }
    }
}

- (NSUInteger)obtainPreviousVersion {
    NSUserDefaults* defaults        = [NSUserDefaults standardUserDefaults];
    return (NSUInteger) [defaults integerForKey:@"previousVersion"];
}

- (void)performMigrationAfterFirstImport
{
    /* abstract implementation */
}

- (void)performMigrationFrom:(NSInteger) __unused previousVersion currentVersion:(NSInteger)__unused currentVersion
{
    /* abstract implementation */
}

- (void)performMigrationAfterDataSubstrateFrom:(NSInteger) __unused previousVersion currentVersion:(NSInteger) __unused currentVersion
{
    /* abstract implementation */
}

- (BOOL)application:(UIApplication *) __unused application didFinishLaunchingWithOptions:(NSDictionary *) __unused launchOptions
{
    self.dataUploader = [[APCDataUploader alloc] init];
    [self.dataMonitor appFinishedLaunching];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *) __unused application
{
    // This will dismiss the keyboard, if one is visible
    [self.window endEditing:YES];
    [self showSecureView];
}

- (void)applicationDidBecomeActive:(UIApplication *) __unused application
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kAppWillEnterForegroundTimeKey];
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
    [self.dataMonitor appBecameActive];
}

- (void)application:(UIApplication *) __unused application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)applicationWillTerminate:(UIApplication *) __unused application
{
    if (self.dataSubstrate.currentUser.signedIn && !self.isPasscodeShowing) {
        [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithLong:uptime()] forKey:kLastUsedTimeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (NSDate*)applicationBecameActiveDate
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAppWillEnterForegroundTimeKey];
}

- (void)applicationDidEnterBackground:(UIApplication *) __unused application
{
    if (self.dataSubstrate.currentUser.signedIn && !self.isPasscodeShowing) {
        [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithLong:uptime()] forKey:kLastUsedTimeKey];
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
    didRegisterUserNotificationSettings: (UIUserNotificationSettings *) notificationSettings
{
    if (notificationSettings) {
        [[NSNotificationCenter defaultCenter]postNotificationName:APCAppDidRegisterUserNotification object:notificationSettings];
    }
    
}

/*********************************************************************************/
#pragma mark - General initialization
/*********************************************************************************/
- (void) doGeneralInitialization
{
    NSError*    error = nil;
    BOOL        fileSecurityPermissionsResetSuccessful = [self resetFileSecurityPermissionsWithError:&error];
    
    if (fileSecurityPermissionsResetSuccessful == NO)
    {
        APCLogDebug(@"Incomplete reset of file system security permissions");
        APCLogError2(error);
    }
    
    self.catastrophicStartupError = nil;
    
    //initialize tasksReminder
    self.tasksReminder = [APCTasksReminderManager new];
}

- (BOOL)resetFileSecurityPermissionsWithError:(NSError* __autoreleasing *)error
{
    NSArray*                paths               = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*               documentsDirectory  = [paths objectAtIndex:0];
    NSFileManager*          fileManager         = [NSFileManager defaultManager];
    NSDirectoryEnumerator*  directoryEnumerator = [fileManager enumeratorAtPath:documentsDirectory];

    BOOL                    isSuccessful     = NO;
    
    for (NSString* relativeFilePath in directoryEnumerator)
    {
        NSDictionary*   attributes = directoryEnumerator.fileAttributes;
        
        if ([[attributes objectForKey:NSFileProtectionKey] isEqual:NSFileProtectionComplete])
        {
            NSString*   absoluteFilePath = [documentsDirectory stringByAppendingPathComponent:relativeFilePath];
            
            attributes   = @{ NSFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication };
            isSuccessful = [fileManager setAttributes:attributes ofItemAtPath:absoluteFilePath error:error];
            if (isSuccessful == NO && error != nil)
            {
                APCLogError2(*error);
            }
        }
    }
    
    return isSuccessful;
}

/*********************************************************************************/
#pragma mark - Did Finish Launch Methods
/*********************************************************************************/
- (void) initializeBridgeServerConnection
{
    [BridgeSDK setupWithStudy:self.initializationOptions[kAppPrefixKey] environment:(SBBEnvironment)[self.initializationOptions[kBridgeEnvironmentKey] integerValue]];
}

- (BOOL) determineIfPeresistentStoreExists {
    
    BOOL persistenStoreExists = NO;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:
          [[self applicationDocumentsDirectory] stringByAppendingPathComponent:self.initializationOptions[kDatabaseNameKey]]])
    {
        persistenStoreExists = YES;
    }
    
    return persistenStoreExists;
}

- (void) initializeAppleCoreStack
{
    //Check if persistent store (db.sqlite file) exists
    self.persistentStoreExistence = [self determineIfPeresistentStoreExists];
    
    self.dataSubstrate = [[APCDataSubstrate alloc] initWithPersistentStorePath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:self.initializationOptions[kDatabaseNameKey]] additionalModels: nil studyIdentifier:self.initializationOptions[kStudyIdentifierKey]];
    
    [self performMigrationAfterDataSubstrateFrom:[self obtainPreviousVersion] currentVersion:kTheEntireDataModelOfTheApp];
    
    self.scheduler = [[APCScheduler alloc] initWithDataSubstrate:self.dataSubstrate];
    self.dataMonitor = [[APCDataMonitor alloc] initWithDataSubstrate:self.dataSubstrate scheduler:self.scheduler];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.passiveDataCollector = [[APCPassiveDataCollector alloc] init];
    });
    
    
    //Setup AuthDelegate for SageSDK
    SBBAuthManager * manager = (SBBAuthManager*) SBBComponent(SBBAuthManager);
    manager.authDelegate = self.dataSubstrate.currentUser;
}

//This method is overridable from each app
- (void) updateDBVersionStatus
{
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
            
            NSAssert([url checkResourceIsReachableAndReturnError:&error], @"Animation file--%@--not reachable: %@", animationUrl, error);
            section.customAnimationURL = url;
        }
        
        [consentSections addObject:section];
    }
    
    return consentSections;
}


- (void) setUpTasksReminder {/*Abstract Implementation*/}

-(void)application:(UIApplication *)__unused application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler{
    
    if ([identifier isEqualToString:kDelayReminderIdentifier]) {
        notification.fireDate = [notification.fireDate dateByAddingTimeInterval:3600];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    completionHandler();
}

- (NSArray *)offsetForTaskSchedules
{
    //TODO: Number of days should be zero based. If I want something to show up on day 2 then the offset is 1
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

// The block of text for the All Set
- (NSArray *)allSetTextBlocks
{
    /* Abstract implementaion. Subclass to override.
     *
     * Use this to provide custom text on the All Set
     * screen.
     *
     * Please don't be glutenous, don't use four words
     * when one would suffice.
     */
    
    return nil;
}

- (NSDictionary *)configureTasksForActivities
{
    /* Abstract implementation. Subclass to override.
     *
     * Use this to properly group your tasks into the three groups
     * that are now shown on the Activities tab.
     * 
     * 1. Todays tasks
     * 2. Keep Going
     * 3. Yesterday's incomplete tasks
     *
     * Note: This needs to be refactored
     */
    return nil;
}

- (BOOL)hideEmailOnWelcomeScreen
{
    /* Abstract implementation. Subclass to override.
     *
     * To hide the email consent button on the Welcome screen return YES.
     */
    return NO;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(withdrawStudy:) name:APCUserDidWithdrawStudyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newsFeedUpdated:) name:kAPCNewsFeedUpdateNotification object:nil];
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

- (void)newsFeedUpdated:(NSNotification *)__unused notification
{
    if ([self.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        
        BOOL newsFeedTab = [self.initializationOptions[kNewsFeedTabKey] boolValue];
        
        NSArray *items = tabBarController.tabBar.items;
        UITabBarItem *item = items[kAPCNewsFeedTabIndex];
        
        if (newsFeedTab){
            NSUInteger unreadPostsCount = [self.dataSubstrate.newsFeedManager unreadPostsCount];
            NSNumber *unreadValue = @(unreadPostsCount);
            
            if (unreadPostsCount != 0) {
                item.badgeValue = [unreadValue stringValue];
            } else {
                item.badgeValue = nil;
            }
        }
    }
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

- (void)showTabBar
{
    self.tabBarController = [[UITabBarController alloc] init];
    NSUInteger selectedItemIndex = kAPCActivitiesTabIndex;
    
    NSMutableArray *tabBarItems = [NSMutableArray new];
    NSMutableArray *viewControllers = [NSMutableArray new];
    
    {
        //Activities Tab
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Activities", nil) image:[UIImage imageNamed:@"tab_activities"] selectedImage:[UIImage imageNamed:@"tab_activities_selected"]];
        [tabBarItems addObject:item];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kActivitiesStoryBoardKey bundle:[NSBundle appleCoreBundle]];
        UIViewController *viewController = [storyboard instantiateInitialViewController];
        [viewControllers addObject:viewController];
    }
    
    {
        //Dashboard Tab
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Dashboard", nil) image:[UIImage imageNamed:@"tab_dashboard"] selectedImage:[UIImage imageNamed:@"tab_dashboard_selected"]];
        [tabBarItems addObject:item];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kDashBoardStoryBoardKey bundle:[NSBundle mainBundle]];
        UIViewController *viewController = [storyboard instantiateInitialViewController];
        [viewControllers addObject:viewController];
    }
    
    BOOL newsFeedTab = [self.initializationOptions[kNewsFeedTabKey] boolValue];
    if (newsFeedTab) {
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"News Feed", nil) image:[UIImage imageNamed:@"tab_newsfeed"] selectedImage:[UIImage imageNamed:@"tab_newsfeed_selected"]];
        [tabBarItems addObject:item];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kNewsFeedStoryBoardKey bundle:[NSBundle appleCoreBundle]];
        UIViewController *viewController = [storyboard instantiateInitialViewController];
        [viewControllers addObject:viewController];
    }
    
    {
        //Learn Tab
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Learn", nil) image:[UIImage imageNamed:@"tab_learn"] selectedImage:[UIImage imageNamed:@"tab_learn_selected"]];
        [tabBarItems addObject:item];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kLearnStoryBoardKey bundle:[NSBundle appleCoreBundle]];
        UIViewController *viewController = [storyboard instantiateInitialViewController];
        [viewControllers addObject:viewController];
    }
    
    {
        //Profile Tab
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Profile", nil) image:[UIImage imageNamed:@"tab_profile"] selectedImage:[UIImage imageNamed:@"tab_profile_selected"]];
        [tabBarItems addObject:item];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kHealthProfileStoryBoardKey bundle:[NSBundle appleCoreBundle]];
        UIViewController *viewController = [storyboard instantiateInitialViewController];
        [viewControllers addObject:viewController];
    }
    
    [self.tabBarController setViewControllers:[NSArray arrayWithArray:viewControllers]];
    
    NSArray *items = self.tabBarController.tabBar.items;
    
    for (NSUInteger i=0; i<items.count; i++) {
        UITabBarItem *item = items[i];
        UITabBarItem *tabBarItem = tabBarItems[i];
        
        item.image = tabBarItem.image;
        item.selectedImage = tabBarItem.selectedImage;
        item.title = tabBarItem.title;
        item.tag = i;
        
        if (i == kAPCNewsFeedTabIndex && newsFeedTab){
            [self updateNewsFeedBadgeCount];
        }
    }
    
    //The tab bar icons take the default tint color from UIView Appearance tintin iOS8. In order to fix this for we are selecting each of the tabs.
    {
        [self.tabBarController setSelectedIndex:0];
        [self.tabBarController setSelectedIndex:1];
        [self.tabBarController setSelectedIndex:2];
        [self.tabBarController setSelectedIndex:3];
        if (newsFeedTab) {
            [self.tabBarController setSelectedIndex:4];
        }
    }
    
    [self.tabBarController setSelectedIndex:selectedItemIndex];
    self.tabBarController.delegate = self;
    self.tabBarController.tabBar.translucent = NO;
    self.window.rootViewController = self.tabBarController;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UIViewController class]]) {
        
        NSUInteger  controllerIndex = [tabBarController.viewControllers indexOfObject:viewController];
        
        BOOL newsFeedTab = [self.initializationOptions[kNewsFeedTabKey] boolValue];
        NSUInteger indexOfProfileTab = newsFeedTab ? 4 : 3;
        
        if (controllerIndex == indexOfProfileTab)
        {
            UINavigationController * profileNavigationController = (UINavigationController *) viewController;
            
            if ( [profileNavigationController.childViewControllers[0] isKindOfClass:[APCProfileViewController class]])
            {
                self.profileViewController = (APCProfileViewController *) profileNavigationController.childViewControllers[0];
                
                self.profileViewController.delegate = [self profileExtenderDelegate];
            }
        }
        
        if(controllerIndex == kAPCNewsFeedTabIndex && newsFeedTab){
            [self updateNewsFeedBadgeCount];
        }
    }
}

- (void)updateNewsFeedBadgeCount
{
    NSUInteger unreadPostsCount = [self.dataSubstrate.newsFeedManager unreadPostsCount];
    NSNumber *unreadValue = @(unreadPostsCount);
    
    UITabBarItem *item = self.tabBarController.tabBar.items[kAPCNewsFeedTabIndex];
    
    if (unreadPostsCount != 0) {
        item.badgeValue = [unreadValue stringValue];
    } else {
        item.badgeValue = nil;
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
        [self showPasscodeViewController];
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
        NSInteger numberOfMinutes = [self.dataSubstrate.parameters integerForKey:kNumberOfMinutesForPasscodeKey];
        NSNumber *lastPasscodeSuccessTime = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUsedTimeKey];
        long timeDifference = uptime() - lastPasscodeSuccessTime.longValue;
        if (timeDifference > numberOfMinutes * 60) {
            [self showPasscodeViewController];
        }
    }
}

- (void)showPasscodeViewController
{
    if (!self.passcodeViewController) {
        self.passcodeViewController = [[UIStoryboard storyboardWithName:@"APCPasscode" bundle:[NSBundle appleCoreBundle]] instantiateInitialViewController];
        self.passcodeViewController.passcodeViewControllerDelegate = self;
    }
    
    self.window.rootViewController = self.passcodeViewController;
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

#pragma mark - Onboarding Manager

- (APCOnboardingManager *)onboardingManager {
    if (!_onboardingManager) {
        self.onboardingManager = [APCOnboardingManager managerWithProvider:self user:self.dataSubstrate.currentUser];
    }
    return _onboardingManager;
}

- (APCPermissionsManager *)permissionsManager {
    return [APCPermissionsManager new];
}

- (APCScene *)inclusionCriteriaSceneForOnboarding:(APCOnboarding *)__unused onboarding {
    NSAssert(NO, @"Cannot retun nil. Override this delegate method to return a valid APCScene.");
    return nil;
}


- (ORKTaskViewController *)consentViewController
{
    NSAssert(NO, @"Override this method to return a valid Consent Task View Controller.");
    return nil;
}


#pragma mark - Private Helper Methods

- (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    return basePath;
}


#pragma mark - Secure View

- (void)showSecureView
{
    UIView *viewForSnapshot = self.window;
    if (self.secureView == nil) {
        self.secureView = [[UIView alloc] initWithFrame:self.window.rootViewController.view.bounds];
        
        UIImage *blurredImage = [viewForSnapshot blurredSnapshot];
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
        

#pragma mark - PasscodeViewController delegate

- (void)passcodeViewControllerDidSucceed:(APCPasscodeViewController *)__unused viewController
{
    //set the tabbar controller as the rootViewController
    [self showTabBar];
    self.isPasscodeShowing = NO;
    self.passcodeViewController = nil;
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithLong:uptime()] forKey:kLastUsedTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)passcodeViewControllerDidFail:(APCPasscodeViewController *) __unused viewController
{
    //retain the passcodeViewController as the Root View Controller and do not reset timeout
    self.isPasscodeShowing = YES;
}

@end
