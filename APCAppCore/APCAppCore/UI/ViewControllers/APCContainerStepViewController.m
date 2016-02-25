//
//  APCContainerStepViewController.m
//  APCAppCore
//
//  Created by Shannon Young on 2/23/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

#import "APCContainerStepViewController.h"

@implementation APCContainerStepViewController

- (instancetype)initWithStep:(ORKStep *)step childViewController:(UIViewController*)childViewController {
    self = [super initWithStep:step];
    if (self) {
        _childViewController = childViewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Load the child view controller
    [self addChildViewController:self.childViewController];
    self.childViewController.view.frame = self.view.bounds;
    self.childViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.childViewController.view];
    [self.childViewController didMoveToParentViewController:self];
}

- (ORKStepResult *)result {
    ORKStepResult *parentResult = [super result];
    parentResult.results = self.childResults;
    return parentResult;
}

@end
