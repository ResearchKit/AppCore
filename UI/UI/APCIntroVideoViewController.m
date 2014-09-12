//
//  OnBoardingVideoViewController.m
//  OnBoarding
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "UIView+Category.h"
#import "APCIntroVideoViewController.h"
#import "APCSignupOptionsViewController.h"

@interface APCIntroVideoViewController ()

@end

@implementation APCIntroVideoViewController
//
//- (void) loadView {
//    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.view.backgroundColor = [UIColor whiteColor];
//}

- (instancetype) init {
    self = [super initWithContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"intro" ofType:@"m4v"]]];
    if (self) {
        self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    }
    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(self.view.innerWidth - 70, 10, 60, 44);
    [button setTitle:NSLocalizedString(@"Skip", @"") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(skip) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.moviePlayer play];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Private Methods

- (void) skip {
    APCSignupOptionsViewController *optionsViewController = [[APCSignupOptionsViewController alloc] initWithNibName:@"APCSignupOptionsViewController" bundle:nil];
    
    [self.navigationController pushViewController:optionsViewController animated:YES];
}

@end
