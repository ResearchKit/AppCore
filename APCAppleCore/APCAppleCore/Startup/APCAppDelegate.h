//
//  APCAppDelegate.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const kStudyIdentifierKey = @"StudyIdentifierKey";
static NSString *const kAppPrefixKey = @"AppPrefixKey";
static NSString *const kBaseURLKey = @"BaseURLKey";
static NSString *const kDatabaseNameKey = @"DatabaseNameKey";
static NSString *const kTasksAndSchedulesJSONFileNameKey = @"TasksAndSchedulesJSONFileNameKey";
static NSString *const kDataSubstrateClassNameKey = @"APHDatasubstrateClassName";

static NSString *const kPasswordKey = @"password";

@class APCDataSubstrate, APCDataMonitor, APCScheduler;
@interface APCAppDelegate : UIResponder <UIApplicationDelegate>

@property  (strong, nonatomic)  UIWindow * window;

//APC Related Properties & Methods
@property (strong, nonatomic) APCDataSubstrate * dataSubstrate;
@property (strong, nonatomic) APCDataMonitor * dataMonitor;
@property (strong, nonatomic) APCScheduler * scheduler;

@property (nonatomic, strong) NSDictionary * initializationOptions;

- (void)loadStaticTasksAndSchedulesIfNecessary;  //For resetting app
- (void) clearNSUserDefaults; //For resetting app

//For User in Subclasses
- (void) signedInNotification:(NSNotification *)notification;
- (void) signedUpNotification: (NSNotification*) notification;
- (void) logOutNotification:(NSNotification *)notification;

@end
