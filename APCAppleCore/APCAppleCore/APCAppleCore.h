//
//  APCAppleCore.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for APCAppleCore.
FOUNDATION_EXPORT double APCAppleCoreVersionNumber;

//! Project version string for APCAppleCore.
FOUNDATION_EXPORT const unsigned char APCAppleCoreVersionString[];

#import <ResearchKit/ResearchKit.h>
#import <BridgeSDK/BridgeSDK.h>

//Headers
#import <APCAppleCore/APCAppDelegate.h>
#import <APCAppleCore/APCDataMonitor.h>
#import <APCAppleCore/APCDataSubstrate.h>
#import <APCAppleCore/APCDataSubstrate+CoreData.h>
#import <APCAppleCore/APCDataSubstrate+ResearchKit.h>
#import <APCAppleCore/APCModel.h>
#import <APCAppleCore/APCScheduler.h>
#import <APCAppleCore/APCScheduleInterpreter.h>
#import <APCAppleCore/APCPassiveLocationTracking.h>
#import <APCAppleCore/APCParameters.h>
#import <APCAppleCore/APCPermissionsManager.h>

//UI
#import <APCAppleCore/APCAssertionHandler.h>
#import <APCAppleCore/APCCircularProgressView.h>
#import <APCAppleCore/APCConfigurableCell.h>
#import <APCAppleCore/APCConfirmationView.h>
#import <APCAppleCore/APCCriteriaCell.h>
#import <APCAppleCore/APCForgotPasswordViewController.h>
#import <APCAppleCore/APCIntroVideoViewController.h>
#import <APCAppleCore/APCNavigationController.h>
#import <APCAppleCore/APCPasscodeView.h>
#import <APCAppleCore/APCSegmentControl.h>
#import <APCAppleCore/APCSignInViewController.h>
#import <APCAppleCore/APCSignupCriteriaViewController.h>
#import <APCAppleCore/APCSignUpPermissionsViewController.h>
#import <APCAppleCore/APCSignUpProgressing.h>
#import <APCAppleCore/APCSignupTouchIDViewController.h>
#import <APCAppleCore/APCSignUpUserInfoViewController.h>
#import <APCAppleCore/APCSignupViewController.h>
#import <APCAppleCore/APCStudyOverviewViewController.h>
#import <APCAppleCore/APCSpinnerViewController.h>
#import <APCAppleCore/APCStepProgressBar.h>
#import <APCAppleCore/APCTableViewItem.h>
#import <APCAppleCore/APCUserInfoCell.h>
#import <APCAppleCore/APCPermissionsCell.h>
#import <APCAppleCore/APCUserInfoConstants.h>
#import <APCAppleCore/APCUserInfoViewController.h>
#import <APCAppleCore/APCViewController.h>
#import <APCAppleCore/APCProfile.h>
#import <APCAppleCore/YMLChartEnumerations.h>
#import <APCAppleCore/YMLChartUnitsView.h>
#import <APCAppleCore/YMLLineChartView.h>
#import <APCAppleCore/YMLTimeLineChartView.h>

#import <APCAppleCore/APCSetupTaskViewController.h>
#import <APCAppleCore/APCStepViewController.h>

#import <APCAppleCore/APCActivitiesViewController.h>
#import <APCAppleCore/APCActivitiesTableViewCell.h>

#import <APCAppleCore/APCEmailVerifyViewController.h>

//Objects
#import <APCAppleCore/APCGroupedScheduledTask.h>
#import <APCAppleCore/APCKeychainStore.h>

//Categories
#import <APCAppleCore/APCStepProgressBar+Appearance.h>
#import <APCAppleCore/CALayer+Appearance.h>
#import <APCAppleCore/NSBundle+Helper.h>
#import <APCAppleCore/NSDate+Helper.h>
#import <APCAppleCore/NSError+APCAdditions.h>
#import <APCAppleCore/NSObject+Helper.h>
#import <APCAppleCore/NSString+Helper.h>
#import <APCAppleCore/UIAlertView+Helper.h>
#import <APCAppleCore/UIBarButtonItem+Appearance.h>
#import <APCAppleCore/UIColor+Helper.h>
#import <APCAppleCore/UIScrollView+Helper.h>
#import <APCAppleCore/UISegmentedControl+Appearance.h>
#import <APCAppleCore/UITableView+Appearance.h>
#import <APCAppleCore/UIView+Helper.h>
#import <APCAppleCore/UIColor+Appearance.h>
#import <APCAppleCore/HKHealthStore+APCExtensions.h>

static NSString *const APCUserSignedUpNotification     = @"APCUserSignedUpNotification";
static NSString *const APCUserSignedInNotification     = @"APCUserSignedInNotification";
static NSString *const APCUserLogOutNotification  = @"APCUserLogOutNotification";
static NSString *const APCUserDidConsentNotification = @"APCUserDidConsentNotification";

static NSString *const APCAppDidRegisterUserNotification            = @"APCAppDidRegisterUserNotification";
static NSString *const APCAppDidFailToRegisterForRemoteNotification = @"APCAppDidFailToRegisterForRemoteNotifications";
