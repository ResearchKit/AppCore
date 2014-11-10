//
//  APCStudyDetailsViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCStudyDetailsViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

@interface APCStudyDetailsViewController ()

@end

@implementation APCStudyDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupAppearance];
    
    self.iconImageView.image = self.studyDetails.iconImage;
    self.title = self.studyDetails.caption;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup

- (void)setupAppearance
{
    [self.textView setTextColor:[UIColor appSecondaryColor1]];
    [self.textView setFont:[UIFont appLightFontWithSize:17.0f]];
}

@end
