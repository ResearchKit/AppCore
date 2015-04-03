// 
//  APCConstants.h 
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
 
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, APCSignUpPermissionsType) {
    kSignUpPermissionsTypeNone = 0,
    kSignUpPermissionsTypeHealthKit,
    kSignUpPermissionsTypeLocation,
    kSignUpPermissionsTypeLocalNotifications,
    kSignUpPermissionsTypeCoremotion,
    kSignUpPermissionsTypeMicrophone,
    kSignUpPermissionsTypeCamera,
    kSignUpPermissionsTypePhotoLibrary
};

typedef NS_ENUM(NSUInteger, APCDashboardMessageType) {
    kAPCDashboardMessageTypeAlert,
    kAPCDashboardMessageTypeInsight,
};

typedef NS_ENUM(NSUInteger, APCDashboardGraphType) {
    kAPCDashboardGraphTypeLine,
    kAPCDashboardGraphTypeDiscrete,
};

FOUNDATION_EXPORT NSString *const APCUserSignedUpNotification;
FOUNDATION_EXPORT NSString *const APCUserSignedInNotification;
FOUNDATION_EXPORT NSString *const APCUserLogOutNotification;
FOUNDATION_EXPORT NSString *const APCUserWithdrawStudyNotification;
FOUNDATION_EXPORT NSString *const APCUserDidConsentNotification;

FOUNDATION_EXPORT NSString *const APCScheduleUpdatedNotification;
FOUNDATION_EXPORT NSString *const APCUpdateActivityNotification;

FOUNDATION_EXPORT NSString *const APCAppDidRegisterUserNotification;
FOUNDATION_EXPORT NSString *const APCAppDidFailToRegisterForRemoteNotification;

FOUNDATION_EXPORT NSString *const APCScoringHealthKitDataIsAvailableNotification;
FOUNDATION_EXPORT NSString *const APCTaskResultsProcessedNotification;

FOUNDATION_EXPORT NSString *const APCUpdateTasksReminderNotification;

FOUNDATION_EXPORT NSString *const APCConsentCompletedWithDisagreeNotification;

FOUNDATION_EXPORT NSString *const APCMotionHistoryReporterDoneNotification;

FOUNDATION_EXPORT NSString *const APCHealthKitObserverQueryUpdateForSampleTypeNotification;

FOUNDATION_EXPORT NSString *const kStudyIdentifierKey;
FOUNDATION_EXPORT NSString *const kAppPrefixKey;
FOUNDATION_EXPORT NSString *const kBridgeEnvironmentKey;
FOUNDATION_EXPORT NSString *const kDatabaseNameKey;
FOUNDATION_EXPORT NSString *const kTasksAndSchedulesJSONFileNameKey;
FOUNDATION_EXPORT NSString *const kConsentSectionFileNameKey;
FOUNDATION_EXPORT NSString *const kHKWritePermissionsKey;
FOUNDATION_EXPORT NSString *const kHKReadPermissionsKey;
FOUNDATION_EXPORT NSString *const kAppServicesListRequiredKey;
FOUNDATION_EXPORT NSString *const kAppServicesDescriptionsKey;
FOUNDATION_EXPORT NSString *const kAppProfileElementsListKey;
FOUNDATION_EXPORT NSString *const kVideoURLKey;
FOUNDATION_EXPORT NSString *const kTaskReminderStartupDefaultOnOffKey;
FOUNDATION_EXPORT NSString *const kTaskReminderStartupDefaultTimeKey;
FOUNDATION_EXPORT NSString *const kDelayReminderIdentifier;
FOUNDATION_EXPORT NSString *const kTaskReminderDelayCategory;
FOUNDATION_EXPORT NSString *const kDBStatusVersionKey;
FOUNDATION_EXPORT NSString *const kShareMessageKey;

FOUNDATION_EXPORT NSString *const kHKQuantityTypeKey;
FOUNDATION_EXPORT NSString *const kHKCategoryTypeKey;
FOUNDATION_EXPORT NSString *const kHKCharacteristicTypeKey;
FOUNDATION_EXPORT NSString *const kHKCorrelationTypeKey;
FOUNDATION_EXPORT NSString *const kHKWorkoutTypeKey;

FOUNDATION_EXPORT NSString * const kPasswordKey;
FOUNDATION_EXPORT NSString * const kNumberOfMinutesForPasscodeKey;

FOUNDATION_EXPORT NSInteger      const kAPCSigninErrorCode_NotSignedIn;
FOUNDATION_EXPORT NSUInteger     const kAPCSigninNumRetriesBeforePause;
FOUNDATION_EXPORT NSTimeInterval const kAPCSigninNumSecondsBetweenRetries;
FOUNDATION_EXPORT NSTimeInterval const kAPCSignInButtonPulseFadeInTimeInSeconds;
FOUNDATION_EXPORT NSTimeInterval const kAPCSignInButtonPulseFadeOutTimeInSeconds;
FOUNDATION_EXPORT NSTimeInterval const kAPCSignInButtonPulsePauseWhileVisibleTimeInSeconds;

FOUNDATION_EXPORT NSString *const kRegularFontNameKey;
FOUNDATION_EXPORT NSString *const kMediumFontNameKey;
FOUNDATION_EXPORT NSString *const kLightFontNameKey;

FOUNDATION_EXPORT NSString *const kHairlineEnDashJoinerKey;

FOUNDATION_EXPORT NSString *const kPrimaryAppColorKey;

FOUNDATION_EXPORT NSString *const kSecondaryColor1Key;
FOUNDATION_EXPORT NSString *const kSecondaryColor2Key;
FOUNDATION_EXPORT NSString *const kSecondaryColor3Key;
FOUNDATION_EXPORT NSString *const kSecondaryColor4Key;

FOUNDATION_EXPORT NSString *const kTertiaryColor1Key;
FOUNDATION_EXPORT NSString *const kTertiaryColor2Key;

FOUNDATION_EXPORT NSString *const kTertiaryGreenColorKey;
FOUNDATION_EXPORT NSString *const kTertiaryBlueColorKey;
FOUNDATION_EXPORT NSString *const kTertiaryRedColorKey ;
FOUNDATION_EXPORT NSString *const kTertiaryYellowColorKey;
FOUNDATION_EXPORT NSString *const kTertiaryPurpleColorKey;
FOUNDATION_EXPORT NSString *const kTertiaryGrayColorKey;

FOUNDATION_EXPORT NSString *const kBorderLineColor;

FOUNDATION_EXPORT NSString *const kTasksReminderDefaultsOnOffKey;
FOUNDATION_EXPORT NSString *const kTasksReminderDefaultsTimeKey;

FOUNDATION_EXPORT NSString *const kScheduleOffsetTaskIdKey;
FOUNDATION_EXPORT NSString *const kScheduleOffsetOffsetKey;

FOUNDATION_EXPORT NSString *const kReviewConsentActionPDF;
FOUNDATION_EXPORT NSString *const kReviewConsentActionVideo;
FOUNDATION_EXPORT NSString *const kReviewConsentActionSlides;

FOUNDATION_EXPORT NSString *const kAllSetActivitiesTextOriginal;
FOUNDATION_EXPORT NSString *const kAllSetActivitiesTextAdditional;
FOUNDATION_EXPORT NSString *const kAllSetDashboardTextOriginal;
FOUNDATION_EXPORT NSString *const kAllSetDashboardTextAdditional;

FOUNDATION_EXPORT NSString *const kActivitiesSectionKeepGoing;
FOUNDATION_EXPORT NSString *const kActivitiesSectionYesterday;
FOUNDATION_EXPORT NSString *const kActivitiesSectionToday;

FOUNDATION_EXPORT NSString *const kActivitiesRequiresMotionSensor;



// ---------------------------------------------------------
#pragma mark - Events
// ---------------------------------------------------------

FOUNDATION_EXPORT NSString *const kAppStateChangedEvent;
FOUNDATION_EXPORT NSString *const kNetworkEvent;
FOUNDATION_EXPORT NSString *const kSchedulerEvent;
FOUNDATION_EXPORT NSString *const kTaskEvent;
FOUNDATION_EXPORT NSString *const kPageViewEvent;
FOUNDATION_EXPORT NSString *const kErrorEvent;
FOUNDATION_EXPORT NSString *const kPassiveCollectorEvent;



// ---------------------------------------------------------
#pragma mark - Known files, folders, extensions, and content types
// ---------------------------------------------------------

/*
 Folders that will appear in the user's Documents directory,
 or elsewhere that we might need to understand and inspect 'em.
 */

FOUNDATION_EXPORT NSString * const kAPCFolderName_ArchiveAndUpload_TopLevelFolder;
FOUNDATION_EXPORT NSString * const kAPCFolderName_ArchiveAndUpload_Archiving;
FOUNDATION_EXPORT NSString * const kAPCFolderName_ArchiveAndUpload_Uploading;

FOUNDATION_EXPORT NSString * const kAPCFileName_EncryptedZipFile;
FOUNDATION_EXPORT NSString * const kAPCFileName_UnencryptedZipFile;

FOUNDATION_EXPORT NSString * const kAPCFileExtension_JSON;
FOUNDATION_EXPORT NSString * const kAPCFileExtension_PrivateKey;
FOUNDATION_EXPORT NSString * const kAPCFileExtension_CommaSeparatedValues;

FOUNDATION_EXPORT NSString * const kAPCContentType_JSON;



@interface APCConstants : NSObject

@end












