// 
//  APCSignInViewController.m 
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
 
#import "APCAppCore.h"
#import "APCSignInViewController.h"
#import "APCEmailVerifyViewController.h"
#import "APCOnboardingManager.h"
#import "APCLog.h"

#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "UIAlertController+Helper.h"

static NSString * const kServerInvalidEmailErrorString = @"Invalid username or password.";

@interface APCSignInViewController () <ORKTaskViewControllerDelegate>

@end

@implementation APCSignInViewController

- (void)dealloc {
    _userHandleTextField.delegate = nil;
    _passwordTextField.delegate = nil;
}

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
    APCLogViewControllerAppeared();
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
    UIBarButtonItem  *backster = [APCCustomBackButton customBackBarButtonItemWithTarget:self action:@selector(back) tintColor:[UIColor appPrimaryColor]];
    [self.navigationItem setLeftBarButtonItem:backster];
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

- (APCUser *)user {
    return [(id<APCOnboardingManagerProvider>)[UIApplication sharedApplication].delegate onboardingManager].user;
}

- (APCOnboarding *)onboarding {
    return [(id<APCOnboardingManagerProvider>)[UIApplication sharedApplication].delegate onboardingManager].onboarding;
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
            if (error) {
                [spinnerController dismissViewControllerAnimated:YES completion:^{
                    if (error) {
                        APCLogError2 (error);
                    
                        if (error.code == kSBBServerPreconditionNotMet) {
                            [self showConsent];
                        } else {
                            NSString *errorMessage = [error message];
                            errorMessage = [errorMessage isEqualToString:kServerInvalidEmailErrorString] ?
                                NSLocalizedString(@"Invalid email or password.\n\nIn case you have not verified your account, please do so by clicking the link in the email we have sent you.", nil) :
                            errorMessage;
                            
                            UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Sign In", @"") message:errorMessage];
                            [self presentViewController:alert animated:YES completion:nil];
                            
                        }
                    }
                }];
                
            } else {
                [user retrieveConsentOnCompletion:^(NSError *error) {
                    [spinnerController dismissViewControllerAnimated:YES completion:^{
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
                }];
            }
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
    ORKTaskViewController *consentViewController = [((APCAppDelegate*)[UIApplication sharedApplication].delegate) consentViewController];
    consentViewController.delegate = self;
    
    NSUInteger subviewsCount = consentViewController.view.subviews.count;
    UILabel *watermarkLabel = [APCExampleLabel watermarkInRect:consentViewController.view.bounds
                                                    withCenter:consentViewController.view.center];
    
    [consentViewController.view insertSubview:watermarkLabel atIndex:subviewsCount];
    
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
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Rejoin", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * __unused action) {
        [self rejoinStudy];
    }];
    [alertContorller addAction:yesAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * __unused action) {
        
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

#pragma mark - ORKTaskViewControllerDelegate methods

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(nullable NSError *)__unused error
{
    if (reason == ORKTaskViewControllerFinishReasonCompleted)
    {
        [self taskViewControllerDidComplete:taskViewController];
    }
    else if (reason == ORKTaskViewControllerFinishReasonDiscarded)
    {
        [taskViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else if (reason == ORKTaskViewControllerFinishReasonFailed)
    {
        [taskViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else if (reason == ORKTaskViewControllerFinishReasonSaved)
    {
        [taskViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)taskViewControllerDidComplete: (ORKTaskViewController *)taskViewController
{
    ORKConsentSignatureResult *consentResult =  nil;
    
    if ([taskViewController respondsToSelector:@selector(signatureResult)])
    {
        APCConsentTaskViewController *consentTaskViewController = (APCConsentTaskViewController *)taskViewController;
        if (consentTaskViewController.signatureResult)
        {
            consentResult = consentTaskViewController.signatureResult;
        }
    }
    else
    {
        NSString*   signatureResultStepIdentifier = @"reviewStep";
        
        for (ORKStepResult* result in taskViewController.result.results)
        {
            if ([result.identifier isEqualToString:signatureResultStepIdentifier])
            {
                consentResult = (ORKConsentSignatureResult*)[[result results] firstObject];
                break;
            }
        }
        
        NSAssert(consentResult != nil, @"Unable to find consent result with signature (identifier == \"%@\"", signatureResultStepIdentifier);
    }
    
    if (consentResult.signature.requiresName && (consentResult.signature.givenName && consentResult.signature.familyName))
    {
        APCUser *user = [self user];
        user.consentSignatureName = [consentResult.signature.givenName stringByAppendingFormat:@" %@",consentResult.signature.familyName];
        user.consentSignatureImage = UIImagePNGRepresentation(consentResult.signature.signatureImage);
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = consentResult.signature.signatureDateFormatString;
        user.consentSignatureDate = [dateFormatter dateFromString:consentResult.signature.signatureDate];
        
        [self dismissViewControllerAnimated:YES completion:^
         {
             [((APCAppDelegate*)[UIApplication sharedApplication].delegate) dataSubstrate].currentUser.userConsented = YES;
             
             [self sendConsent];
         }];
    }
    else
    {
        [taskViewController dismissViewControllerAnimated:YES completion:^
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:APCConsentCompletedWithDisagreeNotification object:nil];
         }];
    }
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
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:forgotPasswordViewController];
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (IBAction) signIn: (id) __unused sender
{
    if ([self.userHandleTextField isFirstResponder]) {
        [self.userHandleTextField resignFirstResponder];
    } else if ([self.passwordTextField isFirstResponder]){
        [self.passwordTextField resignFirstResponder];
    }
    
    [self signIn];
}

@end
