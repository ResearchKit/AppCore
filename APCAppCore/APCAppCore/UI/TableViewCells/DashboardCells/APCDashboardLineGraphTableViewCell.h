//
//  APCDashboardGraphTableViewCell.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class APCLineGraphView;

static NSString * const kAPCDashboardGraphTableViewCellIdentifier = @"APCDashboardLineGraphTableViewCell";

@protocol APCDashboardGraphTableViewCellDelegate;

@interface APCDashboardLineGraphTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet APCLineGraphView *graphView;

@property (weak, nonatomic) IBOutlet UIButton *resizeButton;

@property (strong, nonatomic) UIColor *tintColor;

@property (weak, nonatomic) id <APCDashboardGraphTableViewCellDelegate> delegate;

@end

@protocol APCDashboardGraphTableViewCellDelegate <NSObject>

@required

- (void)dashboardGraphViewCellDidTapExpandForCell:(APCDashboardLineGraphTableViewCell *)cell;

@end
