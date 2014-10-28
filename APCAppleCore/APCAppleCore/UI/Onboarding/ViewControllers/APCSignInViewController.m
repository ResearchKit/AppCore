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
    
    if (user.userName) {
        NSString *partialUsername = [user.userName substringToIndex:3];
        
        self.userHandleTextField.text = [NSString stringWithFormat:@"%@XXXX", partialUsername];
    }
    
    [self.passwordTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.passwordTextField setFont:[UIFont appMediumFontWithSize:17.0f]];
    
}

- (void)setupNavAppearance
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 44, 44);
    [backButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
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
        
        if (!user.userName) {
            user.userName = self.userHandleTextField.text;
        }
        
        user.password = self.passwordTextField.text;
        [user signInOnCompletion:^(NSError *error) {
            [spinnerController dismissViewControllerAnimated:YES completion:^{
                if (error) {
                    [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:error.message];
                }
                else
                {
                    if (!user.consented) {
                        APCEmailVerifyViewController *emailVerifyVC = [[UIStoryboard storyboardWithName:@"APCEmailVerify" bundle:[NSBundle appleCoreBundle]] instantiateInitialViewController];
                        
                        APCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                        appDelegate.window.rootViewController = emailVerifyVC;
                    } else{
                        user.signedIn = YES;
                    }
                }
            }];
            
        }];
    } else {
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
    [self signIn];
}

- (IBAction)forgotUsername:(id)sender
{
    APCForgotUsernameViewController *forgotUsernameViewController = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"ForgotUsernameVC"];
    [self.navigationController pushViewController:forgotUsernameViewController animated:YES];
}

@end
