// 
//  APCDashboardLineGraphTableViewCell.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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
