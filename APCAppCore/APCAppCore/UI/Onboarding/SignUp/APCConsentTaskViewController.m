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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Required Protocol Methods for Abstract Class
-(void)taskViewControllerDidComplete:(RKSTTaskViewController *)taskViewController{
    
}

-(void)taskViewController:(RKSTTaskViewController *)taskViewController didFailOnStep:(RKSTStep *)step withError:(NSError *)error{
    
}

-(void)taskViewControllerDidCancel:(RKSTTaskViewController *)taskViewController{
    
}

@end
