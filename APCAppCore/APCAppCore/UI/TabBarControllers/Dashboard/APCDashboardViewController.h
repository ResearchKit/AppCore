// 
//  APCDashboardViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCTableViewItem.h"
#import "APCDashboardLineGraphTableViewCell.h"
#import "APCDashboardMessageTableViewCell.h"
#import "APCDashboardProgressTableViewCell.h"
#import "APCDashboardBadgesTableViewCell.h"
#import "APCGraph.h"

typedef NS_ENUM(APCTableViewItemType, APCTableViewDashboardItemType) {
    kAPCTableViewDashboardItemTypeProgress,
    kAPCTableViewDashboardItemTypeGraph,
    kAPCTableViewDashboardItemTypeMessage,
};

@interface APCDashboardViewController : UITableViewController <APCLineGraphViewDelegate, APCDashboardGraphTableViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *items;

- (APCTableViewItem *)itemForIndexPath:(NSIndexPath *)indexPath;

- (APCTableViewItemType)itemTypeForIndexPath:(NSIndexPath *)indexPath;

//For overriding if necessary
- (void)updateVisibleRowsInTableView:(NSNotification *)notification;

@end
