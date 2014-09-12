//
//  APCSignUpUserInfoViewController.h
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSignUpProgressing.h"
#import "APCUserInfoViewController.h"

typedef NS_ENUM(NSUInteger, APCSignUpUserInfoField) {
    APCSignUpUserInfoFieldUserName = 0,
    APCSignUpUserInfoFieldEmail,
    APCSignUpUserInfoFieldPassword,
    APCSignUpUserInfoFieldDateOfBirth,
    APCSignUpUserInfoFieldMedicalCondition,
    APCSignUpUserInfoFieldMedication,
    APCSignUpUserInfoFieldBloodType,
    APCSignUpUserInfoFieldWeight,
    APCSignUpUserInfoFieldHeight,
    APCSignUpUserInfoFieldGender
};

@interface APCSignUpUserInfoViewController : APCUserInfoViewController <APCSignUpProgressing>

@end
