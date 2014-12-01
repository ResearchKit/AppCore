//
//  APCChangeEmailViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/30/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCChangeEmailViewController : UITableViewController<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;

- (void)updateEmailAddress;

@end
