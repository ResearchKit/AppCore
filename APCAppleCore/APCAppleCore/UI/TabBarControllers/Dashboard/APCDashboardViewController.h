//
//  APCDashboardViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCTableViewItem.h"
#import "APCDashboardGraphTableViewCell.h"
#import "APCDashboardMessageTableViewCell.h"
#import "APCDashboardProgressTableViewCell.h"
#import "APCGraph.h"

typedef NS_ENUM(APCTableViewItemType, APCTableViewDashboardItemType) {
    kAPCTableViewDashboardItemTypeProgress,
    kAPCTableViewDashboardItemTypeGraph,
    kAPCTableViewDashboardItemTypeMessage,
};

@interface APCDashboardViewController : UITableViewController <APCLineGraphViewDelegate>

@property (nonatomic, strong) NSMutableArray *items;

- (APCTableViewItem *)itemForIndexPath:(NSIndexPath *)indexPath;

- (APCTableViewItemType)itemTypeForIndexPath:(NSIndexPath *)indexPath;

@end
