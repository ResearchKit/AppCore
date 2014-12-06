// 
//  APCProfileViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCUserInfoViewController.h"

@interface APCProfileViewController : APCUserInfoViewController <APCPickerTableViewCellDelegate, APCTextFieldTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate>

@property (nonatomic, strong) APCUser *user;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;

@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;

@property (weak, nonatomic) IBOutlet UILabel *editLabel;

@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UILabel *footerTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *diseaseLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;

@property (weak, nonatomic) IBOutlet UIButton *signOutButton;

@property (weak, nonatomic) IBOutlet UIButton *leaveStudyButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

@property (nonatomic, strong) UIImage *profileImage;

- (IBAction)signOut:(id)sender;

- (IBAction)leaveStudy:(id)sender;

- (IBAction)changeProfileImage:(id)sender;

- (IBAction)editFields:(id)sender;

- (void)loadProfileValuesInModel;

- (void)setupDataFromJSONFile:(NSString *)jsonFileName;

@end
