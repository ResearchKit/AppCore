//
//  APCDashboardPieGraphTableViewCell.m
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 11/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDashboardPieGraphTableViewCell.h"
#import "UIFont+APCAppearance.h"

@implementation APCDashboardPieGraphTableViewCell

@synthesize tintColor = _tintColor;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupAppearance];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupAppearance
{
    self.titleLabel.font = [UIFont appRegularFontWithSize:19.0f];
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    self.tintView.backgroundColor = tintColor;
    self.titleLabel.textColor = tintColor;
}

@end
