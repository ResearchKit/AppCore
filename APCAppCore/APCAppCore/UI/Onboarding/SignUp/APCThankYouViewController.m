//
//  APCThankYouViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCThankYouViewController.h"
#import "APCAppCore.h"

@interface APCThankYouViewController ()

@end

@implementation APCThankYouViewController

@synthesize stepProgressBar;

@synthesize user = _user;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

- (IBAction)next:(APCButton *) __unused sender {
    if (self.emailVerified == YES) {
        [self performSelector:@selector(setUserSignedIn) withObject:nil afterDelay:0.4];
    } else {
        [self finishOnboarding];
    }
}

- (void)finishOnboarding
{
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
    [(APCAppDelegate *)[UIApplication sharedApplication].delegate afterOnBoardProcessIsFinished];
}

@end
