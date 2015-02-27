// 
//  APCAppDelegate.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCDataSubstrate.h"
#import "APCOnboarding.h"
#import "APCPasscodeViewController.h"
#import "APCProfileViewController.h"


@class APCDataSubstrate, APCDataMonitor, APCScheduler, APCOnboarding, APCPasscodeViewController, APCTasksReminderManager, APCPassiveDataCollector;

@interface APCAppDelegate : UIResponder <UIApplicationDelegate, APCOnboardingDelegate, APCOnboardingTaskDelegate, APCPasscodeViewControllerDelegate>

@property  (strong, nonatomic)  UIWindow * window;
@property (strong, nonatomic) UITabBarController *tabster;

//APC Related Properties & Methods
@property (strong, nonatomic) APCDataSubstrate * dataSubstrate;
@property (strong, nonatomic) APCDataMonitor * dataMonitor;
@property (strong, nonatomic) APCScheduler * scheduler;
@property (strong, nonatomic) APCTasksReminderManager * tasksReminder;
@property (strong, nonatomic) APCPassiveDataCollector * passiveDataCollector;

@property (strong, nonatomic) APCProfileViewController * profileViewController;

//Initialization Methods
@property (nonatomic, strong) NSDictionary * initializationOptions;
- (NSMutableDictionary*) defaultInitializationOptions;

@property (strong, nonatomic) APCOnboarding *onboarding;

@property  (nonatomic, strong)  NSArray  *storyboardIdInfo;

- (void)loadStaticTasksAndSchedulesIfNecessary;  //For resetting app
- (void) updateDBVersionStatus;
- (void) clearNSUserDefaults; //For resetting app

- (NSMutableArray*)consentSectionsAndHtmlContent:(NSString**)htmlContent;  //  Retrieve and creates Consent Sections from JSON file.


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

//For User in Subclasses
- (void) signedInNotification:(NSNotification *)notification;
- (void) signedUpNotification: (NSNotification*) notification;
- (void) logOutNotification:(NSNotification *)notification;

//To be called from Datasubstrate
- (void) setUpCollectors;
- (id <APCProfileViewControllerDelegate>) profileExtenderDelegate;

- (void)showPasscodeIfNecessary;

- (ORKTaskViewController *)consentViewController;

- (void)instantiateOnboardingForType:(APCOnboardingTaskType)type;

@end
