//
//  APCDashboardTableViewCell.m
//  AppCore
//
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//

#import "APCDashboardTableViewCell.h"
#import "UIFont+APCAppearance.h"

static const CGFloat kTitleLabelHeight = 26.0f;

@implementation APCDashboardTableViewCell

@synthesize tintColor = _tintColor;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup
{
    self.titleLabel.font = [UIFont appRegularFontWithSize:19.0f];
    
    [self.infoButton setImage:[[UIImage imageNamed:@"info_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.infoButton setImage:[[UIImage imageNamed:@"info_icon_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    self.infoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.resizeButton setImage:[[UIImage imageNamed:@"expand_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.resizeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
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

- (IBAction)infoTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(dashboardTableViewCellDidTapMoreInfo:)]) {
        [self.delegate dashboardTableViewCellDidTapMoreInfo:self];
    }
}

- (IBAction)expandTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(dashboardTableViewCellDidTapExpand:)]) {
        [self.delegate dashboardTableViewCellDidTapExpand:self];
    }
}

@end
