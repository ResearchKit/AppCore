// 
//  APCDashboardEditTableViewCell.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const kAPCDashboardEditTableViewCellIdentifier;

@interface APCDashboardEditTableViewCell : UITableViewCell

@property (nonatomic, strong) UIColor *tintColor;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UIView *tintView;

@end
