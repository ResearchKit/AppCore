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

@interface APCSignInViewController () <ORKTaskViewControllerDelegate>

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
    ORKTaskViewController *consentViewController = [((APCAppDelegate*)[UIApplication sharedApplication].delegate) consentViewController];
    consentViewController.delegate = self;
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

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithResult:(ORKTaskViewControllerResult)result error:(NSError *)error
{
    if (result == ORKTaskViewControllerResultCompleted)
    {
        [self taskViewControllerDidComplete:taskViewController];
    }
    else if (result == ORKTaskViewControllerResultDiscarded)
    {
        [taskViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else if (result == ORKTaskViewControllerResultFailed)
    {
        [taskViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else if (result == ORKTaskViewControllerResultSaved)
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
    
    if (consentResult.signature.requiresName && (consentResult.signature.firstName && consentResult.signature.lastName))
    {
        APCUser *user = [self user];
        user.consentSignatureName = [consentResult.signature.firstName stringByAppendingFormat:@" %@",consentResult.signature.lastName];
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
    [self.navigationController pushViewController:forgotPasswordViewController animated:YES];
    
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
