// 
//  APCChangeEmailViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

@interface APCChangeEmailViewController : UITableViewController<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;

- (void)updateEmailAddress;

@end
