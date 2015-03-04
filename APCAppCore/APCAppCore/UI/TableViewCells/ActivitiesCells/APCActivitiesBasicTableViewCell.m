//
//  APCActivitiesBasicTableViewCell.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCActivitiesBasicTableViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

NSString * const kAPCActivitiesBasicTableViewCellIdentifier = @"APCActivitiesBasicTableViewCell";

@implementation APCActivitiesBasicTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self setupAppearance];
}

- (void)setupAppearance
{
    self.titleLabel.textColor = [UIColor appSecondaryColor1];
    self.titleLabel.font = [UIFont appRegularFontWithSize:16.f];
}

@end
