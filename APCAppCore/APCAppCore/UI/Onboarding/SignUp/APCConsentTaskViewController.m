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
-(void)taskViewControllerDidComplete:(ORKTaskViewController *)taskViewController{
    
}

-(void)taskViewController:(ORKTaskViewController *)taskViewController didFailOnStep:(ORKStep *)step withError:(NSError *)error{
    
}

-(void)taskViewControllerDidCancel:(ORKTaskViewController *)taskViewController{
    
}

@end
