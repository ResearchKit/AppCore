//
//  APCSignupTouchIDViewController.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCProfile.h"
#import "UIView+Helper.h"
#import "APCPasscodeView.h"
#import "APCStepProgressBar.h"
#import "UIAlertView+Helper.h"
#import "APCSignupTouchIDViewController.h"
#import "APCSignUpPermissionsViewController.h"

@import LocalAuthentication;

@interface APCSignupTouchIDViewController () <APCPasscodeViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *touchIDButton;

@property (weak, nonatomic) IBOutlet APCPasscodeView *passcodeView;

@property (weak, nonatomic) IBOutlet APCPasscodeView *retryPasscodeView;

@property (nonatomic, strong) LAContext *touchContext;

@end

@implementation APCSignupTouchIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNavigationItems];
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

- (void) addNavigationItems {
    self.title = NSLocalizedString(@"Sign Up", @"");
}

- (void) setupProgressBar {
    
    [self setStepNumber:3 title:NSLocalizedString(@"Identification", @"")];
    [self.stepProgressBar setCompletedSteps:1 animation:NO];
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
    else {
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


#pragma mark - Private Methods

- (void) next {
    [self.navigationController pushViewController:[APCSignUpPermissionsViewController new] animated:YES];
}

- (void) showFirstTry {
    self.passcodeView.hidden = NO;
    self.retryPasscodeView.hidden = YES;
    
    self.titleLabel.text = NSLocalizedString(@"Set a passcode\nfor secure identification", @"");
    
    [self.passcodeView becomeFirstResponder];
    [self.passcodeView reset];
}

- (void) showRetry {
    self.passcodeView.hidden = YES;
    self.retryPasscodeView.hidden = NO;
    
    self.titleLabel.text = NSLocalizedString(@"Re-enter your passcode", @"");
    
    [self.retryPasscodeView becomeFirstResponder];
    [self.retryPasscodeView reset];
}


#pragma mark - NSNotification

- (void) keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardRect;
    CGFloat duration = 0;
    UIViewAnimationCurve curve;
    
    [UIView frame:&keyboardRect animationDuration:&duration animationCurve:&curve fromKeyboardNotification:notification];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect buttonRect = self.touchIDButton.frame;
    buttonRect.origin.y -= keyboardRect.size.height;
    self.touchIDButton.frame = buttonRect;
    
    [UIView commitAnimations];
}

- (void) keyboardWillHide:(NSNotification *)notification {
    CGRect keyboardRect;
    CGFloat duration = 0;
    UIViewAnimationCurve curve;
    
    [UIView frame:&keyboardRect animationDuration:&duration animationCurve:&curve fromKeyboardNotification:notification];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect buttonRect = self.touchIDButton.frame;
    buttonRect.origin.y += keyboardRect.size.height;
    self.touchIDButton.frame = buttonRect;
    
    [UIView commitAnimations];
}


@end
