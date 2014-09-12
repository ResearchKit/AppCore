//
//  APCSignUpUserInfoViewController.h
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSignUpProgressing.h"
#import "APCUserInfoViewController.h"

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
    APCSignUpUserInfoItemGender
};

@interface APCSignUpUserInfoViewController : APCUserInfoViewController <APCSignUpProgressing>

@end
