//
//  ViewController.h
//  Profile
//
//  Created by Karthik Keyan on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCUserInfoCell.h"

typedef NS_ENUM(NSUInteger, APCUserInfoField) {
    APCUserInfoFieldUserName = 0,
    APCUserInfoFieldEmail,
    APCUserInfoFieldPassword,
    APCUserInfoFieldDateOfBirth,
    APCUserInfoFieldMedicalCondition,
    APCUserInfoFieldMedication,
    APCUserInfoFieldBloodType,
    APCUserInfoFieldWeight,
    APCUserInfoFieldHeight,
    APCUserInfoFieldGender
};

@class APCProfile;

@interface APCUserInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, APCUserInfoCellDelegate>

@property (nonatomic, strong) NSArray *fields;

@property (nonatomic, readonly) NSArray *medicalConditions;

@property (nonatomic, readonly) NSArray *medications;

@property (nonatomic, readonly) NSArray *bloodTypes;

@property (nonatomic, readonly) NSArray *heightValues;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) APCProfile *profile;

- (Class) cellClass;

@end

