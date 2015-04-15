// 
//  APCForgotPasswordViewController.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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

- (void)dealloc {
    _emailTextField.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupAppearance];
    
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
    
    self.resetButton.backgroundColor = [UIColor clearColor];
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

                __weak typeof(self) weakSelf = self;
                
                [SBBComponent(SBBAuthManager) requestPasswordResetForEmail: emailAddress
                                                                completion: ^(NSURLSessionDataTask * __unused task,
                                                                              id __unused responseObject,
                                                                              NSError *error) {

                    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {

						[spinnerController dismissViewControllerAnimated:YES completion:^{

							if (error)
							{
								NSString *errorTitle = NSLocalizedString (@"Forgot Password", @"This is the title for the message that appears when the user asked for a 'reset password,' and that 'resetting' process failed.");
                                
                                UIAlertController *alert = [UIAlertController simpleAlertWithTitle: errorTitle
                                                                                           message: error.message];

								[weakSelf presentViewController:alert animated:YES completion:nil];
							}
							else
							{
								[UIView animateWithDuration:0.2 animations:^{
									weakSelf.emailMessageLabel.text = NSLocalizedString(@"An email has been sent.", @"");
									weakSelf.emailMessageLabel.alpha = 1;
                                    weakSelf.resetButton.alpha = 0;
								} completion:^(BOOL __unused finished) {
                                    [weakSelf performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
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

- (IBAction)resetPassword:(id) __unused sender
{
    [self sendPassword];
}

- (IBAction)cancel:(id) __unused sender
{
    [self dismiss];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
