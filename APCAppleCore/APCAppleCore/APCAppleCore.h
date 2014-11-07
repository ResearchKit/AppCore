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
#import <APCAppleCore/APCAssertionHandler.h>
#import <APCAppleCore/APCSignUpProgressing.h>

/* UI */
/* -------------------------
 Onboarding ViewControllers
 ------------------------- */
#import <APCAppleCore/APCUserInfoConstants.h>
#import <APCAppleCore/APCUserInfoViewController.h>
#import <APCAppleCore/APCIntroVideoViewController.h>
#import <APCAppleCore/APCStudyOverviewViewController.h>
#import <APCAppleCore/APCStudyDetailsViewController.h>
#import <APCAppleCore/APCSignInViewController.h>
#import <APCAppleCore/APCForgotPasswordViewController.h>
#import <APCAppleCore/APCInclusionCriteriaViewController.h>
#import <APCAppleCore/APCEligibleViewController.h>
#import <APCAppleCore/APCInEligibleViewController.h>
#import <APCAppleCore/APCShareViewController.h>
#import <APCAppleCore/APCTermsAndConditionsViewController.h>
#import <APCAppleCore/APCSignUpInfoViewController.h>
#import <APCAppleCore/APCSignupTouchIDViewController.h>
#import <APCAppleCore/APCSignUpPermissionsViewController.h>
#import <APCAppleCore/APCEmailVerifyViewController.h>

/*--------------------------
 Activities ViewControllers
 -------------------------*/
#import <APCAppleCore/APCIntroductionViewController.h>
#import <APCAppleCore/APCSpinnerViewController.h>
#import <APCAppleCore/APCSetupTaskViewController.h>
#import <APCAppleCore/APCStepViewController.h>
#import <APCAppleCore/APCActivitiesViewController.h>

/* -------------------------
 Profile ViewControllers
 ------------------------- */
#import <APCAppleCore/APCProfileViewController.h>
#import <APCAppleCore/APCSettingsViewController.h>
#import <APCAppleCore/APCChangePasscodeViewController.h>

/* -------------------------
 Views
 ------------------------- */
#import <APCAppleCore/APCGraph.h>
#import <APCAppleCore/APCStepProgressBar.h>
#import <APCAppleCore/APCSegmentedButton.h>
#import <APCAppleCore/APCImageButton.h>
#import <APCAppleCore/APCCircularProgressView.h>
#import <APCAppleCore/APCConfirmationView.h>
#import <APCAppleCore/APCPasscodeView.h>

/* -------------------------
 Cells
 ------------------------- */
#import <APCAppleCore/APCTextFieldTableViewCell.h>
#import <APCAppleCore/APCPickerTableViewCell.h>
#import <APCAppleCore/APCSegmentedTableViewCell.h>
#import <APCAppleCore/APCPermissionsCell.h>
#import <APCAppleCore/APCDefaultTableViewCell.h>
#import <APCAppleCore/APCSwitchTableViewCell.h>

/* -------------------------
 Objects
 ------------------------- */
#import <APCAppleCore/APCTableViewItem.h>
#import <APCAppleCore/APCGroupedScheduledTask.h>
#import <APCAppleCore/APCKeychainStore.h>
#import <APCAppleCore/APCPresentAnimator.h>

/* -------------------------
 Categories
 ------------------------- */
#import <APCAppleCore/NSBundle+Helper.h>
#import <APCAppleCore/NSDate+Helper.h>
#import <APCAppleCore/NSError+APCAdditions.h>
#import <APCAppleCore/NSObject+Helper.h>
#import <APCAppleCore/NSString+Helper.h>
#import <APCAppleCore/UIAlertController+Helper.h>
#import <APCAppleCore/UIScrollView+Helper.h>
#import <APCAppleCore/HKHealthStore+APCExtensions.h>
#import <APCAppleCore/UIImage+APCHelper.h>
#import <APCAppleCore/APCParameters+Settings.h>

/* -------------------------
 Appearance
 ------------------------- */
#import <APCAppleCore/APCAppearanceInfo.h>
#import <APCAppleCore/UIFont+APCAppearance.h>
#import <APCAppleCore/UIColor+APCAppearance.h>

/* -------------------------
 YML Chart Components
 ------------------------- */
#import <APCAppleCore/YMLChartEnumerations.h>
#import <APCAppleCore/YMLChartUnitsView.h>
#import <APCAppleCore/YMLLineChartView.h>
#import <APCAppleCore/YMLTimeLineChartView.h>


/* -------------------------
 Constants
 ------------------------- */

static NSString *const APCUserSignedUpNotification   = @"APCUserSignedUpNotification";
static NSString *const APCUserSignedInNotification   = @"APCUserSignedInNotification";
static NSString *const APCUserLogOutNotification     = @"APCUserLogOutNotification";
static NSString *const APCUserDidConsentNotification = @"APCUserDidConsentNotification";

static NSString *const APCAppDidRegisterUserNotification            = @"APCAppDidRegisterUserNotification";
static NSString *const APCAppDidFailToRegisterForRemoteNotification = @"APCAppDidFailToRegisterForRemoteNotifications";
