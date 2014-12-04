// 
//  APCForgotPasswordViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

@interface APCForgotPasswordViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;

- (void) sendPassword;

@end
