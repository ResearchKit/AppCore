//
//  APCDashboardLineGraphTableViewCell.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCDashboardTableViewCell.h"

@class APCLineGraphView;
@class APCDiscreteGraphView;

FOUNDATION_EXPORT NSString * const kAPCDashboardGraphTableViewCellIdentifier;

@interface APCDashboardGraphTableViewCell : APCDashboardTableViewCell

@property (weak, nonatomic) IBOutlet APCLineGraphView *lineGraphView;
@property (weak, nonatomic) IBOutlet APCDiscreteGraphView *discreteGraphView;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *averageImageView;


@end
