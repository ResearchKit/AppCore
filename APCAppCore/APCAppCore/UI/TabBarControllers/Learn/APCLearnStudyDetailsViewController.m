//
//  APCLearnStudyDetailsViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/30/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCLearnStudyDetailsViewController.h"
#import "UIColor+APCAppearance.h"

@interface APCLearnStudyDetailsViewController ()

@end

@implementation APCLearnStudyDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavAppearance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setupNavAppearance
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 44, 44);
    [backButton setImage:[[UIImage imageNamed:@"back_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    backButton.tintColor = [UIColor appPrimaryColor];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButton];
}

#pragma mark - Selectors / IBActions

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
