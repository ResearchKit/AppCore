// 
//  APCDashboardPieGraphTableViewCell.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
@class APCPieGraphView;

static NSString * const kAPCDashboardPieGraphTableViewCellIdentifier = @"APCDashboardPieGraphTableViewCell";

@interface APCDashboardPieGraphTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *tintView;
@property (weak, nonatomic) IBOutlet APCPieGraphView *pieGraphView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) UIColor *tintColor;

@end
