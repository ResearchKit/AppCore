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
        [self.emailTextField becomeFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
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

                [SBBComponent(SBBAuthManager) requestPasswordResetForEmail:emailAddress completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                    
                    [spinnerController dismissViewControllerAnimated:YES completion:^{
                        UIAlertController *alert = nil;
                        
                        if (error) {
                            alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Forgot Password", @"")  message:[[error.userInfo valueForKey:@"SBBOriginalErrorKey"] valueForKey:@"message"]];
                        } else {
                            
                            [UIView animateWithDuration:0.2 animations:^{
                                self.emailMessageLabel.text = NSLocalizedString(@"An email has been sent.", @"");
                                self.emailMessageLabel.alpha = 1;
                            }];
                            
                        }
                    
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                            
                            if (alert) {
                                [self presentViewController:alert animated:YES completion:nil];
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

- (IBAction)done:(id)sender
{
    [self sendPassword];
}

@end
