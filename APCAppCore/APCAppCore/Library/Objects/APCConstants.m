// 
//  APCConstants.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCConstants.h"

/* -------------------------
 Constants
 ------------------------- */
NSString *const APCUserSignedUpNotification   = @"APCUserSignedUpNotification";
NSString *const APCUserSignedInNotification   = @"APCUserSignedInNotification";
NSString *const APCUserLogOutNotification     = @"APCUserLogOutNotification";
NSString *const APCUserWithdrawStudyNotification     = @"APCUserWithdrawStudyNotification";
NSString *const APCUserDidConsentNotification = @"APCUserDidConsentNotification";

NSString *const APCScheduleUpdatedNotification = @"APCScheduleUpdatedNotification";

NSString *const APCAppDidRegisterUserNotification            = @"APCAppDidRegisterUserNotification";
NSString *const APCAppDidFailToRegisterForRemoteNotification = @"APCAppDidFailToRegisterForRemoteNotifications";

NSString *const APCScoringHealthKitDataIsAvailableNotification = @"APCScoringHealthKitDataIsAvailableNotification";

NSString *const kStudyIdentifierKey                  = @"StudyIdentifierKey";
NSString *const kAppPrefixKey                        = @"AppPrefixKey";
NSString *const kBridgeEnvironmentKey                = @"BridgeEnvironmentKey";
NSString *const kDatabaseNameKey                     = @"DatabaseNameKey";
NSString *const kTasksAndSchedulesJSONFileNameKey    = @"TasksAndSchedulesJSONFileNameKey";
NSString *const kHKWritePermissionsKey               = @"HKWritePermissions";
NSString *const kHKReadPermissionsKey                = @"HKReadPermissions";
NSString *const kAppServicesListRequiredKey          = @"AppServicesListRequired";
NSString *const kVideoURLKey                         = @"VideoURLKey";

NSString *const kHKQuantityTypeKey                   = @"HKQuantityType";
NSString *const kHKCategoryTypeKey                   = @"HKCategoryType";
NSString *const kHKCharacteristicTypeKey             = @"HKCharacteristicType";
NSString *const kHKCorrelationTypeKey                = @"HKCorrelationType";

NSString *const kPasswordKey                         = @"Password";
NSString *const kSessionTokenKey                     = @"sessionToken";
NSString *const kNumberOfMinutesForPasscodeKey       = @"NumberOfMinutesForPasscodeKey";

NSString *const kAnalyticsOnOffKey					 = @"AnalyticsOnOffKey";
NSString *const kAnalyticsFlurryAPIKeyKey			 = @"AnalyticsFlurryAPIKeyKey";

NSString *const kRegularFontNameKey = @"RegularFontNameKey";
NSString *const kMediumFontNameKey  = @"MediumFontNameKey";
NSString *const kLightFontNameKey   = @"LightFontNameKey";

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


/*********************************************************************************/
#pragma mark - Events
/*********************************************************************************/
NSString *const kAppStateChangedEvent   = @"AppStateChanged";
NSString *const kNetworkEvent           = @"NetworkEvent";
NSString *const kSchedulerEvent         = @"SchedulerEvent";
NSString *const kTaskEvent              = @"TaskEvent";


@implementation APCConstants

@end
