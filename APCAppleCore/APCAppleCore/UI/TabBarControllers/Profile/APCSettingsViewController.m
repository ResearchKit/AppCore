//
//  APCSettingsViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/1/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSettingsViewController.h"
#import "APCChangePasscodeViewController.h"
#import "APCAppDelegate.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"


static NSString * const kAPCBasicTableViewCellIdentifier = @"APCBasicTableViewCell";
static NSString * const kAPCRightDetailTableViewCellIdentifier = @"APCRightDetailTableViewCell";

@interface APCSettingsViewController ()

@end

@implementation APCSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"Version: %@ (Build %@)", version, build];
    
    self.editing = YES;
    
    // Added for testing purposes. In case the QA chose to Reset the app, the screen shouldn't crash
    NSNumber *numberOfMinutes = [self.parameters numberForKey:kNumberOfMinutesForPasscodeKey];
    if (!numberOfMinutes) {
        [self.parameters setNumber:[APCParameters autoLockValues][0] forKey:kNumberOfMinutesForPasscodeKey];
    }
    
    self.items = [self prepareContent];
}

- (NSArray *)prepareContent
{
    NSMutableArray *items = [NSMutableArray new];
    
    {
        NSMutableArray *rowItems = [NSMutableArray new];
        
        {
            APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            field.selectionStyle = UITableViewCellSelectionStyleGray;
            field.caption = NSLocalizedString(@"Auto-Lock", @"");
            field.detailDiscloserStyle = YES;
            field.textAlignnment = NSTextAlignmentRight;
            field.pickerData = @[[APCParameters autoLockOptionStrings]];
            
            NSNumber *numberOfMinutes = [self.parameters numberForKey:kNumberOfMinutesForPasscodeKey];
            NSInteger index = [[APCParameters autoLockValues] indexOfObject:numberOfMinutes];
            field.selectedRowIndices = @[@(index)];
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCSettingsItemTypeAutoLock;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewItem *field = [APCTableViewItem new];
            field.caption = NSLocalizedString(@"Change Passcode", @"");
            field.identifier = kAPCBasicTableViewCellIdentifier;
            field.textAlignnment = NSTextAlignmentRight;
            field.editable = NO;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCSettingsItemTypePasscode;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewItem *field = [APCTableViewItem new];
            field.caption = NSLocalizedString(@"Change Password", @"");
            field.identifier = kAPCBasicTableViewCellIdentifier;
            field.textAlignnment = NSTextAlignmentRight;
            field.editable = NO;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCSettingsItemTypePassword;
            [rowItems addObject:row];
        }
        
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        [items addObject:section];
    }
    
    {
        NSMutableArray *rowItems = [NSMutableArray new];
        
        {
            APCTableViewSwitchItem *field = [APCTableViewSwitchItem new];
            field.caption = NSLocalizedString(@"Push Notifications", @"");
            field.identifier = kAPCSwitchCellIdentifier;
            field.editable = NO;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCSettingsItemTypePushNotifications;
            [rowItems addObject:row];
        }
        
        {
            APCTableViewItem *field = [APCTableViewItem new];
            field.caption = NSLocalizedString(@"Devices", @"");
            field.identifier = kAPCRightDetailTableViewCellIdentifier;
            field.textAlignnment = NSTextAlignmentRight;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCSettingsItemTypeDevices;
            [rowItems addObject:row];
        }
        
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        [items addObject:section];
    }
    
    return [NSArray arrayWithArray:items];
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

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewItemType itemType = [self itemTypeForIndexPath:indexPath];
    
    switch (itemType) {
        case kAPCSettingsItemTypePasscode:
        {
            APCChangePasscodeViewController *changePasscodeViewController = [[UIStoryboard storyboardWithName:@"APCProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"ChangePasscodeVC"];
            [self.navigationController presentViewController:changePasscodeViewController animated:YES completion:nil];
        }
            break;
            
        default:
            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - APCPickerTableViewCellDelegate methods

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell pickerViewDidSelectIndices:(NSArray *)selectedIndices
{
    [super pickerTableViewCell:cell pickerViewDidSelectIndices:selectedIndices];
    
    NSInteger index = ((NSNumber *)selectedIndices[0]).integerValue;
    
    [self.parameters setNumber:[APCParameters autoLockValues][index] forKey:kNumberOfMinutesForPasscodeKey];
}

- (void)setupDefaultCellAppearance:(APCDefaultTableViewCell *)cell
{
    [cell.textLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    [cell.textLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [cell.detailTextLabel setFont:[UIFont appRegularFontWithSize:16.0f]];
    [cell.detailTextLabel setTextColor:[UIColor appSecondaryColor2]];

}

- (void)setupSwitchCellAppearance:(APCSwitchTableViewCell *)cell
{
    [cell.textLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    [cell.textLabel setTextColor:[UIColor appSecondaryColor1]];
}

#pragma mark - Getter

- (APCParameters *)parameters
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.parameters;
}

@end
