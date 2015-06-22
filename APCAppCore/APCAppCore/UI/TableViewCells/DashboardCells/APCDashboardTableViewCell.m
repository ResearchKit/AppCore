// 
//  APCDashboardTableViewCell.m 
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
 
#import "APCDashboardTableViewCell.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"

static const CGFloat kTitleLabelHeight = 26.0f;

@implementation APCDashboardTableViewCell

@synthesize tintColor = _tintColor;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup
{
    self.titleLabel.font = [UIFont appRegularFontWithSize:19.0f];
    
    [self.infoButton setImage:[[UIImage imageNamed:@"info_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.infoButton setImage:[[UIImage imageNamed:@"info_icon_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    self.infoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.infoButton.imageView.tintColor = [UIColor appSecondaryColor1];
    
    [self.resizeButton setImage:[[UIImage imageNamed:@"expand_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.resizeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.resizeButton.imageView.tintColor = [UIColor appSecondaryColor1];
}

#pragma mark - Setter methods

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    self.tintView.backgroundColor = tintColor;
    self.titleLabel.textColor = tintColor;
    self.resizeButton.imageView.tintColor = tintColor;
    self.infoButton.imageView.tintColor = tintColor;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
    
    CGSize textSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(320, kTitleLabelHeight) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size;
    self.titleLabelWidthConstraint.constant = textSize.width + 1;
    
    [self setNeedsLayout];
}
#pragma mark - IBActions

- (IBAction)infoTapped:(id) __unused sender
{
    if ([self.delegate respondsToSelector:@selector(dashboardTableViewCellDidTapMoreInfo:)]) {
        [self.delegate dashboardTableViewCellDidTapMoreInfo:self];
    }
}

- (IBAction)expandTapped:(id) __unused sender
{
    if ([self.delegate respondsToSelector:@selector(dashboardTableViewCellDidTapExpand:)]) {
        [self.delegate dashboardTableViewCellDidTapExpand:self];
    }
}

- (IBAction)legendLabelTapped:(id)__unused sender
{
    
    if ([self.delegate respondsToSelector:@selector(dashboardTableViewCellDidTapLegendTitle:)]) {
        [self.delegate dashboardTableViewCellDidTapLegendTitle:self];
    }
}

@end
