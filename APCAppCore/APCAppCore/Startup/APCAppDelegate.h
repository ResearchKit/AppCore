//
//  APCAppDelegate.h
//  APCAppCore`
//
//  Created by Dhanush Balachandran on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCDataSubstrate.h"
#import "APCHealthKitQuantityTracker.h"
#import "APCOnboarding.h"

@class APCDataSubstrate, APCDataMonitor, APCScheduler, APCOnboarding;

@interface APCAppDelegate : UIResponder <UIApplicationDelegate, APCDataSubstrateProtocol, APCOnboardingDelegate>

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

//Datasubstrate Delegate
- (void) setUpCollectors;

- (void)showPasscodeIfNecessary;

- (RKSTTaskViewController *)consentViewController;

@end
