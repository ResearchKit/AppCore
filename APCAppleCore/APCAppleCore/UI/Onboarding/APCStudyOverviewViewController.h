//
//  APCStudyOverviewViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 9/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCTableViewItem.h"
#import "APCTintedTableViewCell.h"

@interface APCStudyOverviewViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *diseaseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (strong, nonatomic) NSString *diseaseName;

@property (nonatomic, strong) NSMutableArray *items;

- (IBAction)signInTapped:(id)sender;
- (IBAction)signUpTapped:(id)sender;

- (void)studyDetailsFromJSONFile:(NSString *)jsonFileName;

- (APCTableViewStudyDetailsItem *)itemForIndexPath:(NSIndexPath *)indexPath;
- (APCTableViewStudyItemType)itemTypeForIndexPath:(NSIndexPath *)indexPath;

@end
