//
//  APCAppDelegate.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCDataSubstrate.h"

static NSString *const kStudyIdentifierKey = @"StudyIdentifierKey";
static NSString *const kAppPrefixKey = @"AppPrefixKey";
static NSString *const kBaseURLKey = @"BaseURLKey";
static NSString *const kDatabaseNameKey = @"DatabaseNameKey";
static NSString *const kTasksAndSchedulesJSONFileNameKey = @"TasksAndSchedulesJSONFileNameKey";
static NSString *const kDataSubstrateClassNameKey = @"APHDatasubstrateClassName";
static NSString *const kHKWritePermissionsKey = @"HKWritePermissions";
static NSString *const kHKReadPermissionsKey = @"HKReadPermissions";

static NSString *const kPasswordKey = @"password";

@class APCDataSubstrate, APCDataMonitor, APCScheduler;

@interface APCAppDelegate : UIResponder <UIApplicationDelegate>

@property  (strong, nonatomic)  UIWindow * window;

//APC Related Properties & Methods
@property (strong, nonatomic) APCDataSubstrate * dataSubstrate;
@property (strong, nonatomic) APCDataMonitor * dataMonitor;
@property (strong, nonatomic) APCScheduler * scheduler;

//Initialization Methods
@property (nonatomic, strong) NSDictionary * initializationOptions;
- (NSMutableDictionary*) defaultInitializationOptions;

- (void)loadStaticTasksAndSchedulesIfNecessary;  //For resetting app
- (void) clearNSUserDefaults; //For resetting app

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

@end
