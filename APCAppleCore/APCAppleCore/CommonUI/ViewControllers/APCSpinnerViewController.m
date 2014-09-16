//
//  APCSpinnerView.m
//  UI
//
//  Created by Karthik Keyan on 9/8/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "UIView+Category.h"
#import "UIColor+Category.h"
#import "NSBundle+Category.h"
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
