//
//  OnBoardingVideoViewController.m
//  OnBoarding
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCOnBoardingVideoViewController.h"
#import "APCOnBoardingOptionsViewController.h"

@interface APCOnBoardingVideoViewController ()

@end

@implementation APCOnBoardingVideoViewController

- (void) loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *skipBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Skip", @"") style:UIBarButtonItemStylePlain target:self action:@selector(skip)];
    self.navigationItem.rightBarButtonItem = skipBarButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods

- (void) skip {
    APCOnBoardingOptionsViewController *optionsViewController = [[APCOnBoardingOptionsViewController alloc] initWithNibName:@"OnBoardingOptionsViewController" bundle:nil];
    
    [self.navigationController pushViewController:optionsViewController animated:YES];
}

@end
