// 
//  APCPermissionPrimingViewController.m 
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
 
#import "APCPermissionPrimingViewController.h"
#import "APCOnboardingManager.h"
#import "APCPermissionsManager.h"
#import "APCCustomBackButton.h"
#import "APCConstants.h"

#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"


@implementation APCPermissionPrimingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupAppearance];
    [self setupNavAppearance];
    
    self.title = NSLocalizedString(@"Consent", @"Consent");
    self.titleLabel.text = NSLocalizedString(@"What to Expect", @"What to Expect");
    
    APCPermissionsManager *permissionsManager = [self onboardingManager].permissionsManager;
    self.detailTextLabel.text = [permissionsManager permissionDescriptionForType:kAPCSignUpPermissionsTypeHealthKit];
}

- (void)setupAppearance {
    self.titleLabel.font = [UIFont appLightFontWithSize:38.0f];
    self.titleLabel.textColor = [UIColor appSecondaryColor1];
    
    self.detailTextLabel.font = [UIFont appRegularFontWithSize:16.0f];
    self.detailTextLabel.textColor = [UIColor appSecondaryColor1];
    
    self.headerImageView.image = [UIImage imageNamed:@"switch_icon"];
}

- (void)setupNavAppearance {
    if ([[self onboarding] taskType] == kAPCOnboardingTaskTypeSignUp) {
        UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                       target:self
                                                                                       action:@selector(back)];
        [self.navigationItem setLeftBarButtonItem:backBarButton];
    } else {
        [self.navigationItem setHidesBackButton:YES];
    }
}

- (APCOnboardingManager *)onboardingManager {
    return [(id<APCOnboardingManagerProvider>)[UIApplication sharedApplication].delegate onboardingManager];
}

- (APCOnboarding *)onboarding {
    return [self onboardingManager].onboarding;
}

- (IBAction)next:(id) __unused sender {
    UIViewController *viewController = [[self onboarding] nextScene];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)back {
    [[self onboarding] popScene];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
