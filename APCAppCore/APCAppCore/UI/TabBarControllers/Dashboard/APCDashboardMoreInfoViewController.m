//
//  APCDashboardMoreInfoViewController.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCDashboardMoreInfoViewController.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"

@interface APCDashboardMoreInfoViewController ()


@end

@implementation APCDashboardMoreInfoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupAppearance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.titleLabel.text = self.titleString;
    self.textView.text = self.info;
    self.backgroundImageView.image = self.blurredImage;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:2 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.containerView.center = CGPointMake(self.containerView.center.x, CGRectGetMidY(self.view.bounds));
    } completion:^(BOOL finished) {
        
    }];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.containerView.center = CGPointMake(self.containerView.center.x, CGRectGetHeight(self.view.bounds)*1.5);
}

- (void)setupAppearance
{
    self.titleLabel.font = [UIFont appLightFontWithSize:24.0f];
    self.titleLabel.textColor = [UIColor appSecondaryColor1];
    
    self.textView.font = [UIFont appRegularFontWithSize:16.0f];
    self.textView.textColor = [UIColor appSecondaryColor1];
    
    self.containerView.layer.cornerRadius = 5.0;
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.layer.shadowOffset = CGSizeMake(0, 4);
    self.containerView.layer.masksToBounds = NO;
    self.containerView.layer.shadowRadius = 10;
    self.containerView.layer.shadowOpacity = 0.4;
}

- (IBAction)dismiss:(id)sender
{
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.containerView.center = CGPointMake(self.containerView.center.x, CGRectGetHeight(self.view.bounds)*1.5 - CGRectGetHeight(self.containerView.bounds)/2);
    } completion:^(BOOL finished) {
    
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
