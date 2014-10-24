//
//  APCForgotUsernameViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/17/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCForgotUsernameViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

- (IBAction)forgotUsername:(id)sender;
@end
