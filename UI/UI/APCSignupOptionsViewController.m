//
//  OnBoardingOptionsViewController.m
//  OnBoarding
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSignInViewController.h"
#import "APCSignupOptionsViewController.h"
#import "APHSignUpGeneralInfoViewController.h"

@interface APCSignupOptionsViewController ()

@end

@implementation APCSignupOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"Sign In", @"");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBActions

- (IBAction) signUp {
    [self.navigationController pushViewController:[APHSignUpGeneralInfoViewController new] animated:YES];
}

- (IBAction) signIn {
    APCSignInViewController *signInViewController = [[APCSignInViewController alloc] initWithNibName:@"APCSignInViewController" bundle:nil];
    [self.navigationController pushViewController:signInViewController animated:YES];
}

@end
