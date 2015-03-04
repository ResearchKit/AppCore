// 
//  APCDashboardProgressTableViewCell.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCDashboardProgressTableViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

NSString * const kAPCDashboardProgressTableViewCellIdentifier = @"APCDashboardProgressTableViewCell";

@implementation APCDashboardProgressTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self setupAppearance];
}

- (void)setupAppearance
{
    self.progressView.progress = 0.0f;
    self.progressView.lineWidth = 4.0f;
    self.progressView.tintColor = [UIColor appTertiaryColor1];
    
    self.titleLabel.textColor = [UIColor appSecondaryColor1];
    
    self.subTitleLabel.font = [UIFont appRegularFontWithSize:15.0f];
    self.subTitleLabel.textColor = [UIColor appSecondaryColor2];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.progressView.progress == 0) {
        self.progressView.tintColor = [UIColor appSecondaryColor2];
    } else {
        self.progressView.tintColor = [UIColor appTertiaryColor1];
    }
}

@end
