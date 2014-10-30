//
//  APCForgotPasswordViewController.h
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/4/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCForgotPasswordViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

- (void) sendPassword;

@end
