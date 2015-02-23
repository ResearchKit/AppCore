// 
//  APCForgotPasswordViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCButton.h"

@interface APCForgotPasswordViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UILabel *emailMessageLabel;
@property (weak, nonatomic) IBOutlet APCButton *resetButton;

- (void) sendPassword;

- (IBAction)resetPassword:(id)sender;
- (IBAction)cancel:(id)sender;

@end
