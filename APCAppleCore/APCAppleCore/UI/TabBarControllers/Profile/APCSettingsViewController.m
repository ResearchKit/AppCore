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
    
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"Version: %@ (Build %@)", version, build];
    
    self.editing = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Getter

- (APCParameters *)parameters
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.parameters;
}

@end
