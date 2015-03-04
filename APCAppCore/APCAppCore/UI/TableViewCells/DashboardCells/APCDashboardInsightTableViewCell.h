//
//  APCDashboardInsightTableViewCell.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCDashboardInsightTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *goodInsightCaption;
@property (nonatomic, strong) NSString *badInsightCaption;
@property (nonatomic, strong) NSNumber *goodInsightBar;
@property (nonatomic, strong) NSNumber *badInsightBar;
@property (nonatomic, strong) UIImage *insightImage;

@property (nonatomic, strong) UIColor *tintColor;

@end
