// 
//  APCSpinnerViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "UIColor+APCAppearance.h"
#import "NSBundle+Helper.h"
#import "APCSpinnerViewController.h"

@implementation APCSpinnerViewController

- (instancetype) init {
    return [self initWithNibName:@"APCSpinnerViewController" bundle:[NSBundle appleCoreBundle]];
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.activityIndicatorView stopAnimating];
}

@end
