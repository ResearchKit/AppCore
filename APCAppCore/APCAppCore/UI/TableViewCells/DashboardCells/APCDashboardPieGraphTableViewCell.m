// 
//  APCDashboardPieGraphTableViewCell.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCDashboardPieGraphTableViewCell.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+APCAppearance.h"

NSString * const kAPCDashboardPieGraphTableViewCellIdentifier = @"APCDashboardPieGraphTableViewCell";

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
    
    self.subTitleLabel3.font = [UIFont appRegularFontWithSize:16.0f];
    self.subTitleLabel3.textColor = [UIColor appSecondaryColor3];
}


@end
