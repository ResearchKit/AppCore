//
//  APCDashboardMoreInfoViewController.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
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
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    [self.backgroundImageView addGestureRecognizer:tapRecognizer];
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
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.containerView.frame = CGRectMake(CGRectGetMinX(self.containerView.frame), CGRectGetMaxY(self.view.frame) - CGRectGetHeight(self.containerView.frame) - 20, CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame));
        
    } completion:^(BOOL __unused finished) {
        
    }];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.containerView.frame = CGRectMake(CGRectGetMinX(self.containerView.frame), CGRectGetMaxY(self.view.frame), CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame));
}

- (void)setupAppearance
{
    self.titleLabel.font = [UIFont appLightFontWithSize:24.0f];
    self.titleLabel.textColor = [UIColor appSecondaryColor1];
    
    self.textView.font = [UIFont appRegularFontWithSize:16.0f];
    self.textView.textColor = [UIColor appSecondaryColor1];
    
    self.containerView.layer.cornerRadius = 3.0;
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.layer.shadowOffset = CGSizeMake(0, 4);
    self.containerView.layer.masksToBounds = NO;
    self.containerView.layer.shadowRadius = 10;
    self.containerView.layer.shadowOpacity = 0.2;
}

- (IBAction) dismiss: (id) __unused sender
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.containerView.center = CGPointMake(self.containerView.center.x, CGRectGetHeight(self.view.bounds)*1.5 - CGRectGetHeight(self.containerView.bounds)/2);
    } completion:^(BOOL __unused finished) {
    
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewTapped
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.containerView.center = CGPointMake(self.containerView.center.x, CGRectGetHeight(self.view.bounds)*1.5 - CGRectGetHeight(self.containerView.bounds)/2);
    } completion:^(BOOL __unused finished) {
        
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
