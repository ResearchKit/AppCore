// 
//  APCEmailVerifyViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCEmailVerifyViewController.h"
#import "APCAppDelegate.h"
#import "UIAlertController+Helper.h"
#import "APCUser+Bridge.h"
#import "UIAlertController+Helper.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"
#import "NSError+APCAdditions.h"
#import "APCAppCore.h"

@interface APCEmailVerifyViewController ()
@property (nonatomic, readonly) APCUser * user;
@end

@implementation APCEmailVerifyViewController

- (APCUser *)user
{
    return ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Email Verification", nil);
    
    [self setupAppearance];
    
    self.emailLabel.text = self.user.email;
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    self.topMessageLabel.text = [NSString stringWithFormat:@"An email has been sent by %@ to", appName];
    
    [self checkSignIn];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  APCLogViewControllerAppeared();
    
    self.emailLabel.text = self.user.email;
}

- (void)setupAppearance
{
    [self.logoImageView setImage:[UIImage imageNamed:@"logo_disease"]];
    
    [self.topMessageLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    [self.topMessageLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [self.emailLabel setFont:[UIFont appMediumFontWithSize:16.0f]];
    [self.emailLabel setAdjustsFontSizeToFitWidth:YES];
    [self.emailLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [self.middleMessageLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    [self.middleMessageLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [self.bottomMessageLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    [self.bottomMessageLabel setTextColor:[UIColor appSecondaryColor3]];
    
    [self.changeEmailButton.titleLabel setFont:[UIFont appRegularFontWithSize:12.0f]];
    [self.changeEmailButton setTitleColor:[UIColor appSecondaryColor2] forState:UIControlStateNormal];
    
    [self.resendEmailButton.titleLabel setFont:[UIFont appRegularFontWithSize:16.0f]];
    [self.resendEmailButton setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
}

- (void) checkSignIn
{
    __weak APCEmailVerifyViewController * weakSelf = self;
    [self.user signInOnCompletion:^(NSError *error) {
        if (error) {
            if (error.code == kSBBServerPreconditionNotMet) {
                [weakSelf getServerConsent];
            }
            else if (error.code == 404)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    APCLogDebug(@"Checking Server Again");
                    APCLogEventWithData(kNetworkEvent, @{@"event_detail":@"Checking Bridgeserver for email verification of current user"});
                    [weakSelf checkSignIn];
                });
            }
            else
            {
                APCLogError2 (error);
                UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"User Sign In Error", @"") message:error.localizedDescription];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        else
        {
            self.user.signedIn = YES;
            [self.user updateProfileOnCompletion:^(NSError *error) {
                APCLogError2 (error);
            }];
        }
    }];
}

- (void) getServerConsent
{
    if (self.user.isUserConsented) {
        [self.user sendUserConsentedToBridgeOnCompletion:^(NSError *error) {
            if (error) {
                UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"User Consent Error", @"") message:error.localizedDescription];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else
            {
                self.user.consented = YES;
                [self checkSignIn];
            }
        }];
    }
}

- (IBAction) skip: (id) __unused sender
{
    self.user.signedIn = YES;
}

- (IBAction) changeEmailAddress: (id) __unused sender
{
    
}

- (IBAction) secretButton: (id) __unused sender
{
    self.user.signedIn = YES;
}

- (IBAction) resendEmail: (id) __unused sender
{
    [self.user resendEmailVerificationOnCompletion:^(NSError *error) {
        if (error != nil) {
            APCLogError2 (error);
        }
     }];
}

@end
