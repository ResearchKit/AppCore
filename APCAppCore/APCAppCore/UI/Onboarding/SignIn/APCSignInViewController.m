// 
//  APCSignInViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCAppCore.h"
#import "APCSignInViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCEmailVerifyViewController.h"
#import "UIAlertController+Helper.h"

static NSString * const kServerInvalidEmailErrorString = @"Invalid username or password.";

@interface APCSignInViewController () <RKSTTaskViewControllerDelegate>

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
    APCLogViewController();
}

#pragma mark - Appearance

- (void)setupAppearance
{
    [self.userHandleTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.userHandleTextField setFont:[UIFont appRegularFontWithSize:17.0f]];
    [self.userHandleTextField setTintColor:[UIColor appPrimaryColor]];
    
    APCUser * user = [self user];
    
    self.userHandleTextField.text = user.email;
    
    [self.passwordTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.passwordTextField setFont:[UIFont appMediumFontWithSize:17.0f]];
    [self.passwordTextField setTintColor:[UIColor appPrimaryColor]];
    
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

- (APCOnboarding *)onboarding
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).onboarding;
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
        
        user.email = self.userHandleTextField.text;
        
        user.password = self.passwordTextField.text;
        [user signInOnCompletion:^(NSError *error) {
            [spinnerController dismissViewControllerAnimated:YES completion:^{
                if (error) {
                    APCLogError2 (error);
                    
                    if (error.code == kSBBServerPreconditionNotMet) {
                        [self showConsent];
                        
                    } else {
                        NSString *errorMessage = [error message];
                        errorMessage = [errorMessage isEqualToString:kServerInvalidEmailErrorString] ? NSLocalizedString(@"Invalid email or password.\n\nIn case you have not verified your account, please do so by clicking the link in the email we have sent you.", @"EmailError") : errorMessage;
                        
                        UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:errorMessage];
                        [self presentViewController:alert animated:YES completion:nil];
                        
                    }
                    
                } else
                {
                    [user retrieveConsentOnCompletion:^(NSError *error) {
                        if (error) {
                            APCLogError2 (error);
                            
                            if (error.code == kSBBServerPreconditionNotMet) {
                                [self showConsent];
                            } else {
                                UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:error.message];
                                [self presentViewController:alert animated:YES completion:nil];
                            }
                            
                        } else {
                            user.consented = YES;
                            user.userConsented = YES;
                            [self signInSuccess];
                        }
                    }];
                    
                }
            }];
            
        }];
    } else {
        UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:errorMessage];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Custom methods

- (void)signInSuccess
{
    APCUser *user = [self user];
    
    [user getProfileOnCompletion:^(NSError *error) {
        APCLogError2 (error);
    }];
    
    if (user.isSecondaryInfoSaved) {
        user.signedIn = YES;
    } else{
        UIViewController *viewController = [[self onboarding] nextScene];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)showConsent
{
    RKSTTaskViewController *consentViewController = [((APCAppDelegate*)[UIApplication sharedApplication].delegate) consentViewController];
    consentViewController.taskDelegate = self;
    [self.navigationController presentViewController:consentViewController animated:YES completion:nil];
}

- (void)sendConsent
{
    APCUser *user = [self user];
    
    APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
    [self presentViewController:spinnerController animated:YES completion:nil];
    
    [user sendUserConsentedToBridgeOnCompletion:^(NSError *error) {
        [spinnerController dismissViewControllerAnimated:YES completion:^{
            
            if (error) {
                if (error.code == 409) {
                    [self handleConsentConflict];
                }
            } else {
                user.consented = YES;
                [self signInSuccess];
            }
        }];
        
    }];
}

- (void)handleConsentConflict
{
    UIAlertController *alertContorller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Sign In", @"") message:NSLocalizedString(@"You have previously withdrawn from this Study. Do you wish to rejoin?", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Rejoin", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self rejoinStudy];
    }];
    [alertContorller addAction:yesAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [alertContorller addAction:cancelAction];
    
    [self.navigationController presentViewController:alertContorller animated:YES completion:nil];
}

- (void)rejoinStudy
{
    APCUser *user = [self user];
    
    [user resumeStudyOnCompletion:^(NSError *error) {
        if (error) {
            APCLogError2 (error);
            
            UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:error.message];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            user.consented = YES;
            [self signInSuccess];
        }
    }];
}

#pragma mark - RKSTTaskViewControllerDelegate methods

- (void)taskViewControllerDidComplete: (RKSTTaskViewController *)taskViewController
{
    APCUser *user = [self user];
    user.userConsented = YES;
    
    RKSTConsentSignatureResult *consentResult = (RKSTConsentSignatureResult *)[[taskViewController.result.results[1] results] firstObject];
    
    user.consentSignatureName = consentResult.signature.name;
    user.consentSignatureImage = UIImagePNGRepresentation(consentResult.signature.signatureImage);
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = consentResult.signature.signatureDateFormatString;
    user.consentSignatureDate = [dateFormatter dateFromString:consentResult.signature.signatureDate];
    
    [taskViewController dismissViewControllerAnimated:YES completion:^{
        [self sendConsent];
    }];
}

- (void)taskViewControllerDidCancel:(RKSTTaskViewController *)taskViewController
{
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewController:(RKSTTaskViewController *)taskViewController didFailOnStep:(RKSTStep *)step withError:(NSError *)error
{
    //TODO: Figure out what to do if it fails
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions 

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
