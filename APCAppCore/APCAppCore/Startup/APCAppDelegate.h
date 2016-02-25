// 
//  APCAppDelegate.h 
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
 
#import <UIKit/UIKit.h>
#import "APCDataSubstrate.h"
#import "APCPasscodeViewController.h"
#import "APCProfileViewController.h"
#import "APCOnboardingManager.h"
#import "APCConsentTask.h"
#import "APCDataUploader.h"

extern NSUInteger   const kTheEntireDataModelOfTheApp;
static NSString*    const kDatabaseName                     = @"db.sqlite";

// Default tab controller tab keys
extern NSString *const kDashBoardStoryBoardKey;
extern NSString *const kLearnStoryBoardKey;
extern NSString *const kActivitiesStoryBoardKey;
extern NSString *const kHealthProfileStoryBoardKey;
extern NSString *const kNewsFeedStoryBoardKey;

@class APCDataSubstrate, APCDataMonitor, APCScheduler, APCPasscodeViewController, APCTasksReminderManager, APCPassiveDataCollector, APCFitnessAllocation, APCDataGroupsManager;

@interface APCAppDelegate : UIResponder <UIApplicationDelegate, APCOnboardingManagerProvider, APCPasscodeViewControllerDelegate, SBBBridgeAppDelegate>

@property (nonatomic, strong) APCFitnessAllocation *sevenDayFitnessAllocationData;
@property (strong, nonatomic) UITabBarController *tabBarController;

+ (instancetype) sharedAppDelegate;

//APC Related Properties & Methods
@property (strong, nonatomic) APCDataSubstrate * dataSubstrate;
@property (strong, nonatomic) APCDataMonitor * dataMonitor;
@property (strong, nonatomic) APCScheduler * scheduler;
@property (strong, nonatomic) APCTasksReminderManager * tasksReminder;
@property (strong, nonatomic) APCPassiveDataCollector * passiveDataCollector;
@property (strong, nonatomic) APCProfileViewController * profileViewController;
@property (nonatomic) BOOL disableSignatureInConsent;
@property (nonatomic, strong) APCDataUploader *dataUploader;

//Initialization Methods
@property (nonatomic, getter=doesPersisteStoreExist) BOOL persistentStoreExistence;
@property (nonatomic, strong) NSDictionary * initializationOptions;
- (NSMutableDictionary*) defaultInitializationOptions;

#pragma mark Onboarding

@property (nonatomic, strong, readonly) APCOnboardingManager *onboardingManager;

@property  (nonatomic, strong)  NSArray  *storyboardIdInfo;

- (void) updateDBVersionStatus;
- (void) clearNSUserDefaults; //For resetting app

- (UIWindow *)window;

- (NSString*) certificateFileName;

/**
 * link for opening the app store. AppDelegate implementations can override.
 */
- (NSURL *)appStoreLinkURL;

//Show Methods
- (void) showTabBar;
- (void) showOnBoarding;
- (void) showNeedsEmailVerification;
- (void) setUpRootViewController: (UIViewController*) viewController;
- (void) setUpTasksReminder;
- (void)performMigrationAfterFirstImport;
- (void)performMigrationFrom:(NSInteger)previousVersion currentVersion:(NSInteger)currentVersion;
- (void)performMigrationAfterDataSubstrateFrom:(NSInteger)previousVersion currentVersion:(NSInteger)currentVersion;
- (NSString *) applicationDocumentsDirectory;
- (NSUInteger)obtainPreviousVersion;

//Default bundle for resources and storyboards
- (NSBundle*)resourceBundle;
- (NSString*)pathForResource:(NSString*)resourceName ofType:(NSString*)resourceType;

//SetupMethods
- (void) setUpInitializationOptions;
- (void) setUpAppAppearance;
- (void) registerCatastrophicStartupError: (NSError *) error;

//For User in Subclasses
- (void) signedInNotification:(NSNotification *)notification;
- (void) signedUpNotification: (NSNotification*) notification;
- (void) logOutNotification:(NSNotification *)notification;

- (void)afterOnBoardProcessIsFinished;
- (NSArray *)reviewConsentActions;
- (NSArray *)allSetTextBlocks;
- (NSDictionary *)configureTasksForActivities;
- (BOOL)hideEmailOnWelcomeScreen;

//To be called from Datasubstrate
- (void) setUpCollectors;

- (id <APCProfileViewControllerDelegate>) profileExtenderDelegate;

- (void)showPasscodeIfNecessary;

- (ORKTaskViewController *)consentViewController;
- (NSMutableArray*)consentSectionsAndHtmlContent:(NSString**)htmlContent;

- (NSDate*)applicationBecameActiveDate;

- (void)updateNewsFeedBadgeCount;

// List of the tabs to use to setup the tabbar
- (NSMutableArray <APCScene *> *)tabBarScenes;

- (void) transitionToRootViewController:(UIViewController*) viewController;

@end
