//
//  ViewController.h
//  Profile
//
//  Created by Karthik Keyan on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "UserInfoCell.h"

typedef NS_ENUM(NSUInteger, UserInfoField) {
    UserInfoFieldUserName = 0,
    UserInfoFieldEmail,
    UserInfoFieldPassword,
    UserInfoFieldDateOfBirth,
    UserInfoFieldMedicalCondition,
    UserInfoFieldMedication,
    UserInfoFieldBloodType,
    UserInfoFieldWeight,
    UserInfoFieldHeight,
    UserInfoFieldGender
};

@class Profile;

@interface UserInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UserInfoCellDelegate>

@property (nonatomic, strong) NSArray *fields;

@property (nonatomic, readonly) NSArray *medicalConditions;

@property (nonatomic, readonly) NSArray *medications;

@property (nonatomic, readonly) NSArray *bloodTypes;

@property (nonatomic, readonly) NSArray *heightValues;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) Profile *profile;

@end

