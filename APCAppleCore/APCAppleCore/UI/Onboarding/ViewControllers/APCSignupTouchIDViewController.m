//
//  APCSignupTouchIDViewController.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCUser.h"
#import "UIView+Helper.h"
#import "APCPasscodeView.h"
#import "APCStepProgressBar.h"
#import "UIAlertView+Helper.h"
#import "APCSignupTouchIDViewController.h"
#import "APCSignUpPermissionsViewController.h"
#import "APCAppDelegate.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCKeychainStore.h"

@import LocalAuthentication;

@interface APCSignupTouchIDViewController () <APCPasscodeViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet APCPasscodeView *passcodeView;

@property (weak, nonatomic) IBOutlet APCPasscodeView *retryPasscodeView;

@end


@implementation APCSignupTouchIDViewController

@synthesize stepProgressBar;

@synthesize user = _user;

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupProgressBar];
    
    self.titleLabel.text = NSLocalizedString(@"Set a passcode\nfor secure identification", @"");
    
    self.passcodeView.delegate = self;
    self.retryPasscodeView.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showFirstTry];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:2 animation:YES];
    
    [self.passcodeView becomeFirstResponder];
}

#pragma mark - Setup

- (void)setupAppearance
{
    [self.titleLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.titleLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
}

- (void) setupProgressBar {
     
    CGFloat stepProgressByYPosition = self.topLayoutGuide.length;
    
    self.stepProgressBar = [[APCStepProgressBar alloc] initWithFrame:CGRectMake(0, stepProgressByYPosition, self.view.width, kAPCSignUpProgressBarHeight)
                                                               style:APCStepProgressBarStyleDefault];
    self.stepProgressBar.numberOfSteps = kNumberOfSteps;
    [self.view addSubview:self.stepProgressBar];
    
    [self.stepProgressBar setCompletedSteps:1 animation:NO];
}

- (APCUser *) user {
    if (!_user) {
        _user = ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
    }
    return _user;
}


#pragma mark - APCPasscodeViewDelegate

- (void) passcodeViewDidFinish:(APCPasscodeView *)passcodeView withCode:(NSString *)code {
    if (passcodeView == self.passcodeView) {
        [self showRetry];
    }
    else if (self.passcodeView.code.length > 0) {
        if ([self.passcodeView.code isEqualToString:self.retryPasscodeView.code]) {
            [self savePasscode];
        }
        else {
            [self showFirstTry];
            
            [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Identification", @"") message:NSLocalizedString(@"Your passcodes are not identical. Please enter it again.", @"")];
        }
    }
}

#pragma mark - Private Methods

- (void) next
{
    
}

- (void) showFirstTry
{
    self.passcodeView.hidden = NO;
    self.retryPasscodeView.hidden = YES;
    
    self.titleLabel.text = NSLocalizedString(@"Set a passcode\nfor secure identification", @"");
    
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

#pragma mark Passcode

- (void)savePasscode
{
    [APCKeychainStore setString:self.retryPasscodeView.code forKey:kAPCPasscodeKey];
    [self next];
}


@end
