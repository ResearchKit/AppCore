// 
//  APCStepViewController.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCStepViewController.h"
#import "APCAppCore.h"

@interface APCStepViewController ()

@end

@implementation APCStepViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  APCLogViewControllerAppeared();
}

@end
