//
//  OnBoardingOptionsViewController.m
//  OnBoarding
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCOnBoardingOptionsViewController.h"
#import "APCSignUpGeneralInfoViewController.h"

@interface APCOnBoardingOptionsViewController ()

@end

@implementation APCOnBoardingOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBActions

- (IBAction) signUp {
    [self.navigationController pushViewController:[APCSignUpGeneralInfoViewController new] animated:YES];
}

- (IBAction) signIn {
    
}

@end
