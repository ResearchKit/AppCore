//
//  APCEmailVerifyViewController.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCEmailVerifyViewController.h"
#import "APCAppleCore.h"

@interface APCEmailVerifyViewController ()
@property (nonatomic, readonly) APCUser * user;
@property (weak, nonatomic) IBOutlet UILabel *userMessage;


@end

@implementation APCEmailVerifyViewController

- (APCUser *)user
{
    return ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Verify Email";
    self.userMessage.text = @"Please verify your email...";
    [self checkSignIn];
}

- (void) checkSignIn
{
    __weak APCEmailVerifyViewController * weakSelf = self;
    [self.user signInOnCompletion:^(NSError *error) {
        if (error) {
            if (error.code == kSBBServerPreconditionNotMet) {
                weakSelf.userMessage.text = @"Sending consent to server...";
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
                [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"User Consent Error", @"User Consent Error") message:error.message];
            }
            else
            {
                self.user.consented = YES;
                [self checkSignIn];
            }
        }];
    }
}


@end
