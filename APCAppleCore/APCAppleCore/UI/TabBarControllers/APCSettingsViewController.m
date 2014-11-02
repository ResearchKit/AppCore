//
//  APCSettingsViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/1/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSettingsViewController.h"
#import "APCAppDelegate.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

static NSString *const kAPCRightDetailCellIdentifier = @"APCRightDetailCellIdentifier";
static NSString *const kAPCBasicCellIdentifier       = @"APCBasicCellIdentifier";

@interface APCSettingsViewController ()

@end

@implementation APCSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    
    if (section == 0) {
        rows = 3;
    } else {
        rows = 2;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCRightDetailCellIdentifier];
            cell.textLabel.text = NSLocalizedString(@"Auto-Lock", nil);
            
            NSInteger numberOfMinutes = [((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.parameters numberForKey:kNumberOfMinutesForPasscodeKey].integerValue;
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld %@", (long)numberOfMinutes, NSLocalizedString(@"minutes", nil)];
        } else if (indexPath.row == 1){
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCBasicCellIdentifier];
            cell.textLabel.text = NSLocalizedString(@"Change Passcode", @"");
        } else if (indexPath.row == 2){
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCBasicCellIdentifier];
            cell.textLabel.text = NSLocalizedString(@"Change Password", @"");
        }
        
    } else {
        if (indexPath.row == 0) {
//            APCSwitchTableViewCell *cell = (APCSwitchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAPCSwitchCellIdentifier];
//            cell.textLabel.text = NSLocalizedString(@"Push Notifications", @"");
//            cell.cellSwich.on = YES;
//            cell.delegate = self;
//            
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCBasicCellIdentifier];
            cell.textLabel.text = NSLocalizedString(@"Push Notifications", @"");
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:kAPCRightDetailCellIdentifier];
            cell.textLabel.text = NSLocalizedString(@"Devices", @"");
        }
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), tableView.sectionHeaderHeight)];
    headerView.contentView.backgroundColor = [UIColor colorWithWhite:248/255.0f alpha:1.0];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    headerLabel.font = [UIFont appLightFontWithSize:16.0f];
    headerLabel.textColor = [UIColor appSecondaryColor2];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:headerLabel];
    
    if (section == 0) {
        headerLabel.text = @"Security";
    } else{
        headerLabel.text = @"General";
    }
    
    return headerView;
}

#pragma mark - APCSwitchTableViewCellDelegate methods

- (void)switchTableViewCell:(APCSwitchTableViewCell *)cell switchValueChanged:(BOOL)on
{
    
}

@end
