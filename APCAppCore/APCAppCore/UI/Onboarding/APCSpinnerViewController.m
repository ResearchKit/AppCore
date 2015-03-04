// 
//  APCSpinnerViewController.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "UIColor+APCAppearance.h"
#import "NSBundle+Helper.h"
#import "APCSpinnerViewController.h"
#import "APCAppCore.h"

@implementation APCSpinnerViewController

- (instancetype) init {
    return [self initWithNibName:@"APCSpinnerViewController" bundle:[NSBundle appleCoreBundle]];
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _landscape = NO;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.activityIndicatorContainerView.layer.cornerRadius = 8.0;
    self.activityIndicatorContainerView.layer.masksToBounds = YES;
    
    self.view.opaque = NO;
    self.view.backgroundColor = [UIColor clearColor];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.activityIndicatorView startAnimating];

	APCLogViewControllerAppeared();
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - Orientation methods

- (BOOL)shouldAutorotate
{
    return !self.landscape;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.landscape ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.landscape ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait;
}

@end
