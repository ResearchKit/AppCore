//
//  APCDashboardInsightTableViewCell.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCDashboardInsightTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *goodInsightCaption;
@property (nonatomic, strong) NSString *badInsightCaption;
@property (nonatomic, strong) NSNumber *goodInsightBar;
@property (nonatomic, strong) NSNumber *badInsightBar;
@property (nonatomic, strong) UIImage *insightImage;

@end
