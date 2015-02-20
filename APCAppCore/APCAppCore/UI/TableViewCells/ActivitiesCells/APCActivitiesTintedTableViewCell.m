//
//  APCActivitiesTintedTableViewCell.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCActivitiesTintedTableViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

NSString * const kAPCActivitiesTintedTableViewCellIdentifier = @"APCActivitiesTintedTableViewCell";

static CGFloat const kTitleLabelCenterYConstant = 10.5f;

@implementation APCActivitiesTintedTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self setupAppearance];
    
    self.hidesSubTitle = NO;
}

- (void)setupAppearance
{
    self.titleLabel.textColor = [UIColor appSecondaryColor1];
    self.titleLabel.font = [UIFont appRegularFontWithSize:16.f];
    
    self.subTitleLabel.textColor = [UIColor appSecondaryColor3];
    self.subTitleLabel.font = [UIFont appRegularFontWithSize:14.f];
    
    self.countLabel.text = @"";
}

- (void)setHidesSubTitle:(BOOL)hidesSubTitle
{
    _hidesSubTitle = hidesSubTitle;
    
    self.subTitleLabel.hidden = hidesSubTitle;
    
    if (hidesSubTitle) {
        self.titleLabelCenterYConstraint.constant = 0;
    } else {
        self.titleLabelCenterYConstraint.constant = kTitleLabelCenterYConstant;
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    self.tintView.backgroundColor = tintColor;
}

- (void)setupIncompleteAppearance
{
    self.titleLabel.textColor = [UIColor appSecondaryColor3];
    
    self.subTitleLabel.textColor = [UIColor appSecondaryColor3];
    
    self.countLabel.hidden = YES;
    
    self.tintView.backgroundColor = [UIColor appTertiaryGrayColor];
    
}

@end
