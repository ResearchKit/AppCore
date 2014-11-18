//
//  APCDashboardGraphTableViewCell.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kAPCDashboardGraphTableViewCellIdentifier = @"APCDashboardGraphTableViewCell";

@protocol APCDashboardGraphTableViewCellDelegate;

@interface APCDashboardGraphTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *graphContainerView;

@property (weak, nonatomic) id <APCDashboardGraphTableViewCellDelegate> delegate;

@end

@protocol APCDashboardGraphTableViewCellDelegate <NSObject>

@required

- (void)dashboardGraphViewCellDidTapExpandForCell:(APCDashboardGraphTableViewCell *)cell;

@end
