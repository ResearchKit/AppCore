// 
//  APCDashboardEditViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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
