// 
//  APCAppCore.h 
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
#import <APCAppCore/APCParameters.h>
#import <APCAppCore/APCPermissionsManager.h>
#import <APCAppCore/APCAssertionHandler.h>
#import <APCAppCore/APCSignUpProgressing.h>
#import <APCAppCore/APCOnboarding.h>
#import <APCAppCore/APCDataResult.h>
#import <APCAppCore/APCTasksReminderManager.h>
#import <APCAppCore/APCUtilities.h>

//  Tasks
#import <APCAppCore/APCConsentTask.h>
#import <APCAppCore/APCConsentQuestion.h>
#import <APCAppCore/APCConsentBooleanQuestion.h>
#import <APCAppCore/APCConsentInstructionQuestion.h>
#import <APCAppCore/APCConsentTextChoiceQuestion.h>
#import <APCAppCore/APCConsentRedirector.h>

/* -------------------------------------
 Data Archiver & Passive Data Collectors
 --------------------------------------- */
#import <APCAppCore/APCDataArchiverAndUploader.h>
#import <APCAppCore/APCDataArchiver.h>
#import <APCAppCore/APCPassiveDataCollector.h>
#import <APCAppCore/APCDataTracker.h>
#import <APCAppCore/APCHKDiscreteQuantityTracker.h>
#import <APCAppCore/APCHKCumulativeQuantityTracker.h>
#import <APCAppCore/APCCoreLocationTracker.h>
#import <APCAppCore/APCCoreMotionTracker.h>
#import <APCAppCore/zipzap.h>
#import <APCAppCore/ZZArchive.h>
#import "APCAppCore/ZZArchiveEntry.h"
#import "APCAppCore/ZZConstants.h"
#import "APCAppCore/ZZError.h"
#import "APCAppCore/APCCMS.h"

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
#import <APCAppCore/APCPermissionPrimingViewController.h>
#import <APCAppCore/APCSignUpInfoViewController.h>
#import <APCAppCore/APCSignUpGeneralInfoViewController.h>
#import <APCAppCore/APCSignUpMedicalInfoViewController.h>
#import <APCAppCore/APCSignupPasscodeViewController.h>
#import <APCAppCore/APCSignUpPermissionsViewController.h>
#import <APCAppCore/APCEmailVerifyViewController.h>
#import <APCAppCore/APCChangeEmailViewController.h>
#import <APCAppCore/APCPasscodeViewController.h>
#import <APCAppCore/APCConsentTaskViewController.h>
#import <APCAppCore/APCWebViewController.h>

/*--------------------------
 Dashboard ViewControllers
 -------------------------*/
#import <APCAppCore/APCDashboardViewController.h>
#import <APCAppCore/APCDashboardEditViewController.h>
#import <APCAppCore/APCGraphViewController.h>
#import <APCAppCore/APCDashboardMoreInfoViewController.h>

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
#import <APCAppCore/APCSharingOptionsViewController.h>

/* -------------------------
 Medication Tracking Setup Controllers
 ------------------------- */

#import <APCAppCore/APCMedicationTrackerSetupViewController.h>
#import <APCAppCore/APCMedicationDosageViewController.h>
#import <APCAppCore/APCFrequencyDayTableViewCell.h>
#import <APCAppCore/APCFrequencyEverydayTableViewCell.h>
#import <APCAppCore/APCFrequencyTableViewTimesCell.h>
#import <APCAppCore/APCMedicationFrequencyViewController.h>
#import <APCAppCore/APCColorSwatchTableViewCell.h>
#import <APCAppCore/APCMedicationColorViewController.h>
#import <APCAppCore/APCLozengeButton.h>
#import <APCAppCore/APCMedicationNameViewController.h>
#import <APCAppCore/APCMedicationTrackerSetupViewController.h>
#import <APCAppCore/APCSetupTableViewCell.h>
#import <APCAppCore/APCSetupButtonTableViewCell.h>
#import <APCAppCore/APCMedicationNameTableViewCell.h>
#import <APCAppCore/APCMedicationSummaryTableViewCell.h>

/* -------------------------
 Medication Tracking App Level Components
 ------------------------- */

#import <APCAppCore/APCMedicationTrackerCalendarViewController.h>
#import <APCAppCore/APCMedicationTrackerCalendarDailyView.h>
#import <APCAppCore/APCMedicationDetailsTableViewCell.h>
#import <APCAppCore/APCMedicationTrackerCalendarWeeklyView.h>
#import <APCAppCore/APCMedicationTrackerDayTitleLabel.h>
#import <APCAppCore/APCMedicationTrackerDetailViewController.h>
#import <APCAppCore/APCMedicationTrackerMedicationsDisplayView.h>
#import <APCAppCore/NSDate+MedicationTracker.h>
#import <APCAppCore/NSDictionary+MedicationTracker.h>
#import <APCAppCore/UIColor+MedicationTracker.h>

/* -------------------------
 Medication-Tracker Storage (not the med-tracker itself)
 ------------------------- */
#import <APCAppCore/APCMedTrackerDataStorageManager.h>
#import <APCAppCore/APCMedTrackerDailyDosageRecord.h>
#import <APCAppCore/APCMedTrackerDailyDosageRecord+Helper.h>
#import <APCAppCore/APCMedTrackerInflatableItem.h>
#import <APCAppCore/APCMedTrackerInflatableItem+Helper.h>
#import <APCAppCore/APCMedTrackerMedication.h>
#import <APCAppCore/APCMedTrackerMedication+Helper.h>
#import <APCAppCore/APCMedTrackerPrescription.h>
#import <APCAppCore/APCMedTrackerPrescription+Helper.h>
#import <APCAppCore/APCMedTrackerPossibleDosage.h>
#import <APCAppCore/APCMedTrackerPossibleDosage+Helper.h>
#import <APCAppCore/APCMedTrackerPrescriptionColor.h>
#import <APCAppCore/APCMedTrackerPrescriptionColor+Helper.h>

/* -------------------------
 Views
 ------------------------- */
	 
#import <APCAppCore/APCHorizontalThinLineView.h>
#import <APCAppCore/APCHorizontalBottomThinLineView.h>
#import <APCAppCore/APCVerticalThinLineView.h>
#import <APCAppCore/APCCircularProgressView.h>
#import <APCAppCore/APCConcentricProgressView.h>
#import <APCAppCore/APCConfirmationView.h>
#import <APCAppCore/APCCustomBackButton.h>
#import <APCAppCore/APCFormTextField.h>
#import <APCAppCore/APCGraph.h>
#import <APCAppCore/APCButton.h>
#import <APCAppCore/APCImageButton.h>
#import <APCAppCore/APCPasscodeView.h>
#import <APCAppCore/APCPieGraphView.h>
#import <APCAppCore/APCResizeView.h>
#import <APCAppCore/APCSegmentedButton.h>
#import <APCAppCore/APCStepProgressBar.h>
#import <APCAppCore/APCInsightBarView.h>
#import <APCAppCore/APCPermissionButton.h>
#import <APCAppCore/APCTheme.h>
#import <APCAppCore/APCActivityTrackingStepViewController.h>
#import <APCAppCore/APCFitnessAllocation.h>
#import <APCAppCore/APCExampleLabel.h>

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
#import <APCAppCore/APCDashboardTableViewCell.h>
#import <APCAppCore/APCDashboardGraphTableViewCell.h>
#import <APCAppCore/APCDashboardMessageTableViewCell.h>
#import <APCAppCore/APCDashboardProgressTableViewCell.h>
#import <APCAppCore/APCDashboardPieGraphTableViewCell.h>
#import <APCAppCore/APCShareTableViewCell.h>
#import <APCAppCore/APCAddressTableViewCell.h>
#import <APCAppCore/APCDashboardInsightsTableViewCell.h>
#import <APCAppCore/APCDashboardInsightSummaryTableViewCell.h>
#import <APCAppCore/APCDashboardInsightTableViewCell.h>
#import <APCAppCore/APCDashboardFoodInsightTableViewCell.h>
#import <APCAppCore/APCStudyVideoCollectionViewCell.h>
#import <APCAppCore/APCStudyOverviewCollectionViewCell.h>
#import <APCAppCore/APCStudyLandingCollectionViewCell.h>
#import <APCAppCore/APCActivitiesTableViewCell.h>
#import <APCAppCore/APCActivitiesBasicTableViewCell.h>
#import <APCAppCore/APCActivitiesTintedTableViewCell.h>
#import <APCAppCore/APCActivitiesSectionHeaderView.h>

/* -------------------------
 Objects
 ------------------------- */
#import <APCAppCore/APCTableViewItem.h>
#import <APCAppCore/APCGroupedScheduledTask.h>
#import <APCAppCore/APCKeychainStore+Passcode.h>
#import <APCAppCore/APCPresentAnimator.h>
#import <APCAppCore/APCFadeAnimator.h>
#import <APCAppCore/APCScoring.h>
#import <APCAppCore/APCDeviceHardware.h>
#import <APCAppCore/APCInsights.h>
#import <APCAppCore/APCFoodInsight.h>
#import <APCAppCore/APCBadgeLabel.h>
#import <APCAppCore/APCMotionHistoryData.h>
#import <APCAppCore/APCMotionHistoryReporter.h>
#import <APCAppCore/APCJSONSerializer.h>
#import <APCAppCore/APCTaskReminder.h>

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
#import <APCAppCore/ORKQuestionResult+APCHelper.h>
#import <APCAppCore/NSOperationQueue+Helper.h>

/* -------------------------
 Appearance
 ------------------------- */
#import <APCAppCore/APCAppearanceInfo.h>
#import <APCAppCore/UIFont+APCAppearance.h>
#import <APCAppCore/UIColor+APCAppearance.h>
#import <APCAppCore/APCStepProgressBar+Appearance.h>

/* -------------------------
 Schedule and ScheduleExpression components
 ------------------------- */
#import <APCAppCore/APCScheduler.h>
#import <APCAppCore/APCScheduleExpression.h>
#import <APCAppCore/APCDayOfMonthSelector.h>
#import <APCAppCore/APCListSelector.h>
#import <APCAppCore/APCPointSelector.h>
#import <APCAppCore/APCScheduleEnumerator.h>
#import <APCAppCore/APCScheduleExpressionParser.h>
#import <APCAppCore/APCScheduleExpressionToken.h>
#import <APCAppCore/APCScheduleExpressionTokenizer.h>
#import <APCAppCore/APCTimeSelector.h>
#import <APCAppCore/APCTimeSelectorEnumerator.h>
