// 
//  APCConstants.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, APCSignUpPermissionsType) {
    kSignUpPermissionsTypeHealthKit,
    kSignUpPermissionsTypeLocation,
    kSignUpPermissionsTypePushNotifications,
    kSignUpPermissionsTypeCoremotion,
};

typedef NS_ENUM(NSUInteger, APCDashboardMessageType) {
    kAPCDashboardMessageTypeAlert,
    kAPCDashboardMessageTypeInsight,
};

typedef NS_ENUM(NSUInteger, APCDashboardGraphType) {
    kAPCDashboardGraphTypeLine,
    kAPCDashboardGraphTypePie,
    kAPCDashboardGraphTypeTimeline,
};

FOUNDATION_EXPORT NSString *const APCUserSignedUpNotification;
FOUNDATION_EXPORT NSString *const APCUserSignedInNotification;
FOUNDATION_EXPORT NSString *const APCUserLogOutNotification;
FOUNDATION_EXPORT NSString *const APCUserWithdrawStudyNotification;
FOUNDATION_EXPORT NSString *const APCUserDidConsentNotification;

FOUNDATION_EXPORT NSString *const APCScheduleUpdatedNotification;

FOUNDATION_EXPORT NSString *const APCAppDidRegisterUserNotification;
FOUNDATION_EXPORT NSString *const APCAppDidFailToRegisterForRemoteNotification;

FOUNDATION_EXPORT NSString *const APCScoringHealthKitDataIsAvailableNotification;

FOUNDATION_EXPORT NSString *const kStudyIdentifierKey;
FOUNDATION_EXPORT NSString *const kAppPrefixKey;
FOUNDATION_EXPORT NSString *const kBridgeEnvironmentKey;
FOUNDATION_EXPORT NSString *const kDatabaseNameKey;
FOUNDATION_EXPORT NSString *const kTasksAndSchedulesJSONFileNameKey;
FOUNDATION_EXPORT NSString *const kHKWritePermissionsKey;
FOUNDATION_EXPORT NSString *const kHKReadPermissionsKey;
FOUNDATION_EXPORT NSString *const kAppServicesListRequiredKey;
FOUNDATION_EXPORT NSString *const kVideoURLKey;

FOUNDATION_EXPORT NSString *const kAnalyticsOnOffKey;
FOUNDATION_EXPORT NSString *const kAnalyticsFlurryAPIKeyKey;	// Really. The NSDictionary key for something known as a "key."

FOUNDATION_EXPORT NSString *const kHKQuantityTypeKey;
FOUNDATION_EXPORT NSString *const kHKCategoryTypeKey;
FOUNDATION_EXPORT NSString *const kHKCharacteristicTypeKey;
FOUNDATION_EXPORT NSString *const kHKCorrelationTypeKey;
FOUNDATION_EXPORT NSString *const kHKWorkoutTypeKey;

FOUNDATION_EXPORT NSString *const kPasswordKey;
FOUNDATION_EXPORT NSString *const kSessionTokenKey;
FOUNDATION_EXPORT NSString *const kNumberOfMinutesForPasscodeKey;

FOUNDATION_EXPORT NSString *const kRegularFontNameKey;
FOUNDATION_EXPORT NSString *const kMediumFontNameKey;
FOUNDATION_EXPORT NSString *const kLightFontNameKey;

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

/*********************************************************************************/
#pragma mark - Events
/*********************************************************************************/
FOUNDATION_EXPORT NSString *const kAppStateChangedEvent;
FOUNDATION_EXPORT NSString *const kNetworkEvent;
FOUNDATION_EXPORT NSString *const kSchedulerEvent;
FOUNDATION_EXPORT NSString *const kTaskEvent;

@interface APCConstants : NSObject

@end
