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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.touchContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        self.touchIdButton.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.passcodeView becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark - Setup

- (void)setupAppearance
{
    [self.titleLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.titleLabel setFont:[UIFont appLightFontWithSize:19.0f]];
    
    [self.logoImageView setImage:[UIImage imageNamed:@"logo_disease"]];
    
    [self.touchIdButton setBackgroundImage:[UIImage imageWithColor:[UIColor appPrimaryColor]] forState:UIControlStateNormal];
}

#pragma mark - APCPasscodeViewDelegate

- (void) passcodeViewDidFinish:(APCPasscodeView *)passcodeView withCode:(NSString *)code {

    if (self.passcodeView.code.length > 0) {
        if ([self.passcodeView.code isEqualToString:[APCKeychainStore stringForKey:kAPCPasscodeKey]]) {
            //Authenticate
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Wrong Passcode" message:@"Please enter again." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.passcodeView reset];
                [self.passcodeView becomeFirstResponder];
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

#pragma mark - IBActions

- (IBAction)useTouchId:(id)sender
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
                                                [weakSelf dismissViewControllerAnimated:YES completion:nil];
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
        self.touchIdButtonBottomConstraint.constant = keyboardHeight;
    }];
    
}

@end
