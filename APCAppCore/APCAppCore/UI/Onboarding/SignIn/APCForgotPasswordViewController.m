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

@interface APCForgotPasswordViewController ()

@end

@implementation APCForgotPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupAppearance];
    [self setupNavAppearance];
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
        }
        else {
            UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Forgot Password", @"") message:NSLocalizedString(@"Please enter a valid email address", @"")];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else{
        UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Forgot Password", @"") message:error];
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
    [self sendPassword];
}

@end
