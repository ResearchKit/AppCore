//
//  APCLearnMasterViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCTableViewItem.h"
#import "APCTintedTableViewCell.h"

@interface APCLearnMasterViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *items;

- (void)studyDetailsFromJSONFile:(NSString *)jsonFileName;

- (APCTableViewStudyDetailsItem *)itemForIndexPath:(NSIndexPath *)indexPath;

@end
