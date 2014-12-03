//
//  APCDashboardBadgesTableViewCell.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDashboardBadgesTableViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

@implementation APCDashboardBadgesTableViewCell

@synthesize tintColor = _tintColor;

- (void)awakeFromNib {
    // Initialization code
    
    [self setupAppearance];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupAppearance
{
    [self.titleLabel setTextColor:[UIColor appTertiaryBlueColor]];
    [self.titleLabel setFont:[UIFont appRegularFontWithSize:19.0f]];
    
    [self.participationLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.participationLabel setFont:[UIFont appLightFontWithSize:16.0f]];
    [self.participationPercentLabel setTextColor:[UIColor appTertiaryBlueColor]];
    [self.participationPercentLabel setFont:[UIFont appRegularFontWithSize:19.0f]];
    
    [self.attendanceLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.attendanceLabel setFont:[UIFont appLightFontWithSize:16.0f]];
    [self.attendancePercentLabel setTextColor:[UIColor appTertiaryPurpleColor]];
    [self.attendancePercentLabel setFont:[UIFont appRegularFontWithSize:19.0f]];
    
    [self.undisturbedNightLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.undisturbedNightLabel setFont:[UIFont appLightFontWithSize:16.0f]];
    [self.undisturbedPercentLabel setTextColor:[UIColor appTertiaryGreenColor]];
    [self.undisturbedPercentLabel setFont:[UIFont appRegularFontWithSize:19.0f]];
    
    [self.asthmaFreeDaysLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.asthmaFreeDaysLabel setFont:[UIFont appLightFontWithSize:16.0f]];
    [self.asthmaFreePercentLabel setTextColor:[UIColor appTertiaryYellowColor]];
    [self.asthmaFreePercentLabel setFont:[UIFont appRegularFontWithSize:19.0f]];
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    [self.tintView setBackgroundColor:tintColor];
    self.titleLabel.textColor = tintColor;
}


@end
