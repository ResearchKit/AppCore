// 
//  APCSignInViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

@interface APCSignInViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *userHandleTextField;

@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

- (void) signIn;

- (IBAction)forgotPassword;

@end
