//
//  APCTabBarViewController.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//


#import "APCTabBarViewController.h"
#import "APCAppCore.h"

@interface APCTabBarViewController () <APCPasscodeViewControllerDelegate>
@property (nonatomic) BOOL isPasscodeShowing;
@end

@implementation APCTabBarViewController

- (void)setShowPasscodeScreen:(BOOL)showPasscodeScreen
{
    _showPasscodeScreen = showPasscodeScreen;
    if (showPasscodeScreen) {
        [self performSelector:@selector(showPasscode) withObject:nil afterDelay:0.4];
    }
}

- (void)showPasscode
{
    if (!self.isPasscodeShowing) {
        APCPasscodeViewController *passcodeViewController = [[UIStoryboard storyboardWithName:@"APCPasscode" bundle:[NSBundle appleCoreBundle]] instantiateInitialViewController];
        passcodeViewController.delegate = self;
        UIViewController * presentVC = self.presentedViewController ? self.presentedViewController : self;
        [presentVC presentViewController:passcodeViewController animated:YES completion:nil];
        self.isPasscodeShowing = YES;
    }
}

- (void)passcodeViewControllerDidSucceed:(APCPasscodeViewController *)viewController
{
    self.isPasscodeShowing = NO;
    self.showPasscodeScreen = NO;
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
