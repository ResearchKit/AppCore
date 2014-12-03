// 
//  APCDashboardProgressTableViewCell.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCCircularProgressView.h"

static NSString * const kAPCDashboardProgressTableViewCellIdentifier = @"APCDashboardProgressTableViewCell";

@interface APCDashboardProgressTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet APCCircularProgressView *progressView;

@end
