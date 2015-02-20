// 
//  APCDashboardPieGraphTableViewCell.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCDashboardPieGraphTableViewCell.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"

@implementation APCDashboardPieGraphTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self setupAppearance];
}

- (void)setupAppearance
{
    self.subTitleLabel.font = [UIFont appRegularFontWithSize:16.0f];
    self.subTitleLabel.textColor = [UIColor appSecondaryColor3];
    
    self.subTitleLabel2.font = [UIFont appRegularFontWithSize:16.0f];
    self.subTitleLabel2.textColor = [UIColor appSecondaryColor3];
}


@end
