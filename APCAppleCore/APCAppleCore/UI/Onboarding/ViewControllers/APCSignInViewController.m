//
//  APCSignInViewController.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/4/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppleCore.h"
#import "APCSignInViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCForgotUsernameViewController.h"
#import "APCEmailVerifyViewController.h"

@interface APCSignInViewController ()

@property (weak, nonatomic) IBOutlet UIButton *touchIdButton;

@end

@implementation APCSignInViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.userHandleTextField becomeFirstResponder];
}

#pragma mark - Appearance

- (void)setupAppearance
{
    [self.touchIdButton setBackgroundColor:[UIColor appPrimaryColor]];
    [self.touchIdButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.touchIdButton.titleLabel setFont:[UIFont appMediumFontWithSize:17.0f]];
    [self.userHandleTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.userHandleTextField setFont:[UIFont appRegularFontWithSize:17.0f]];
    
    [self.passwordTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.passwordTextField setFont:[UIFont appMediumFontWithSize:17.0f]];
}

#pragma mark - UITableViewDelegate method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self.userHandleTextField becomeFirstResponder];
    } else {
        [self.passwordTextField becomeFirstResponder];
    }
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


- (void) signIn
{
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
        *errorMessage = NSLocalizedString(@"Please enter your user name", @"");
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

- (IBAction)forgotPassword
{
    APCForgotPasswordViewController *forgotPasswordViewController = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"ForgotPasswordVC"];
    [self.navigationController pushViewController:forgotPasswordViewController animated:YES];
    
}

- (IBAction)signIn:(id)sender
{
    APCAppState state = ((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kAPCAppStateKey]).integerValue;
    
    if (state == kAPCAppStateConsented) {
        [self signIn];
    } else {
        APCEmailVerifyViewController *emailVerifyViewController = [[UIStoryboard storyboardWithName:@"APHEmailVerify" bundle:nil] instantiateInitialViewController];
        [self.navigationController pushViewController:emailVerifyViewController animated:YES];
    }
}

- (IBAction)forgotUsername:(id)sender
{
    APCForgotUsernameViewController *forgotUsernameViewController = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"ForgotUsernameVC"];
    [self.navigationController pushViewController:forgotUsernameViewController animated:YES];
}

@end
