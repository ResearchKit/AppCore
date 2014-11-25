//
//  APCDashboardBadgesTableViewCell.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kAPCDashboardBadgesTableViewCellIdentifier = @"APCDashboardBadgesTableViewCell";

@class APCConcentricProgressView;

@interface APCDashboardBadgesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *tintView;

@property (weak, nonatomic) IBOutlet APCConcentricProgressView *concentricProgressView;

@property (nonatomic, strong) UIColor *tintColor;

@property (weak, nonatomic) IBOutlet UILabel *participationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *participationImageView;
@property (weak, nonatomic) IBOutlet UILabel *participationPercentLabel;

@property (weak, nonatomic) IBOutlet UILabel *attendanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *attendanceImageView;
@property (weak, nonatomic) IBOutlet UILabel *attendancePercentLabel;

@property (weak, nonatomic) IBOutlet UILabel *undisturbedNightLabel;
@property (weak, nonatomic) IBOutlet UIImageView *undisturbedNightsImageView;
@property (weak, nonatomic) IBOutlet UILabel *undisturbedPercentLabel;

@property (weak, nonatomic) IBOutlet UILabel *asthmaFreeDaysLabel;
@property (weak, nonatomic) IBOutlet UIImageView *asthmaFreeDaysImageView;
@property (weak, nonatomic) IBOutlet UILabel *AsthmaFreePercentLabel;

@end