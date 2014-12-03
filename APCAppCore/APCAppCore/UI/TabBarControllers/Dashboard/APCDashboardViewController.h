//
//  APCDashboardViewController.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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

@end
