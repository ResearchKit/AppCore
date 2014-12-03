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
#import "APCEmailVerifyViewController.h"
#import "UIAlertController+Helper.h"

@interface APCSignInViewController ()

@end

@implementation APCSignInViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
    [self setupNavAppearance];
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
    [self.userHandleTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.userHandleTextField setFont:[UIFont appRegularFontWithSize:17.0f]];
    
    APCUser * user = [self user];
    
    if (user.email) {
        NSString *partialEmail = (user.email.length >=4) ? [user.email substringToIndex:3] : user.email;
        
        self.userHandleTextField.text = [NSString stringWithFormat:@"%@XXXXX", partialEmail];
        self.userHandleTextField.enabled = NO;
    }
    
    [self.passwordTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.passwordTextField setFont:[UIFont appMediumFontWithSize:17.0f]];
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Forgot your Password?"];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appSecondaryColor3] range:NSMakeRange(0, 12)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appSecondaryColor1] range:NSMakeRange(12, 9)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont appRegularFontWithSize:16.0f] range:NSMakeRange(0, attributedString.length)];
    
    [self.forgotPasswordButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
}

- (void)setupNavAppearance
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 44, 44);
    [backButton setImage:[[UIImage imageNamed:@"back_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    backButton.tintColor = [UIColor appPrimaryColor];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButton];
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

#pragma mark - Private methods

- (APCUser *)user
{
    APCAppDelegate * appDelegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
    APCUser * user = appDelegate.dataSubstrate.currentUser;
    return user;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Public methods

- (void) signIn
{
    NSString *errorMessage;
    if ([self isContentValid:&errorMessage]) {
        
        APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
        [self presentViewController:spinnerController animated:YES completion:nil];
    
        APCUser * user = [self user];
        
        if (!user.email) {
            user.email = self.userHandleTextField.text;
        }
        
        user.password = self.passwordTextField.text;
        [user signInOnCompletion:^(NSError *error) {
            [spinnerController dismissViewControllerAnimated:YES completion:^{
                if (error) {
                    UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:error.message];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else
                {
                    if (!user.consented) {
                        APCEmailVerifyViewController *emailVerifyVC = [[UIStoryboard storyboardWithName:@"APCEmailVerify" bundle:[NSBundle appleCoreBundle]] instantiateInitialViewController];
                        
                        APCAppDelegate *appDelegate = (APCAppDelegate*)[[UIApplication sharedApplication] delegate];
                        appDelegate.window.rootViewController = emailVerifyVC;
                    } else{
                        user.signedIn = YES;
                    }
                }
            }];
            
        }];
    } else {
        UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:errorMessage];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (BOOL) isContentValid:(NSString **)errorMessage {
    BOOL isContentValid = NO;
    
    if (self.userHandleTextField.text.length == 0) {
        *errorMessage = NSLocalizedString(@"Please enter your email", @"");
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
    APCForgotPasswordViewController *forgotPasswordViewController = [[UIStoryboard storyboardWithName:@"APCOnboarding" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCForgotPasswordViewController"];
    [self.navigationController pushViewController:forgotPasswordViewController animated:YES];
    
}

- (IBAction)signIn:(id)sender
{    
    [self signIn];
}

@end
