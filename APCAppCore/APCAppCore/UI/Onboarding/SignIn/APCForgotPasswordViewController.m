// 
//  APCForgotPasswordViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "NSString+Helper.h"
#import "UIAlertController+Helper.h"
#import "APCUserInfoConstants.h"
#import "APCForgotPasswordViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCAppCore.h"

@interface APCForgotPasswordViewController ()

@end

@implementation APCForgotPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupAppearance];
    [self setupNavAppearance];
    
    self.emailMessageLabel.alpha = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.emailTextField becomeFirstResponder];
  APCLogViewControllerAppeared();
}

#pragma mark - Appearance

- (void)setupAppearance
{
    [self.emailTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.emailTextField setFont:[UIFont appRegularFontWithSize:17.0f]];
}

- (void)setupNavAppearance
{
    UIBarButtonItem  *backster = [APCCustomBackButton customBackBarButtonItemWithTarget:self action:@selector(back) tintColor:[UIColor appPrimaryColor]];
    [self.navigationItem setLeftBarButtonItem:backster];
}

#pragma mark - UITableViewDelegate method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self.emailTextField becomeFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn: (UITextField *) __unused textField
{
    [self sendPassword];
    
    return YES;
}

- (BOOL) isContentValid:(NSString **)errorMessage {
    BOOL isContentValid = NO;
    
    if (self.emailTextField.text.length == 0) {
        *errorMessage = NSLocalizedString(@"Please enter your email address.", @"");
        isContentValid = NO;
    }
    else {
        isContentValid = YES;
    }
    
    return isContentValid;
}

#pragma mark - Public Methods

- (void) sendPassword
{
    NSString *error;
    
    if ([self isContentValid:&error]) {
        if ([self.emailTextField.text isValidForRegex:(NSString *)kAPCGeneralInfoItemEmailRegEx]) {

            NSString *emailAddress = self.emailTextField.text;
            
            if (emailAddress.length) {
                
                APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
                [self presentViewController:spinnerController animated:YES completion:nil];

                [SBBComponent(SBBAuthManager) requestPasswordResetForEmail: emailAddress
                                                                completion: ^(NSURLSessionDataTask * __unused task,
                                                                              id __unused responseObject,
                                                                              NSError *error) {

                    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {

						[spinnerController dismissViewControllerAnimated:YES completion:^{

							if (error)
							{
								NSString *errorTitle = NSLocalizedString (@"Forgot Password", @"This is the title for the message that appears when the user asked for a 'reset password,' and that 'resetting' process failed.");
								NSDictionary *sageErrorDictionary = error.userInfo [@"SBBOriginalErrorKey"];
								NSString *sageErrorMessage = sageErrorDictionary [@"message"];

								UIAlertController *alert = [UIAlertController simpleAlertWithTitle: errorTitle
																						   message: sageErrorMessage];

								[self presentViewController:alert animated:YES completion:nil];
							}
							else
							{
								[UIView animateWithDuration:0.2 animations:^{
									self.emailMessageLabel.text = NSLocalizedString(@"An email has been sent.", @"");
									self.emailMessageLabel.alpha = 1;
								}];
							}
						}];
                    }];
                }];
            }
        }
        else {
            [UIView animateWithDuration:0.2 animations:^{
                self.emailMessageLabel.text = NSLocalizedString(@"Please enter a valid email address", @"");
                self.emailMessageLabel.alpha = 1;
            }];
        }
    }
}

#pragma mark - Selectors / IBActions

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) done: (id) __unused sender
{
    [self sendPassword];
}

@end
