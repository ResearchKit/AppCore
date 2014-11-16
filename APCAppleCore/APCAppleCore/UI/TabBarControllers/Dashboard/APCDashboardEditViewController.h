//
//  APCDashboardEditViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCTableViewItem.h"
#import "APCDashboardEditTableViewCell.h"

static NSString * const kAPCDashboardRowItemsOrder = @"DashboardRowItemsOrder";

@interface APCDashboardEditViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) NSMutableArray *rowItemsOrder;

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@end
