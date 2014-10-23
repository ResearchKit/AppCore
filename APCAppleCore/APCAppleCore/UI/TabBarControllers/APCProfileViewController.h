//
//  APCProfileViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/10/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCUser+HealthKit.h"
#import "APCTextFieldTableViewCell.h"
#import "APCPickerTableViewCell.h"
#import "APCDefaultTableViewCell.h"
#import "APCSegmentedTableViewCell.h"

@interface APCProfileViewController : UITableViewController <APCPickerTableViewCellDelegate, APCTextFieldTableViewCellDelegate, APCSegmentedButtonDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) NSMutableArray *itemTypeOrder;

@property (nonatomic, strong) APCUser *user;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) IBOutlet UILabel *editLabel;

@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UILabel *footerTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *diseaseLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;

@property (weak, nonatomic) IBOutlet UIButton *signOutButton;

@property (weak, nonatomic) IBOutlet UIButton *leaveStudyButton;

@property (weak, nonatomic) IBOutlet UIButton *reviewConsentButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

- (IBAction)signOut:(id)sender;

- (IBAction)leaveStudy:(id)sender;

- (IBAction)reviewConsent:(id)sender;

- (IBAction)changeProfileImage:(id)sender;

- (IBAction)editFields:(id)sender;

@end
