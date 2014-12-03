//
//  APCDashboardPieGraphTableViewCell.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 11/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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
