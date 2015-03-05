//
//  APCConsentTaskViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCConsentTaskViewController.h"

@interface APCConsentTaskViewController ()

@end

@implementation APCConsentTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)taskViewController:(ORKTaskViewController *) __unused taskViewController stepViewControllerWillAppear:(ORKStepViewController *) __unused stepViewController
{
    
}

#pragma mark Required Protocol Methods for Abstract Class
- (void)taskViewController:(ORKTaskViewController *) __unused taskViewController didFinishWithResult:(ORKTaskViewControllerResult) __unused result error:(NSError *) __unused error
{
    
}

- (BOOL)taskViewController:(ORKTaskViewController *) __unused taskViewController shouldPresentStep:(ORKStep *) __unused step {
    return YES;
}

@end
