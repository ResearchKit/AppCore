//
//  APCDashboardProgressTableViewCell.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCCircularProgressView.h"

static NSString * const kAPCDashboardProgressTableViewCellIdentifier = @"APCDashboardProgressTableViewCell";

@interface APCDashboardProgressTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet APCCircularProgressView *progressView;

@end
