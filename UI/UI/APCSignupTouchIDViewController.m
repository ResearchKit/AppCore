//
//  APCSignupTouchIDViewController.m
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCStepProgressBar.h"
#import "APCSignupTouchIDViewController.h"
#import "APCSignupCriteriaViewController.h"

@interface APCSignupTouchIDViewController ()

@end

@implementation APCSignupTouchIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNavigationItems];
    [self setupProgressBar];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:2 animation:YES];
}

- (void) addNavigationItems {
    self.title = NSLocalizedString(@"Sign Up", @"");
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
}

- (void) setupProgressBar {
    [self.stepProgressBar setCompletedSteps:1 animation:NO];
    [self setStepNumber:3 title:NSLocalizedString(@"Identification", @"")];
}


#pragma mark - Private Methods

- (void) next {
    [self.navigationController pushViewController:[APCSignupCriteriaViewController new] animated:YES];
}


@end
