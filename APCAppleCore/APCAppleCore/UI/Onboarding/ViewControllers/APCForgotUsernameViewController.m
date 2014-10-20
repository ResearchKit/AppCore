//
//  APCForgotUsernameViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/17/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCForgotUsernameViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "NSString+Helper.h"
#import "UIAlertView+Helper.h"
#import "APCUserInfoConstants.h"

@interface APCForgotUsernameViewController ()

@end

@implementation APCForgotUsernameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.emailTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Appearance

- (void)setupAppearance
{
    [self.emailTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.emailTextField setFont:[UIFont appRegularFontWithSize:17.0f]];
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
    
    if (textField == self.emailTextField) {
        [self sendEmail];
    }
    
    self.navigationItem.rightBarButtonItem.enabled = [self isContentValid:nil];
    
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

- (IBAction)forgotUsername:(id)sender
{
    [self sendEmail];
}

- (void)sendEmail
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
@end
