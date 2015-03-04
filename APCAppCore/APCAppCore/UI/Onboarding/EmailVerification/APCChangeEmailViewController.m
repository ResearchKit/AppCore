// 
//  APCChangeEmailViewController.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCChangeEmailViewController.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"
#import "APCUserInfoConstants.h"
#import "NSString+Helper.h"
#import "UIAlertController+Helper.h"
#import "APCAppCore.h"

static NSString *kInternetNotAvailableErrorMessage1 = @"Internet Not Connected";
static NSString *kInternetNotAvailableErrorMessage2 = @"BackendServer Not Reachable";

@interface APCChangeEmailViewController ()

@end

@implementation APCChangeEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
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

#pragma mark - UITableViewDelegate method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self.emailTextField becomeFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *) __unused textField
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

- (APCUser *) user {
    return ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
}

#pragma mark - Public Methods

- (void)updateEmailAddress
{
    NSString *error;
    
    if ([self isContentValid:&error]) {
        if ([self.emailTextField.text isValidForRegex:(NSString *)kAPCGeneralInfoItemEmailRegEx]) {
            
            APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
            [self presentViewController:spinnerController animated:YES completion:nil];
            
            APCUser *user = [self user];
            user.email = self.emailTextField.text;
            
            typeof(self) __weak weakSelf = self;
            [user signUpOnCompletion:^(NSError *error) {
                if (error) {
                    
                    APCLogError2 (error);
                    
                    [spinnerController dismissViewControllerAnimated:NO completion:^{
                        
                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", @"Dismiss") style:UIAlertActionStyleCancel handler:^(UIAlertAction * __unused action) {
                            
                        }];
                        
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:error.message preferredStyle:UIAlertControllerStyleAlert];
                        [alertController addAction:cancelAction];
                        
                        [weakSelf.navigationController presentViewController:alertController animated:YES completion:nil];
                    }];
                }
                else
                {
                    [spinnerController dismissViewControllerAnimated:NO completion:^{
                        
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }];
                }
            }];
            
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

- (IBAction) done:(id) __unused sender
{
    [self updateEmailAddress];
}

- (IBAction)cancel:(id) __unused sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
