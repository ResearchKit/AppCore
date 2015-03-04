// 
//  APCDashboardPieGraphTableViewCell.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCDashboardTableViewCell.h"

@class APCPieGraphView;

FOUNDATION_EXPORT NSString * const kAPCDashboardPieGraphTableViewCellIdentifier;

@interface APCDashboardPieGraphTableViewCell : APCDashboardTableViewCell

@property (weak, nonatomic) IBOutlet APCPieGraphView *pieGraphView;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel2
;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel3;

@end
