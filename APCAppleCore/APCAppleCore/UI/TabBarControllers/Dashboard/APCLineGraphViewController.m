//
//  APCLineGraphViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/16/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCLineGraphViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "UIImage+APCHelper.h"

@interface APCLineGraphViewController ()

@end

@implementation APCLineGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.graphView.tintColor = self.graphItem.tintColor;
    self.graphView.titleLabel.text = self.graphItem.caption;
    self.graphView.subTitleLabel.text = self.graphItem.detailText;
    self.graphView.datasource = self.graphItem.graphData;
    self.graphView.landscapeMode = YES;
    
    [self setupAppearance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Appearance

- (void)setupAppearance
{
    self.segmentedControl.tintColor = [UIColor clearColor];
    [self.segmentedControl setTitleTextAttributes:@{NSFontAttributeName:[UIFont appRegularFontWithSize:19.0f], NSForegroundColorAttributeName : [UIColor appSecondaryColor2]} forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:@{NSFontAttributeName:[UIFont appMediumFontWithSize:19.0f], NSForegroundColorAttributeName : [UIColor appSecondaryColor1]} forState:UIControlStateSelected];
    
    self.compareSwitch.onTintColor = self.graphItem.tintColor;
    
    [self.compareLabel setFont:[UIFont appLightFontWithSize:16.0f]];
    [self.compareLabel setTextColor:[UIColor appSecondaryColor2]];
    
    self.graphView.titleLabel.font = [UIFont appRegularFontWithSize:24.0f];
    self.graphView.subTitleLabel.font = [UIFont appRegularFontWithSize:16.0f];
    
    [self.collapseButton setImage:[[UIImage imageNamed:@"collapse_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.collapseButton.imageView setTintColor:self.graphItem.tintColor];
}

#pragma mark - Orientation methods

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

- (IBAction)collapse:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
