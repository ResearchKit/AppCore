//
//  APCDashboardInsightSummaryTableViewCell.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCDashboardInsightSummaryTableViewCell : UITableViewCell

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *sidebarColor;
@property (nonatomic, strong) NSString *summaryCaption;
@property (nonatomic) BOOL showTopSeparator;

@end
