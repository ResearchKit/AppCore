//
//  APCForgotPasswordViewController.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/4/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "NSString+Helper.h"
#import "UIAlertView+Helper.h"
#import "APCUserInfoConstants.h"
#import "APCForgotPasswordViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

@interface APCForgotPasswordViewController ()

@end

@implementation APCForgotPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.emailTextField becomeFirstResponder];
}

#pragma mark - Appearance

- (void)setupAppearance
{
    [self.emailTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.emailTextField setFont:[UIFont appRegularFontWithSize:17.0f]];
    
    [self.usernameTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.usernameTextField setFont:[UIFont appMediumFontWithSize:17.0f]];
}

#pragma mark - UITableViewDelegate method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self.emailTextField becomeFirstResponder];
    } else {
        [self.usernameTextField becomeFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField == self.emailTextField) {
        [self.usernameTextField becomeFirstResponder];
    } else {
        [self sendPassword];
    }
    
    return YES;
}

- (BOOL) isContentValid:(NSString **)errorMessage {
    BOOL isContentValid = NO;
    
    if (self.usernameTextField.text.length == 0) {
        *errorMessage = NSLocalizedString(@"Please enter your Username.", @"");
        isContentValid = NO;
    }
    else if (self.emailTextField.text.length == 0) {
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
        }
        else {
            [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"General Information", @"") message:NSLocalizedString(@"Please give a valid email address", @"")];
        }
    } else{
        [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Forgot Password", @"") message:error];
    }
    
}

- (IBAction)done:(id)sender {
    [self sendPassword];
}
@end
