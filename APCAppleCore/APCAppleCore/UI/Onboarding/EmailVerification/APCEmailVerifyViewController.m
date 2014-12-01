//
//  APCEmailVerifyViewController.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCEmailVerifyViewController.h"
#import "APCAppDelegate.h"
#import "UIAlertController+Helper.h"
#import "APCUser+Bridge.h"
#import "UIAlertController+Helper.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"

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
    [self.changeEmailButton setTitle:[NSString stringWithFormat:@"Not %@? Change email address", self.user.firstName] forState:UIControlStateNormal];
    
    [self checkSignIn];
}

- (void)setupAppearance
{
    [self.logoImageView setImage:[UIImage imageNamed:@"logo_disease"]];
    
    [self.topMessageLabel setFont:[UIFont appRegularFontWithSize:19.0f]];
    [self.topMessageLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [self.emailLabel setFont:[UIFont appRegularFontWithSize:16.0f]];
    [self.emailLabel setTextColor:[UIColor appPrimaryColor]];
    
    [self.middleMessageLabel setFont:[UIFont appRegularFontWithSize:19.0f]];
    [self.middleMessageLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [self.bottomMessageLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    [self.bottomMessageLabel setTextColor:[UIColor appSecondaryColor3]];
    
    [self.changeEmailButton.titleLabel setFont:[UIFont appRegularFontWithSize:12.0f]];
    [self.changeEmailButton setTitleColor:[UIColor appSecondaryColor3] forState:UIControlStateNormal];
}

- (void) checkSignIn
{
    __weak APCEmailVerifyViewController * weakSelf = self;
    [self.user signInOnCompletion:^(NSError *error) {
        if (error) {
            if (error.code == kSBBServerPreconditionNotMet) {
                [weakSelf getServerConsent];
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"Checking Server Again...");
                    [weakSelf checkSignIn];
                });
            }
        }
        else
        {
            self.user.signedIn = YES;
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

- (IBAction)skip:(id)sender
{
    self.user.signedIn = YES;
}

- (IBAction)changeEmailAddress:(id)sender
{
    
}
- (IBAction)secretButton:(id)sender
{
    self.user.signedIn = YES;
}
@end
