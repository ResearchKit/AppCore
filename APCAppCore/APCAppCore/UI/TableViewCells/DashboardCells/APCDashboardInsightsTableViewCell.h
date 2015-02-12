//
//  APCDashboardInsightTableViewCell.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol APCDashboardInsightsTableViewCellDelegate;

@interface APCDashboardInsightsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *expandButton;

@property (nonatomic, weak) id <APCDashboardInsightsTableViewCellDelegate> delegate;

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) NSString *cellTitle;
@property (nonatomic, strong) NSString *cellSubtitle;

@end

@protocol APCDashboardInsightsTableViewCellDelegate <NSObject>

@required
- (void)dashboardInsightDidExpandForCell:(APCDashboardInsightsTableViewCell *)cell;

@end