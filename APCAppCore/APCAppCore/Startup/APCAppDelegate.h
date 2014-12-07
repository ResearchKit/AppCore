// 
//  APCAppDelegate.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCDataSubstrate.h"
#import "APCHealthKitQuantityTracker.h"
#import "APCOnboarding.h"
#import "APCPasscodeViewController.h"

@class APCDataSubstrate, APCDataMonitor, APCScheduler, APCOnboarding, APCPasscodeViewController;

@interface APCAppDelegate : UIResponder <UIApplicationDelegate, APCOnboardingDelegate, APCOnboardingTaskDelegate, APCPasscodeViewControllerDelegate>

@property  (strong, nonatomic)  UIWindow * window;

//APC Related Properties & Methods
@property (strong, nonatomic) APCDataSubstrate * dataSubstrate;
@property (strong, nonatomic) APCDataMonitor * dataMonitor;
@property (strong, nonatomic) APCScheduler * scheduler;
@property (strong, nonatomic) APCHealthKitQuantityTracker *healthKitTracker;

//Initialization Methods
@property (nonatomic, strong) NSDictionary * initializationOptions;
- (NSMutableDictionary*) defaultInitializationOptions;

@property (strong, nonatomic) APCOnboarding *onboarding;

- (void)loadStaticTasksAndSchedulesIfNecessary;  //For resetting app
- (void) clearNSUserDefaults; //For resetting app

- (NSString*) certificateFileName;

//Show Methods
- (void) showTabBar;
- (void) showOnBoarding;
- (void) showNeedsEmailVerification;
- (void) setUpRootViewController: (UIViewController*) viewController;

//SetupMethods
- (void) setUpInitializationOptions;
- (void) setUpAppAppearance;

//For User in Subclasses
- (void) signedInNotification:(NSNotification *)notification;
- (void) signedUpNotification: (NSNotification*) notification;
- (void) logOutNotification:(NSNotification *)notification;

//To be called from Datasubstrate
- (void) setUpCollectors;

- (void)showPasscodeIfNecessary;

- (RKSTTaskViewController *)consentViewController;

- (void)instantiateOnboardingForType:(APCOnboardingTaskType)type;

@end
