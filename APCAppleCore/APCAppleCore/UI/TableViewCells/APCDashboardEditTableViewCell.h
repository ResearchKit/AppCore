//
//  APCDashboardEditTableViewCell.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const kAPCDashboardEditTableViewCellIdentifier = @"APCDashboardEditTableViewCell";

@interface APCDashboardEditTableViewCell : UITableViewCell

@property (nonatomic, strong) UIColor *tintColor;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UIView *tintView;

@end
