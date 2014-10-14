//
//  APCSignInViewController.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/4/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppleCore.h"
#import "APCSignInViewController.h"


@interface APCSignInViewController ()

@end

@implementation APCSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNavigationItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    NSString *errorMessage;
    if ([self isContentValid:&errorMessage]) {
        APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
        [self presentViewController:spinnerController animated:YES completion:nil];
        
        APCAppDelegate * appDelegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
        APCUser * user = appDelegate.dataSubstrate.currentUser;
        
        if (!user.userName) {
            user.userName = self.userHandleTextField.text;
            user.password = self.passwordTextField.text;
            [user signInOnCompletion:^(NSError *error) {
                [spinnerController dismissViewControllerAnimated:YES completion:^{
                    if (error) {
                        [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:error.message];
                    }
                    else
                    {
                        user.signedIn = YES;
                    }
                }];
                
            }];
            
        }
        else if ([self.userHandleTextField.text isEqualToString:user.userName]) {
            [user signInOnCompletion:^(NSError *error) {
                [spinnerController dismissViewControllerAnimated:YES completion:^{
                    if (error) {
                        [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:error.message];
                    }
                    else
                    {
                        user.signedIn = YES;
                    }
                }];
                
            }];
        }
        else
        {
            [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:NSLocalizedString(@"Username does not match the existing username. Please delete the app to login as new user.", @"")];
        }
    }
    else {
        [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:errorMessage];
    }
}

- (BOOL) isContentValid:(NSString **)errorMessage {
    BOOL isContentValid = NO;
    
    if (self.userHandleTextField.text.length == 0) {
        *errorMessage = NSLocalizedString(@"Please enter your user name or email", @"");
        isContentValid = NO;
    }
    else if (self.passwordTextField.text.length == 0) {
        *errorMessage = NSLocalizedString(@"Please enter your password", @"");
        isContentValid = NO;
    }
    else {
        isContentValid = YES;
    }
    
    return isContentValid;
}


- (IBAction) forgotPassword {
    APCForgotPasswordViewController *forgotPasswordViewController = [[APCForgotPasswordViewController alloc] initWithNibName:@"APCForgotPasswordViewController" bundle:[NSBundle appleCoreBundle]];
    [self.navigationController pushViewController:forgotPasswordViewController animated:YES];
}

@end
