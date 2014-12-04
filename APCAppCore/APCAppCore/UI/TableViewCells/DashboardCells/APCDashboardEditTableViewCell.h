// 
//  APCDashboardEditTableViewCell.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

static NSString *const kAPCDashboardEditTableViewCellIdentifier = @"APCDashboardEditTableViewCell";

@interface APCDashboardEditTableViewCell : UITableViewCell

@property (nonatomic, strong) UIColor *tintColor;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UIView *tintView;

@end
