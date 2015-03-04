// 
//  APCDashboardLineGraphTableViewCell.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCDashboardGraphTableViewCell.h"
#import "APCLineGraphView.h"
#import "APCDiscreteGraphView.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"

NSString * const kAPCDashboardGraphTableViewCellIdentifier = @"APCDashboardLineGraphTableViewCell";

@implementation APCDashboardGraphTableViewCell

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
    self.lineGraphView.tintColor = tintColor;
    self.discreteGraphView.tintColor = tintColor;
}

@end
