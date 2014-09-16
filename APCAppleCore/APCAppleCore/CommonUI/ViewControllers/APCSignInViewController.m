//
//  APCSignInViewController.m
//  UI
//
//  Created by Karthik Keyan on 9/4/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "NSBundle+Category.h"
#import "APCSignInViewController.h"
#import "APCForgotPasswordViewController.h"

@interface APCSignInViewController ()

@end

@implementation APCSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNavigationItems];
}

- (void) addNavigationItems {
    self.title = NSLocalizedString(@"Sign In", @"");
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sign In", @"") style:UIBarButtonItemStylePlain target:self action:@selector(signIn)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
}


#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userHandleTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];
        [self signIn];
    }
    
    return YES;
}

- (void) signIn {
    
}

- (IBAction) forgotPassword {
    APCForgotPasswordViewController *forgotPasswordViewController = [[APCForgotPasswordViewController alloc] initWithNibName:@"APCForgotPasswordViewController" bundle:[NSBundle appleCoreBundle]];
    [self.navigationController pushViewController:forgotPasswordViewController animated:YES];
}

@end
