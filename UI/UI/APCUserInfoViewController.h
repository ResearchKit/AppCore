//
//  ViewController.h
//  Profile
//
//  Created by Karthik Keyan on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCUserInfoCell.h"
#import "APCViewController.h"

@interface APCUserInfoViewController : APCViewController <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, APCConfigurableCellDelegate>

@property (nonatomic, strong) NSArray *fields;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;

@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;

@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;

@property (weak, nonatomic) IBOutlet UIView *headerTextFieldSeparatorView;

@property (nonatomic, strong) UITableView *tableView;

- (Class) cellClass;

@end

