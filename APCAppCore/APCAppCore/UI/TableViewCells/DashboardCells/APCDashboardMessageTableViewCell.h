// 
//  APCDashboardMessageTableViewCell.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCConstants.h"

FOUNDATION_EXPORT NSString * const kAPCDashboardMessageTableViewCellIdentifier;

@interface APCDashboardMessageTableViewCell : UITableViewCell

@property (nonatomic) APCDashboardMessageType type;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

