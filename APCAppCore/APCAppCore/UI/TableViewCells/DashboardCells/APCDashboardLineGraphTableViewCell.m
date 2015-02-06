// 
//  APCDashboardLineGraphTableViewCell.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCDashboardLineGraphTableViewCell.h"
#import "APCLineGraphView.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"

@implementation APCDashboardLineGraphTableViewCell

@synthesize tintColor = _tintColor;

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.subTitleLabel.font = [UIFont appRegularFontWithSize:16.0f];
    self.subTitleLabel.textColor = [UIColor appSecondaryColor3];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    for (UIView *subview in self.subviews) {
        [subview layoutSubviews];
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    self.graphView.tintColor = tintColor;
}

@end
