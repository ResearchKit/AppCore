// 
//  APCSignupPasscodeViewController.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCUser.h"
#import "APCPasscodeView.h"
#import "UIAlertController+Helper.h"
#import "APCSignupPasscodeViewController.h"
#import "APCSignUpPermissionsViewController.h"
#import "APCAppDelegate.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCKeychainStore.h"
#import "UIView+Helper.h"
#import "APCAppCore.h"

@import LocalAuthentication;

@interface APCSignupPasscodeViewController () <APCPasscodeViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet APCPasscodeView *passcodeView;

@property (weak, nonatomic) IBOutlet APCPasscodeView *retryPasscodeView;

@end


@implementation APCSignupPasscodeViewController

@synthesize stepProgressBar;

@synthesize user = _user;

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = NSLocalizedString(@"Select a 4-digit passcode. Setting up a passcode will help provide quick and secure access to this application.", @"");
    
    self.passcodeView.delegate = self;
    self.retryPasscodeView.delegate = self;
    
    [self setupAppearance];
    [self setupNavAppearance];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showFirstTry];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:([self onboarding].onboardingTask.currentStepNumber - 1) animation:YES];
    
    [self.passcodeView becomeFirstResponder];
  APCLogViewControllerAppeared();
}

#pragma mark - Setup

- (void)setupAppearance
{
    [self.titleLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.titleLabel setFont:[UIFont appLightFontWithSize:17.0f]];
}

- (void)setupNavAppearance
{
    UIBarButtonItem  *backster = [APCCustomBackButton customBackBarButtonItemWithTarget:self action:@selector(back) tintColor:[UIColor appPrimaryColor]];
    [self.navigationItem setLeftBarButtonItem:backster];

}

- (APCUser *) user {
    if (!_user) {
        _user = ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
    }
    return _user;
}

- (APCOnboarding *)onboarding
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).onboarding;
}

#pragma mark - APCPasscodeViewDelegate

- (void) passcodeViewDidFinish:(APCPasscodeView *)passcodeView withCode:(NSString *) __unused code {
    if (passcodeView == self.passcodeView) {
        [self showRetry];
    }
    else if (self.passcodeView.code.length > 0) {
        if ([self.passcodeView.code isEqualToString:self.retryPasscodeView.code]) {
            [self savePasscode];
        }
        else {
            [self showFirstTry];

            UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Identification", @"") message:NSLocalizedString(@"Your passcodes are not identical. Please enter it again.", @"")];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

#pragma mark - Private Methods

- (void) next
{
    if ([self onboarding].onboardingTask.permissionScreenSkipped) {
        [self finishOnboarding];
    }else {
        UIViewController *viewController = [[self onboarding] nextScene];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
}

- (void) showFirstTry
{
    self.passcodeView.hidden = NO;
    self.retryPasscodeView.hidden = YES;
    
    self.titleLabel.text = NSLocalizedString(@"Select a 4-digit passcode. Setting up a passcode will help provide quick and secure access to this application.", @"");
    
    [self.passcodeView becomeFirstResponder];
    [self.passcodeView reset];
}

- (void) showRetry
{
    self.passcodeView.hidden = YES;
    self.retryPasscodeView.hidden = NO;
    
    self.titleLabel.text = NSLocalizedString(@"Re-enter your passcode", @"");
    
    [self.retryPasscodeView becomeFirstResponder];
    [self.retryPasscodeView reset];
}

- (void)back
{
    self.passcodeView.delegate = nil;
    self.retryPasscodeView.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
    
    [[self onboarding] popScene];
}

#pragma mark Passcode

- (void)savePasscode
{
    [APCKeychainStore setString:self.retryPasscodeView.code forKey:kAPCPasscodeKey];
    [self next];
}

#pragma mark - Selectors

- (void)finishOnboarding
{
    [self.stepProgressBar setCompletedSteps:[self onboarding].onboardingTask.currentStepNumber animation:YES];
    
    if ([self onboarding].taskType == kAPCOnboardingTaskTypeSignIn) {
        // We are posting this notification after .4 seconds delay, because we need to display the progress bar completion animation
        [self performSelector:@selector(setUserSignedIn) withObject:nil afterDelay:0.4];
    } else{
        [self performSelector:@selector(setUserSignedUp) withObject:nil afterDelay:0.4];
    }
    
}

- (void) setUserSignedUp
{
    self.user.signedUp = YES;
}

- (void)setUserSignedIn
{
    self.user.signedIn = YES;
}

@end
