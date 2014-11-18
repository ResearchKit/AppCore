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

@end
