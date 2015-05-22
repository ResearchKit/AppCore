// 
//  APCSignupPasscodeViewController.m 
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
 
#import "APCSignupPasscodeViewController.h"
#import "APCSignUpPermissionsViewController.h"
#import "APCOnboardingManager.h"
#import "APCDataSubstrate.h"
#import "APCConstants.h"
#import "APCLog.h"

#import "APCPasscodeView.h"
#import "APCCustomBackButton.h"
#import "APCStepProgressBar.h"

#import "UIView+Helper.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "UIAlertController+Helper.h"
#import "APCKeychainStore+Passcode.h"

@import LocalAuthentication;

@interface APCSignupPasscodeViewController () <APCPasscodeViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet APCPasscodeView *passcodeView;

@property (weak, nonatomic) IBOutlet APCPasscodeView *retryPasscodeView;

@end


@implementation APCSignupPasscodeViewController

@synthesize stepProgressBar;


#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = NSLocalizedString(@"Select a 4-digit passcode. Setting up a passcode will help provide quick and secure access to this application.", @"");
    
    self.passcodeView.delegate = self;
    self.retryPasscodeView.delegate = self;
    
    [self setupAppearance];
    [self setupNavAppearance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showFirstTry];
}

- (void)viewDidAppear:(BOOL)animated
{
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

- (APCOnboardingManager *)onboardingManager {
    return [(id<APCOnboardingManagerProvider>)[UIApplication sharedApplication].delegate onboardingManager];
}

- (APCOnboarding *)onboarding {
    return [self onboardingManager].onboarding;
}

#pragma mark - APCPasscodeViewDelegate

- (void)passcodeViewDidFinish:(APCPasscodeView *)passcodeView withCode:(NSString *) __unused code
{
    if (passcodeView == self.passcodeView) {
        [self showRetry];
    }
    else if (self.passcodeView.code.length > 0) {
        if ([self.passcodeView.code isEqualToString:self.retryPasscodeView.code]) {
            [self savePasscode];
        }
        else {
            UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Identification", @"") message:NSLocalizedString(@"Your passcodes are not identical. Please enter it again.", @"")];
            __weak typeof(self) weakSelf = self;
            [self presentViewController:alert animated:YES completion:^{[weakSelf showFirstTry];}];
        }
    }
}

#pragma mark - Private Methods

- (void)next:(id)__unused sender {
    if ([self onboarding].onboardingTask.permissionScreenSkipped) {
        [self finishOnboarding];
    } else {
        UIViewController *viewController = [[self onboarding] nextScene];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)showFirstTry
{
    self.passcodeView.hidden = NO;
    self.retryPasscodeView.hidden = YES;
    
    self.titleLabel.text = NSLocalizedString(@"Select a 4-digit passcode. Setting up a passcode will help provide quick and secure access to this application.", @"");
    
    [self.passcodeView becomeFirstResponder];
    [self.passcodeView reset];
}

- (void)showRetry
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

- (void)finishOnboarding {
    [self.stepProgressBar setCompletedSteps:[self onboarding].onboardingTask.currentStepNumber animation:YES];
    
    // We are calling this method after .4 seconds delay, because we need to display the progress bar completion animation
    APCOnboardingManager *manager = [self onboardingManager];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [manager onboardingDidFinish];
    });
}

#pragma mark Passcode

- (void)savePasscode
{
    if (self.retryPasscodeView.code) {
        [APCKeychainStore setPasscode:self.retryPasscodeView.code];
    }
    [self next:nil];
}

@end
