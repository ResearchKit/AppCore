// 
//  APCDashboardPieGraphTableViewCell.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCDashboardTableViewCell.h"

@class APCPieGraphView;

static NSString * const kAPCDashboardPieGraphTableViewCellIdentifier = @"APCDashboardPieGraphTableViewCell";

@interface APCDashboardPieGraphTableViewCell : APCDashboardTableViewCell

@property (weak, nonatomic) IBOutlet APCPieGraphView *pieGraphView;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel2
;

@end
