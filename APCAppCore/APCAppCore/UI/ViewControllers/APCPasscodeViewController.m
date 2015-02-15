// 
//  APCPasscodeViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCPasscodeViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "UIAlertController+Helper.h"
#import "APCPasscodeView.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCKeychainStore.h"
#import "APCUserInfoConstants.h"
#import "UIImage+APCHelper.h"
#import "APCAppCore.h"

@interface APCPasscodeViewController ()<APCPasscodeViewDelegate>

@property (nonatomic, strong) LAContext *touchContext;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet APCPasscodeView *passcodeView;
@property (weak, nonatomic) IBOutlet UIButton *touchIdButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *touchIdButtonBottomConstraint;

@end

@implementation APCPasscodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.touchContext = [LAContext new];
    self.passcodeView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [self setupAppearance];
    
    if ([self.touchContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        self.passcodeView.alpha = 0;
        self.titleLabel.alpha = 0;
        self.touchIdButton.alpha = 0;
        self.titleLabel.text = NSLocalizedString(@"Touch ID or Enter Passcode", nil);
    } else {
        self.touchIdButton.hidden = YES;
        self.titleLabel.text = NSLocalizedString(@"Enter Passcode", nil);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

  APCLogViewControllerAppeared();
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self.touchContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        [self.passcodeView becomeFirstResponder];
    } else {
        self.passcodeView.alpha = 0;
        self.titleLabel.alpha = 0;
        self.touchIdButton.alpha = 0;
        [self promptTouchId];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark - Setup

- (void)setupAppearance
{
    [self.titleLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.titleLabel setFont:[UIFont appLightFontWithSize:19.0f]];
    
    [self.logoImageView setImage:[UIImage imageNamed:@"logo_disease"]];
}

#pragma mark - APCPasscodeViewDelegate

- (void) passcodeViewDidFinish:(APCPasscodeView *) __unused passcodeView withCode:(NSString *) __unused code {

    if (self.passcodeView.code.length > 0) {
        if ([self.passcodeView.code isEqualToString:[APCKeychainStore stringForKey:kAPCPasscodeKey]]) {
            //Authenticate
            if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidSucceed:)]) {
                [self.delegate passcodeViewControllerDidSucceed:self];
            }
        } else {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Wrong Passcode" message:@"Please enter again." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __unused action) {
                [self.passcodeView reset];
                [self.passcodeView becomeFirstResponder];
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

#pragma mark - IBActions

- (IBAction) useTouchId: (id) __unused sender
{
    [self promptTouchId];
}

- (void)promptTouchId
{
    NSError *error = nil;
    
    if ([self.touchContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        self.touchContext.localizedFallbackTitle = NSLocalizedString(@"Enter Passcode", @"");
        
        NSString *localizedReason = NSLocalizedString(@"Please authenticate with Touch ID", @"");
        
        typeof(self) __weak weakSelf = self;
        [self.touchContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                          localizedReason:localizedReason
                                    reply:^(BOOL success, NSError *error) {
                                        
                                        if (success) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if ([weakSelf.delegate respondsToSelector:@selector(passcodeViewControllerDidSucceed:)]) {
                                                    [weakSelf.delegate passcodeViewControllerDidSucceed:weakSelf];
                                                }
                                            });
                                            
                                        } else {
                                            if (error.code == kLAErrorUserFallback) {
                                                //Passcode
                                                
                                                
                                            } else if (error.code == kLAErrorUserCancel) {
                                                //cancel
                                            } else {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    
                                                    UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Authentication Error", @"") message:NSLocalizedString(@"Failed to authenticate.", @"")];
                                                    [self presentViewController:alert animated:YES completion:nil];
                                                });
                                            }
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                [UIView animateWithDuration:0.3 animations:^{
                                                    self.passcodeView.alpha = 1;
                                                    self.titleLabel.alpha = 1;
                                                    self.touchIdButton.alpha = 1;
                                                }];
                                                
                                                [self.passcodeView becomeFirstResponder];
                                            });
                                            
                                        }
                                    }];
    }
    
}
#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notifcation
{
    CGFloat keyboardHeight = [notifcation.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    double animationDuration = [notifcation.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.touchIdButtonBottomConstraint.constant = keyboardHeight + 15;
    }];
    
}

@end
