// 
//  APCLearnMasterViewController.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCTableViewItem.h"
#import "APCTintedTableViewCell.h"
#import <ResearchKit/ResearchKit.h>

@interface APCLearnMasterViewController : UITableViewController <ORKTaskViewControllerDelegate>

@property (nonatomic, strong) NSArray *items;

- (NSArray *)studyDetailsFromJSONFile:(NSString *)jsonFileName;

- (APCTableViewStudyDetailsItem *)itemForIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)prepareContent;

@end
