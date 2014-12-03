//
//  APCStudyOverviewViewController.h
//  APCAppCore
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
@property (weak, nonatomic) IBOutlet UIImageView *diseaseLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *researchInstituteImageView;

@property (strong, nonatomic) NSString *diseaseName;

@property (nonatomic, strong) NSArray *items;

@property (nonatomic) BOOL showShareRow;

@property (nonatomic) BOOL showConsentRow;

- (IBAction)signInTapped:(id)sender;
- (IBAction)signUpTapped:(id)sender;

- (NSArray *)prepareContent;
- (NSArray *)studyDetailsFromJSONFile:(NSString *)jsonFileName;

- (APCTableViewStudyDetailsItem *)itemForIndexPath:(NSIndexPath *)indexPath;
- (APCTableViewStudyItemType)itemTypeForIndexPath:(NSIndexPath *)indexPath;

@end
