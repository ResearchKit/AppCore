//
//  APCForgotPasswordViewController.h
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/4/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCViewController.h"

@interface APCForgotPasswordViewController : APCViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emaiTextField;

- (void) sendPassword;

@end
