// 
//  APCSignUpInfoViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCUserInfoViewController.h"
#import "APCSignUpProgressing.h"
#import "APCFormTextField.h"

@interface APCSignUpInfoViewController : APCUserInfoViewController <APCSignUpProgressing, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;

@property (weak, nonatomic) IBOutlet APCFormTextField *nameTextField;

@property (weak, nonatomic) IBOutlet APCFormTextField *emailTextField;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UILabel *footerLabel;

- (BOOL) isContentValid:(NSString **)errorMessage;

- (void)setupAppearance;

@end
