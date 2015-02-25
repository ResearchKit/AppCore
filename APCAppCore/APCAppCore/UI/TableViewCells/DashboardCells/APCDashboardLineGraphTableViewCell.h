// 
//  APCDashboardLineGraphTableViewCell.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCDashboardTableViewCell.h"

@class APCLineGraphView;

FOUNDATION_EXPORT NSString * const kAPCDashboardGraphTableViewCellIdentifier;

@interface APCDashboardLineGraphTableViewCell : APCDashboardTableViewCell

@property (weak, nonatomic) IBOutlet APCLineGraphView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *averageImageView;


@end
