//
//  APCSignInViewController.h
//  UI
//
//  Created by Karthik Keyan on 9/4/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCViewController.h"

@interface APCSignInViewController : APCViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *userHandleTextField;

@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

- (void) signIn;

- (IBAction) forgotPassword;

@end
