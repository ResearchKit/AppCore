//
//  APHUserInfoConstants.h
//  Parkinson
//
//  Created by Karthik Keyan on 9/16/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#ifndef Parkinson_APHUserInfoConstants_h
#define Parkinson_APHUserInfoConstants_h

@import Foundation;
@import CoreGraphics;

typedef NS_ENUM(NSUInteger, APCSignUpUserInfoItem) {
    APCSignUpUserInfoItemUserName = 0,
    APCSignUpUserInfoItemEmail,
    APCSignUpUserInfoItemPassword,
    APCSignUpUserInfoItemDateOfBirth,
    APCSignUpUserInfoItemMedicalCondition,
    APCSignUpUserInfoItemMedication,
    APCSignUpUserInfoItemBloodType,
    APCSignUpUserInfoItemWeight,
    APCSignUpUserInfoItemHeight,
    APCSignUpUserInfoItemGender,
    APCSignUpUserInfoItemSleepTime,
    APCSignUpUserInfoItemWakeUpTime
};

static CGFloat const kAPCSignUpProgressBarHeight                = 1;

static NSString * const kAPCGeneralInfoItemUserNameRegEx        = @"[A-Za-z0-9_.]+";

static NSString * const kAPCGeneralInfoItemEmailRegEx           = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

static NSString * const kAPCMedicalInfoItemWeightRegEx          = @"[0-9]{1,4}";

static NSString * const kAPCMedicalInfoItemSleepTimeFormate     = @"HH:mm a";


#endif
