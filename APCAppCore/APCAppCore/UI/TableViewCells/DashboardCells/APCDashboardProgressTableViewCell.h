// 
//  APCDashboardProgressTableViewCell.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCCircularProgressView.h"
#import "APCDashboardTableViewCell.h"

FOUNDATION_EXPORT NSString * const kAPCDashboardProgressTableViewCellIdentifier;

@interface APCDashboardProgressTableViewCell : APCDashboardTableViewCell

@property (weak, nonatomic) IBOutlet APCCircularProgressView *progressView;

@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@end
