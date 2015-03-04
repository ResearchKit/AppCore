//
//  APCActivitiesSectionHeaderView.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCActivitiesSectionHeaderView.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

NSString * const kAPCActivitiesSectionHeaderViewIdentifier = @"APCActivitiesSectionHeaderView";

@implementation APCActivitiesSectionHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupAppearance];
}

- (void)setupAppearance
{
    self.titleLabel.textColor = [UIColor appSecondaryColor2];
    self.titleLabel.font = [UIFont appRegularFontWithSize:16.f];
    
    self.subTitleLabel.textColor = [UIColor appSecondaryColor2];
    self.subTitleLabel.font = [UIFont appRegularFontWithSize:14.f];
    
    self.contentView.backgroundColor = [UIColor colorWithWhite:248/255.0 alpha:1.0];
}

@end
