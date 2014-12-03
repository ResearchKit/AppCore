//
//  APCSignUpGeneralInfoViewController.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCUserInfoViewController.h"
#import "APCSignUpProgressing.h"

@interface APCSignUpInfoViewController : APCUserInfoViewController <APCSignUpProgressing, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;

@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UILabel *footerLabel;

- (BOOL) isContentValid:(NSString **)errorMessage;

- (void)setupAppearance;

@end
