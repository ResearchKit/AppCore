// 
//  APCDashboardLineGraphTableViewCell.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCDashboardTableViewCell.h"

@class APCLineGraphView;

static NSString * const kAPCDashboardGraphTableViewCellIdentifier = @"APCDashboardLineGraphTableViewCell";

@protocol APCDashboardGraphTableViewCellDelegate;

@interface APCDashboardLineGraphTableViewCell : APCDashboardTableViewCell

@property (weak, nonatomic) IBOutlet APCLineGraphView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;


@end
