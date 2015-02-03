// 
//  APCAppCore.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

//! Project version number for APCAppCore.
FOUNDATION_EXPORT double APCAppCoreVersionNumber;

//! Project version string for APCAppCore.
FOUNDATION_EXPORT const unsigned char APCAppCoreVersionString[];

#import <BridgeSDK/BridgeSDK.h>

//Headers
#import <APCAppCore/APCConstants.h>
#import <APCAppCore/APCAppDelegate.h>
#import <APCAppCore/APCDataMonitor.h>
#import <APCAppCore/APCDataMonitor+Bridge.h>
#import <APCAppCore/APCDataSubstrate.h>
#import <APCAppCore/APCDataSubstrate+CoreData.h>
#import <APCAppCore/APCDataSubstrate+ResearchKit.h>
#import <APCAppCore/APCDataSubstrate+HealthKit.h>
#import <APCAppCore/APCModel.h>
#import <APCAppCore/APCScheduler.h>
#import <APCAppCore/APCScheduleExpression.h>
#import <APCAppCore/APCPassiveLocationTracking.h>
#import <APCAppCore/APCParameters.h>
#import <APCAppCore/APCPermissionsManager.h>
#import <APCAppCore/APCAssertionHandler.h>
#import <APCAppCore/APCSignUpProgressing.h>
#import <APCAppCore/APCHealthKitQuantityTracker.h>
#import <APCAppCore/APCOnboarding.h>
#import <APCAppCore/APCDataResult.h>
#import <APCAppCore/APCTasksReminderManager.h>
#import <APCAppCore/APCDataArchiver.h>

/* -------------------------
 Logging
 ------------------------- */
#import <APCAppCore/APCLog.h>
#import <APCAppCore/APCDataVerificationClient.h>


/* UI */
/* -------------------------
 Onboarding ViewControllers
 ------------------------- */
#import <APCAppCore/APCUserInfoConstants.h>
#import <APCAppCore/APCUserInfoViewController.h>
#import <APCAppCore/APCIntroVideoViewController.h>
#import <APCAppCore/APCStudyOverviewViewController.h>
#import <APCAppCore/APCStudyDetailsViewController.h>
#import <APCAppCore/APCSignInViewController.h>
#import <APCAppCore/APCForgotPasswordViewController.h>
#import <APCAppCore/APCInclusionCriteriaViewController.h>
#import <APCAppCore/APCEligibleViewController.h>
#import <APCAppCore/APCInEligibleViewController.h>
#import <APCAppCore/APCShareViewController.h>
#import <APCAppCore/APCTermsAndConditionsViewController.h>
#import <APCAppCore/APCSignUpInfoViewController.h>
#import <APCAppCore/APCSignUpGeneralInfoViewController.h>
#import <APCAppCore/APCSignUpMedicalInfoViewController.h>
#import <APCAppCore/APCSignupPasscodeViewController.h>
#import <APCAppCore/APCSignUpPermissionsViewController.h>
#import <APCAppCore/APCEmailVerifyViewController.h>
#import <APCAppCore/APCChangeEmailViewController.h>
#import <APCAppCore/APCPasscodeViewController.h>
#import <APCAppCore/APCHomeLocationViewController.h>
#import <APCAppCore/APCLocationInfoViewController.h>
#import <APCAppCore/APCConsentTaskViewController.h>

/*--------------------------
 Dashboard ViewControllers
 -------------------------*/
#import <APCAppCore/APCDashboardViewController.h>
#import <APCAppCore/APCDashboardEditViewController.h>
#import <APCAppCore/APCLineGraphViewController.h>

/*--------------------------
 Learn ViewControllers
 -------------------------*/
#import <APCAppCore/APCLearnMasterViewController.h>
#import <APCAppCore/APCLearnStudyDetailsViewController.h>

/*--------------------------
 Activities ViewControllers
 -------------------------*/
#import <APCAppCore/APCIntroductionViewController.h>
#import <APCAppCore/APCInstructionStepViewController.h>
#import <APCAppCore/APCSpinnerViewController.h>
#import <APCAppCore/APCBaseTaskViewController.h>
#import <APCAppCore/APCBaseWithProgressTaskViewController.h>
#import <APCAppCore/APCStepViewController.h>
#import <APCAppCore/APCActivitiesViewController.h>
#import <APCAppCore/APCSimpleTaskSummaryViewController.h>
#import <APCAppCore/APCGenericSurveyTaskViewController.h>

/* -------------------------
 Profile ViewControllers
 ------------------------- */
#import <APCAppCore/APCProfileViewController.h>
#import <APCAppCore/APCSettingsViewController.h>
#import <APCAppCore/APCChangePasscodeViewController.h>
#import <APCAppCore/APCWithdrawSurveyViewController.h>
#import <APCAppCore/APCWithdrawCompleteViewController.h>

/* -------------------------
 Views
 ------------------------- */
#import <APCAppCore/APCCircularProgressView.h>
#import <APCAppCore/APCConcentricProgressView.h>
#import <APCAppCore/APCConfirmationView.h>
#import <APCAppCore/APCCustomBackButton.h>
#import <APCAppCore/APCFormTextField.h>
#import <APCAppCore/APCGraph.h>
#import <APCAppCore/APCImageButton.h>
#import <APCAppCore/APCPasscodeView.h>
#import <APCAppCore/APCPieGraphView.h>
#import <APCAppCore/APCResizeView.h>
#import <APCAppCore/APCSegmentedButton.h>
#import <APCAppCore/APCStepProgressBar.h>

/* -------------------------
 Cells
 ------------------------- */
#import <APCAppCore/APCTextFieldTableViewCell.h>
#import <APCAppCore/APCPickerTableViewCell.h>
#import <APCAppCore/APCSegmentedTableViewCell.h>
#import <APCAppCore/APCPermissionsCell.h>
#import <APCAppCore/APCDefaultTableViewCell.h>
#import <APCAppCore/APCSwitchTableViewCell.h>
#import <APCAppCore/APCTintedTableViewCell.h>
#import <APCAppCore/APCCheckTableViewCell.h>
#import <APCAppCore/APCDashboardLineGraphTableViewCell.h>
#import <APCAppCore/APCDashboardBadgesTableViewCell.h>
#import <APCAppCore/APCDashboardMessageTableViewCell.h>
#import <APCAppCore/APCDashboardProgressTableViewCell.h>
#import <APCAppCore/APCDashboardPieGraphTableViewCell.h>
#import <APCAppCore/APCShareTableViewCell.h>
#import <APCAppCore/APCAddressTableViewCell.h>


/* -------------------------
 Objects
 ------------------------- */
#import <APCAppCore/APCTableViewItem.h>
#import <APCAppCore/APCGroupedScheduledTask.h>
#import <APCAppCore/APCKeychainStore.h>
#import <APCAppCore/APCPresentAnimator.h>
#import <APCAppCore/APCScoring.h>
#import <APCAppCore/APCDeviceHardware.h>

/* -------------------------
 Categories
 ------------------------- */
#import <APCAppCore/NSBundle+Helper.h>
#import <APCAppCore/NSDate+Helper.h>
#import <APCAppCore/NSDateComponents+Helper.h>
#import <APCAppCore/NSError+APCAdditions.h>
#import <APCAppCore/NSObject+Helper.h>
#import <APCAppCore/NSString+Helper.h>
#import <APCAppCore/UIAlertController+Helper.h>
#import <APCAppCore/UIScrollView+Helper.h>
#import <APCAppCore/HKHealthStore+APCExtensions.h>
#import <APCAppCore/UIImage+APCHelper.h>
#import <APCAppCore/APCParameters+Settings.h>
#import <APCAppCore/SBBGuidCreatedOnVersionHolder+APCAdditions.h>
#import <APCAppCore/UIView+Helper.h>
#import <APCAppCore/NSDictionary+APCAdditions.h>
#import <APCAppCore/APCDeviceHardware+APCHelper.h>

/* -------------------------
 Appearance
 ------------------------- */
#import <APCAppCore/APCAppearanceInfo.h>
#import <APCAppCore/UIFont+APCAppearance.h>
#import <APCAppCore/UIColor+APCAppearance.h>
#import <APCAppCore/APCStepProgressBar+Appearance.h>
