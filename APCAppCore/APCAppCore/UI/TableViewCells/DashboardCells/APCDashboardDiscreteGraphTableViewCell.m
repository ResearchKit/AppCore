//
//  APCDashboardDiscreteGraphTableViewCell.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCDashboardDiscreteGraphTableViewCell.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"
#import "APCDiscreteGraphView.h"

NSString * const kAPCDashboardDiscreteGraphTableViewCellIdentifier = @"APCDashboardDiscreteGraphTableViewCell";

@implementation APCDashboardDiscreteGraphTableViewCell

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
