// 
//  APCUserInfoConstants.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#ifndef Parkinson_APHUserInfoConstants_h
#define Parkinson_APHUserInfoConstants_h

@import Foundation;
@import CoreGraphics;

typedef NSUInteger APCTableViewItemType;

typedef NS_ENUM(APCTableViewItemType, APCUserInfoItemType) {
    kAPCUserInfoItemTypeName = 0,
    kAPCUserInfoItemTypeEmail,
    kAPCUserInfoItemTypePassword,
    kAPCUserInfoItemTypeDateOfBirth,
    kAPCUserInfoItemTypeMedicalCondition,
    kAPCUserInfoItemTypeMedication,
    kAPCUserInfoItemTypeBloodType,
    kAPCUserInfoItemTypeWeight,
    kAPCUserInfoItemTypeHeight,
    kAPCUserInfoItemTypeBiologicalSex,
    kAPCUserInfoItemTypeSleepTime,
    kAPCUserInfoItemTypeWakeUpTime,
    kAPCUserInfoItemTypeGlucoseLevel,
    kAPCUserInfoItemTypeCustomSurvey,
    kAPCSettingsItemTypeAutoLock,
    kAPCSettingsItemTypePasscode,
    kAPCSettingsItemTypeReminderOnOff,
    kAPCSettingsItemTypeReminderTime,
    kAPCSettingsItemTypePermissions,
    kAPCUserInfoItemTypeReviewConsent,
    kAPCSettingsItemTypePrivacyPolicy,
    kAPCSettingsItemTypeTermsAndConditions,
};


typedef NS_ENUM(APCTableViewItemType, APCTableViewStudyItemType) {
    kAPCTableViewStudyItemTypeStudyDetails,
    kAPCTableViewStudyItemTypeShare,
    kAPCTableViewStudyItemTypeReviewConsent
};


typedef NS_ENUM(APCTableViewItemType, APCTableViewLearnItemType) {
    kAPCTableViewLearnItemTypeStudyDetails,
    kAPCTableViewLearnItemTypeOtherDetails,
    kAPCTableViewLearnItemTypeReviewConsent
};

typedef NS_ENUM(NSUInteger, APCAppState) {
    kAPCAppStateNotConsented,
    kAPCAppStateConsented
};

static CGFloat const kAPCSignUpProgressBarHeight                = 14.0f;

static NSUInteger kAPCPasswordMinimumLength = 2;


static NSString * const kAPCUserInfoFieldNameRegEx              = @"[A-Za-z\\ ]+";

static NSString * const kAPCGeneralInfoItemUserNameRegEx        = @"[A-Za-z0-9_.]+";

static NSString * const kAPCGeneralInfoItemEmailRegEx           = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

static NSString * const kAPCMedicalInfoItemWeightRegEx          = @"[0-9]{1,4}";

static NSString * const kAPCMedicalInfoItemSleepTimeFormat     = @"hh:mm a";


static NSString * const kAPCAppStateKey = @"APCAppState";

static NSString * const kAPCPasscodeKey = @"APCPasscode";

#endif
