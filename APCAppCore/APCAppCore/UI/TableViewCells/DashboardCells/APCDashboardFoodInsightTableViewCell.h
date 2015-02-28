//
//  APCDashboardFoodInsightTableViewCell.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCDashboardFoodInsightTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *foodName;
@property (nonatomic, strong) NSString *foodSubtitle;
@property (nonatomic, strong) NSNumber *foodFrequency;
@property (nonatomic, strong) UIImage *insightImage;

@property (nonatomic, strong) UIColor *tintColor;

@end
