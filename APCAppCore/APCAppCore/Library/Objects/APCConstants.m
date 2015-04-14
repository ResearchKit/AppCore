// 
//  APCConstants.m 
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
 
#import "APCConstants.h"



// ---------------------------------------------------------
#pragma mark - Constants
// ---------------------------------------------------------

NSString *const APCUserSignedUpNotification   = @"APCUserSignedUpNotification";
NSString *const APCUserSignedInNotification   = @"APCUserSignedInNotification";
NSString *const APCUserLogOutNotification     = @"APCUserLogOutNotification";
NSString *const APCUserWithdrawStudyNotification     = @"APCUserWithdrawStudyNotification";
NSString *const APCUserDidConsentNotification = @"APCUserDidConsentNotification";

NSString *const APCScheduleUpdatedNotification = @"APCScheduleUpdatedNotification";
NSString *const APCUpdateActivityNotification = @"APCUpdateActivityNotification";

NSString *const APCAppDidRegisterUserNotification            = @"APCAppDidRegisterUserNotification";
NSString *const APCAppDidFailToRegisterForRemoteNotification = @"APCAppDidFailToRegisterForRemoteNotifications";

NSString *const APCScoringHealthKitDataIsAvailableNotification = @"APCScoringHealthKitDataIsAvailableNotification";
NSString *const APCTaskResultsProcessedNotification = @"APCTaskResultsProcessedNotification";

NSString *const APCUpdateTasksReminderNotification = @"APCUpdateTasksReminderNotification";

NSString *const APCConsentCompletedWithDisagreeNotification = @"goToSignInJoinScreen";

NSString *const APCMotionHistoryReporterDoneNotification = @"APCMotionHistoryReporterDoneNotification";

NSString *const APCHealthKitObserverQueryUpdateForSampleTypeNotification = @"APCHealthKitObserverQueryUpdateForSampleTypeNotification";

NSString *const kStudyIdentifierKey                 = @"StudyIdentifierKey";
NSString *const kAppPrefixKey                       = @"AppPrefixKey";
NSString *const kBridgeEnvironmentKey               = @"BridgeEnvironmentKey";
NSString *const kDatabaseNameKey                    = @"DatabaseNameKey";
NSString *const kTasksAndSchedulesJSONFileNameKey   = @"TasksAndSchedulesJSONFileNameKey";
NSString *const kConsentSectionFileNameKey          = @"ConsentSectionFileNameKey";
NSString *const kHKWritePermissionsKey              = @"HKWritePermissions";
NSString *const kHKReadPermissionsKey               = @"HKReadPermissions";
NSString *const kAppServicesListRequiredKey         = @"AppServicesListRequired";
NSString *const kAppServicesDescriptionsKey         = @"AppServicesDescriptions";
NSString *const kAppProfileElementsListKey          = @"AppProfileElementsListKey";
NSString *const kVideoURLKey                        = @"VideoURLKey";
NSString *const kTaskReminderStartupDefaultOnOffKey = @"TaskReminderStartupDefaultOnOffKey";
NSString *const kTaskReminderStartupDefaultTimeKey  = @"TaskReminderStartupDefaultTimeKey";
NSString *const kDelayReminderIdentifier            = @"DelayReminderIdentifier";
NSString *const kTaskReminderDelayCategory          = @"DelayCategory";
NSString *const kDBStatusVersionKey                 = @"DBStatusVersionKey";
NSString *const kShareMessageKey                    = @"ShareMessageKey";

NSString *const kHKQuantityTypeKey          = @"HKQuantityType";
NSString *const kHKCategoryTypeKey          = @"HKCategoryType";
NSString *const kHKCharacteristicTypeKey    = @"HKCharacteristicType";
NSString *const kHKCorrelationTypeKey       = @"HKCorrelationType";

NSString * const kPasswordKey                    = @"Password";
NSString * const kNumberOfMinutesForPasscodeKey  = @"NumberOfMinutesForPasscodeKey";

NSInteger      const kAPCSigninErrorCode_NotSignedIn                        = 404;
NSUInteger     const kAPCSigninNumRetriesBeforePause                        = 10;
NSTimeInterval const kAPCSigninNumSecondsBetweenRetries                     = 10;
NSTimeInterval const kAPCSignInButtonPulseFadeInTimeInSeconds               = 1.5;
NSTimeInterval const kAPCSignInButtonPulseFadeOutTimeInSeconds              = 1.5;
NSTimeInterval const kAPCSignInButtonPulsePauseWhileVisibleTimeInSeconds    = 1.5;

NSString *const kRegularFontNameKey = @"RegularFontNameKey";
NSString *const kMediumFontNameKey  = @"MediumFontNameKey";
NSString *const kLightFontNameKey   = @"LightFontNameKey";

NSString *const kHairlineEnDashJoinerKey = @"\u200a\u2013\u200a";

NSString *const kPrimaryAppColorKey = @"PrimaryAppColorKey";

NSString *const kSecondaryColor1Key = @"SecondaryColor1Key";
NSString *const kSecondaryColor2Key = @"SecondaryColor2Key";
NSString *const kSecondaryColor3Key = @"SecondaryColor3Key";
NSString *const kSecondaryColor4Key = @"SecondaryColor4Key";

NSString *const kTertiaryColor1Key = @"TertiaryColor1Key";
NSString *const kTertiaryColor2Key = @"TertiaryColor2Key";

NSString *const kTertiaryGreenColorKey  = @"TertiaryGreenColorKey";
NSString *const kTertiaryBlueColorKey   = @"TertiaryBlueColorKey";
NSString *const kTertiaryRedColorKey    = @"TertiaryRedColorKey";
NSString *const kTertiaryYellowColorKey = @"TertiaryYellowColorKey";
NSString *const kTertiaryPurpleColorKey = @"TertiaryPurpleColorKey";
NSString *const kTertiaryGrayColorKey   = @"TertiaryGrayColorKey";
NSString *const kBorderLineColor        = @"LightGrayBorderColorKey";

NSString *const kTasksReminderDefaultsOnOffKey = @"TasksReminderDefaultsOnOffKey";
NSString *const kTasksReminderDefaultsTimeKey = @"TasksReminderDefaultsTimeKey";

NSString *const kScheduleOffsetTaskIdKey = @"scheduleOffsetTaskIdKey";
NSString *const kScheduleOffsetOffsetKey = @"scheduleOffsetOffsetKey";

NSString *const kReviewConsentActionPDF    = @"PDF";
NSString *const kReviewConsentActionVideo  = @"VIDEO";
NSString *const kReviewConsentActionSlides = @"SLIDES";

NSString *const kAllSetActivitiesTextOriginal   = @"allSetActivitiesTextOriginal";
NSString *const kAllSetActivitiesTextAdditional = @"allSetActivitiesTextAdditional";
NSString *const kAllSetDashboardTextOriginal    = @"allSetDashboardTextOriginal";
NSString *const kAllSetDashboardTextAdditional  = @"allSetDashboardTextAdditional";

NSString *const kActivitiesSectionKeepGoing     = @"activitiesSectionKeepGoing";
NSString *const kActivitiesSectionYesterday     = @"activitiesSectionYesterday";
NSString *const kActivitiesSectionToday         = @"activitiesSectionToday";

NSString *const kActivitiesRequiresMotionSensor = @"activitiesRequireMotionSensor";



// ---------------------------------------------------------
#pragma mark - Events
// ---------------------------------------------------------

NSString *const kAppStateChangedEvent   = @"AppStateChanged";
NSString *const kNetworkEvent           = @"NetworkEvent";
NSString *const kSchedulerEvent         = @"SchedulerEvent";
NSString *const kTaskEvent              = @"TaskEvent";
NSString *const kPageViewEvent          = @"PageViewEvent";
NSString *const kErrorEvent             = @"ErrorEvent";
NSString *const kPassiveCollectorEvent  = @"PassiveCollectorEvent";



// ---------------------------------------------------------
#pragma mark - Known files, folders, extensions, and content types
// ---------------------------------------------------------

/*
 Folders that will appear in the user's Documents directory,
 or elsewhere that we might need to understand and inspect 'em.
 */

NSString * const kAPCFolderName_ArchiveAndUpload_TopLevelFolder = @"StuffBeingArchivedAndUploaded";
NSString * const kAPCFolderName_ArchiveAndUpload_Archiving      = @"StuffBeingArchived";
NSString * const kAPCFolderName_ArchiveAndUpload_Uploading      = @"StuffBeingUploaded";

NSString * const kAPCFileName_EncryptedZipFile                  = @"encrypted.zip";
NSString * const kAPCFileName_UnencryptedZipFile                = @"unencrypted.zip";

NSString * const kAPCFileExtension_JSON                         = @"json";
NSString * const kAPCFileExtension_PrivateKey                   = @"pem";
NSString * const kAPCFileExtension_CommaSeparatedValues         = @"csv";

NSString * const kAPCContentType_JSON                           = @"application/json";



@implementation APCConstants

@end













