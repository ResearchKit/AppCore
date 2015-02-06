// 
//  APCChangeEmailViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCChangeEmailViewController.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"
#import "APCUserInfoConstants.h"
#import "NSString+Helper.h"
#import "UIAlertController+Helper.h"
#import "APCAppCore.h"

@interface APCChangeEmailViewController ()

@end

@implementation APCChangeEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
    [self setupNavAppearance];
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

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self updateEmailAddress];
    
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

- (void)updateEmailAddress
{
    NSString *error;
    
    if ([self isContentValid:&error]) {
        if ([self.emailTextField.text isValidForRegex:(NSString *)kAPCGeneralInfoItemEmailRegEx]) {
            
        }
        else {
            UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Change Email", @"") message:NSLocalizedString(@"Please enter a valid email address", @"")];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else{
        UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Change Email", @"") message:error];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Selectors / IBActions

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender
{
    [self updateEmailAddress];
}


@end
