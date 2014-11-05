//
//  APCSignUpGeneralInfoViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCUser+HealthKit.h"
#import "APCTextFieldTableViewCell.h"
#import "APCPickerTableViewCell.h"
#import "APCSegmentedTableViewCell.h"
#import "APCDefaultTableViewCell.h"
#import "APCSignUpProgressing.h"

@interface APCSignUpInfoViewController : UITableViewController <APCTextFieldTableViewCellDelegate, APCSegmentedTableViewCellDelegate, APCPickerTableViewCellDelegate, APCSignUpProgressing, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) NSMutableArray *itemsOrder;

@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;

@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UILabel *footerLabel;

- (BOOL) isContentValid:(NSString **)errorMessage;

- (void)setupAppearance;

@end
