// 
//  APCConstants.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
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
FOUNDATION_EXPORT NSString *const kDBStatusVersionKey;

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

/*********************************************************************************/
#pragma mark - Events
/*********************************************************************************/
FOUNDATION_EXPORT NSString *const kAppStateChangedEvent;
FOUNDATION_EXPORT NSString *const kNetworkEvent;
FOUNDATION_EXPORT NSString *const kSchedulerEvent;
FOUNDATION_EXPORT NSString *const kTaskEvent;
FOUNDATION_EXPORT NSString *const kPageViewEvent;
FOUNDATION_EXPORT NSString *const kErrorEvent;
FOUNDATION_EXPORT NSString *const kPassiveCollectorEvent;


/*********************************************************************************/
#pragma mark - Errors
/*********************************************************************************/
FOUNDATION_EXPORT NSString * const kAPCErrorDomain_CoreData;
FOUNDATION_EXPORT NSInteger  const kAPCErrorDomain_CoreData_Code_Undetermined;
FOUNDATION_EXPORT NSInteger  const kAPCErrorDomain_CoreData_Code_NoError;
FOUNDATION_EXPORT NSInteger  const kAPCErrorDomain_CoreData_Code_CantCreateDatabase;
FOUNDATION_EXPORT NSInteger  const kAPCErrorDomain_CoreData_Code_CantOpenExistingDatabase;

@interface APCConstants : NSObject

@end












