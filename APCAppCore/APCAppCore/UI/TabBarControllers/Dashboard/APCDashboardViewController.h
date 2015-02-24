// 
//  APCDashboardViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import "APCTableViewItem.h"
#import "APCDashboardTableViewCell.h"
#import "APCDashboardLineGraphTableViewCell.h"
#import "APCDashboardMessageTableViewCell.h"
#import "APCDashboardProgressTableViewCell.h"
#import "APCDashboardInsightsTableViewCell.h"
#import "APCDashboardInsightTableViewCell.h"
#import "APCDashboardFoodInsightTableViewCell.h"
#import "APCGraph.h"

FOUNDATION_EXPORT NSInteger const kNumberOfDaysToDisplay;

typedef NS_ENUM(APCTableViewItemType, APCTableViewDashboardItemType) {
    kAPCTableViewDashboardItemTypeProgress,
    kAPCTableViewDashboardItemTypeGraph,
    kAPCTableViewDashboardItemTypeMessage,
};

@interface APCDashboardViewController : UITableViewController <APCBaseGraphViewDelegate, APCDashboardTableViewCellDelegate, APCDashboardInsightsTableViewCellDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;;

- (APCTableViewItem *)itemForIndexPath:(NSIndexPath *)indexPath;

- (APCTableViewItemType)itemTypeForIndexPath:(NSIndexPath *)indexPath;

//For overriding if necessary
- (void)updateVisibleRowsInTableView:(NSNotification *)notification;

@end
