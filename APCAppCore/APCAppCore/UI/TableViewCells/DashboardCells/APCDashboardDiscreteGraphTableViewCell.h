//
//  APCDashboardDiscreteGraphTableViewCell.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCDashboardTableViewCell.h"

@class  APCDiscreteGraphView;

FOUNDATION_EXPORT NSString * const kAPCDashboardDiscreteGraphTableViewCellIdentifier;

@interface APCDashboardDiscreteGraphTableViewCell : APCDashboardTableViewCell

@property (weak, nonatomic) IBOutlet APCDiscreteGraphView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *averageImageView;

@end
