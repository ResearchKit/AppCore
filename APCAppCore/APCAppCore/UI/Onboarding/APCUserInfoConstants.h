// 
//  APCUserInfoConstants.h 
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
    kAPCSettingsItemTypeLicenseInformation,
    kAPCSettingsItemTypeSharingOptions,
};


typedef NS_ENUM(APCTableViewItemType, APCTableViewStudyItemType) {
    kAPCTableViewStudyItemTypeStudyDetails,
    kAPCTableViewStudyItemTypeShare,
    kAPCTableViewStudyItemTypeReviewConsent
};


typedef NS_ENUM(APCTableViewItemType, APCTableViewLearnItemType) {
    kAPCTableViewLearnItemTypeStudyDetails,
    kAPCTableViewLearnItemTypeOtherDetails,
    kAPCTableViewLearnItemTypeReviewConsent,
    kAPCTableViewLearnItemTypeShare,
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
