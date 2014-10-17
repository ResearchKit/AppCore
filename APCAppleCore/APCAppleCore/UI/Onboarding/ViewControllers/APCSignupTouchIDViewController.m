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

@import LocalAuthentication;

@interface APCSignupTouchIDViewController () <APCPasscodeViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *touchIDButton;

@property (weak, nonatomic) IBOutlet APCPasscodeView *passcodeView;

@property (weak, nonatomic) IBOutlet APCPasscodeView *retryPasscodeView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *touchIdButtonBottomConstraint;

@property (nonatomic, strong) LAContext *touchContext;

@end

@implementation APCSignupTouchIDViewController

@synthesize stepProgressBar;

@synthesize user = _user;

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupProgressBar];
    
    self.touchContext = [LAContext new];
    
    [self enableTouchIDFeatureIfAvailable];
    
    self.titleLabel.text = NSLocalizedString(@"Set a passcode\nfor secure identification", @"");
    
    self.passcodeView.delegate = self;
    self.retryPasscodeView.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self showFirstTry];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:2 animation:YES];
    
    [self.passcodeView becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Setup

- (void)setupAppearance
{
    [self.touchIDButton setBackgroundColor:[UIColor appPrimaryColor]];
    [self.touchIDButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.touchIDButton.titleLabel setFont:[UIFont appMediumFontWithSize:17.0f]];
    
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

- (void) enableTouchIDFeatureIfAvailable {
    NSError *error;
    if ([self.touchContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        self.touchIDButton.hidden = NO;
    }
    else {
        self.touchIDButton.hidden = YES;
        
//        if (error) {
//            [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Touch Authentication", @"") message:error.localizedDescription];
//        }
        NSLog(@"Touch Authentication: %@", error.localizedDescription);
    }
}


#pragma mark - APCPasscodeViewDelegate

- (void) passcodeViewDidFinish:(APCPasscodeView *)passcodeView withCode:(NSString *)code {
    if (passcodeView == self.passcodeView) {
        [self showRetry];
    }
    else if (self.passcodeView.code.length > 0) {
        if ([self.passcodeView.code isEqualToString:self.retryPasscodeView.code]) {
            [self next];
        }
        else {
            [self showFirstTry];
            
            [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Identification", @"") message:NSLocalizedString(@"Your passcodes are not identical. Please enter it again.", @"")];
        }
    }
}


#pragma mark - IBActions

- (IBAction) touchID {
    
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


#pragma mark - NSNotification

- (void) keyboardWillShow:(NSNotification *)notification
{
    CGFloat keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    double animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.touchIdButtonBottomConstraint.constant = keyboardHeight;
    } completion:nil];
}

- (void) keyboardWillHide:(NSNotification *)notification {
    
    double animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.touchIdButtonBottomConstraint.constant = 0;
    } completion:nil];
}

- (IBAction)skip
{
    
}

- (IBAction)useTouchId:(id)sender
{
    NSString *localizedReason = NSLocalizedString(@"Authentication", @"");
    
    typeof(self) __weak weakSelf = self;
    [self.touchContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:localizedReason reply:^(BOOL success, NSError *error) {
        if (success) {
            [weakSelf next];
        }
        else {
            [UIAlertView showSimpleAlertWithTitle:NSLocalizedString(@"Touch Authentication", @"") message:error.localizedDescription];
        }
    }];
}

@end
