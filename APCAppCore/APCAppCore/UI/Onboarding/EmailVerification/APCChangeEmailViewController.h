// 
//  APCChangeEmailViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

@interface APCChangeEmailViewController : UITableViewController<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;

- (void)updateEmailAddress;
- (IBAction)cancel:(id)sender;

@end
