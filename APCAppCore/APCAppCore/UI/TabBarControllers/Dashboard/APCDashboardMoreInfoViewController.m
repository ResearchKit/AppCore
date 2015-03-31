// 
//  APCDashboardMoreInfoViewController.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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
