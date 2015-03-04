// 
//  APCAppDelegate.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCDataSubstrate.h"
#import "APCOnboarding.h"
#import "APCPasscodeViewController.h"
#import "APCProfileViewController.h"
#import "APCConsentTask.h"


@class APCDataSubstrate, APCDataMonitor, APCScheduler, APCOnboarding, APCPasscodeViewController, APCTasksReminderManager, APCPassiveDataCollector, APCFitnessAllocation;

@interface APCAppDelegate : UIResponder <UIApplicationDelegate, APCOnboardingDelegate, APCOnboardingTaskDelegate, APCPasscodeViewControllerDelegate>

@property (nonatomic, strong) APCFitnessAllocation *sevenDayFitnessAllocationData;
@property (strong, nonatomic) UITabBarController *tabster;

//APC Related Properties & Methods
@property (strong, nonatomic) APCDataSubstrate * dataSubstrate;
@property (strong, nonatomic) APCDataMonitor * dataMonitor;
@property (strong, nonatomic) APCScheduler * scheduler;
@property (strong, nonatomic) APCTasksReminderManager * tasksReminder;
@property (strong, nonatomic) APCPassiveDataCollector * passiveDataCollector;
@property (strong, nonatomic) APCProfileViewController * profileViewController;
@property (nonatomic) BOOL disableSignatureInConsent;

//Initialization Methods
@property (nonatomic, strong) NSDictionary * initializationOptions;
- (NSMutableDictionary*) defaultInitializationOptions;

@property (strong, nonatomic) APCOnboarding *onboarding;

@property  (nonatomic, strong)  NSArray  *storyboardIdInfo;

- (void)loadStaticTasksAndSchedulesIfNecessary;  //For resetting app
- (void) updateDBVersionStatus;
- (void) clearNSUserDefaults; //For resetting app

- (UIWindow *)window;

- (NSString*) certificateFileName;

//Show Methods
- (void) showTabBar;
- (void) showOnBoarding;
- (void) showNeedsEmailVerification;
- (void) setUpRootViewController: (UIViewController*) viewController;

- (NSDictionary *) tasksAndSchedulesWillBeLoaded;

//SetupMethods
- (void) setUpInitializationOptions;
- (void) setUpAppAppearance;
- (void) registerCatastrophicStartupError: (NSError *) error;

//For User in Subclasses
- (void) signedInNotification:(NSNotification *)notification;
- (void) signedUpNotification: (NSNotification*) notification;
- (void) logOutNotification:(NSNotification *)notification;

- (NSArray *)offsetForTaskSchedules;
- (void)afterOnBoardProcessIsFinished;
- (NSArray *)reviewConsentActions;

//To be called from Datasubstrate
- (void) setUpCollectors;
- (id <APCProfileViewControllerDelegate>) profileExtenderDelegate;

- (void)showPasscodeIfNecessary;

- (ORKTaskViewController *)consentViewController;
- (NSMutableArray*)consentSectionsAndHtmlContent:(NSString**)htmlContent;

- (void)instantiateOnboardingForType:(APCOnboardingTaskType)type;

@end
