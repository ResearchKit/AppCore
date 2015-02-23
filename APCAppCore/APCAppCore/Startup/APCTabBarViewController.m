//
//  APCTabBarViewController.m
//  APCAppCore
//
//  Created by Dhanush Balachandran on 2/23/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCTabBarViewController.h"
#import "APCAppCore.h"

@interface APCTabBarViewController () <APCPasscodeViewControllerDelegate>
@property (nonatomic) BOOL isPasscodeShowing;
@end

@implementation APCTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    APCLogDebug(@"View Did load");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    APCLogDebug(@"self.presentedVC: %@", self.presentedViewController);
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    APCLogDebug(@"self.presentedVC: %@", self.presentedViewController);
    if (self.showPasscodeScreen) {
        self.showPasscodeScreen = NO;
        [self showPasscode];
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
    [viewController dismissViewControllerAnimated:YES completion:nil];
    self.isPasscodeShowing = NO;
}

@end
