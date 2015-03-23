// 
//  APCSettingsViewController.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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
    
    [self setupNavAppearance];
    
    self.editing = YES;
    
    self.items = [self prepareContent];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  APCLogViewControllerAppeared();
}

- (NSArray *)prepareContent
{
    NSMutableArray *items = [NSMutableArray new];
    
    {
        APCAppDelegate * appDelegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
        BOOL reminderOnState = appDelegate.tasksReminder.reminderOn;
        
        NSMutableArray *rowItems = [NSMutableArray new];
        
        {
            APCTableViewSwitchItem *field = [APCTableViewSwitchItem new];
            field.caption = NSLocalizedString(@"All Task Reminders", @"");
            field.identifier = kAPCSwitchCellIdentifier;
            field.editable = NO;
            
            field.on = reminderOnState;
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCSettingsItemTypeReminderOnOff;
            [rowItems addObject:row];
        }
        
        if (reminderOnState)
        {
            APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
            field.caption = NSLocalizedString(@"Reminder Time", @"");
            field.pickerData = @[[APCTasksReminderManager reminderTimesArray]];
            field.textAlignnment = NSTextAlignmentRight;
            field.identifier = kAPCDefaultTableViewCellIdentifier;
            field.selectedRowIndices = @[@([[APCTasksReminderManager reminderTimesArray] indexOfObject:appDelegate.tasksReminder.reminderTime])];

            APCTableViewRow *row = [APCTableViewRow new];
            row.item = field;
            row.itemType = kAPCSettingsItemTypeReminderTime;
            [rowItems addObject:row];
        }
     
        APCTableViewSection *section = [APCTableViewSection new];
        section.sectionTitle = NSLocalizedString(@"", @"");
        section.rows = [NSArray arrayWithArray:rowItems];
        [items addObject:section];
    }

//The code below enables per task notifications section and rows.
    
//    
//    /*************/
//    
//    //Get all the tasks
//    NSManagedObjectContext * context = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.mainContext;
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription
//                                              entityForName:@"APCTask" inManagedObjectContext:context];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setEntity:entityDescription];
//    
//    NSError *error;
//    NSArray *array = [context executeFetchRequest:request error:&error];
//    
//    APCLogError2(error);
//    
//    
//    
//    NSMutableArray *rowItems = [NSMutableArray new];
//    
//    for (APCTask *task in array) {
//        if (task.taskTitle) {
//            
//            {
//                {
//                    APCTableViewSwitchItem *field = [APCTableViewSwitchItem new];
//                    field.caption = NSLocalizedString(task.taskTitle, @"");
//                    field.identifier = kAPCSwitchCellIdentifier;
//                    field.editable = NO;
//                    APCAppDelegate * appDelegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
//                    field.on = appDelegate.tasksReminder.reminderOn;
//                    
//                    APCTableViewRow *row = [APCTableViewRow new];
//                    row.item = field;
//                    row.itemType = kAPCSettingsItemTypeReminderOnOff;
//                    [rowItems addObject:row];
//                }
//                
//                {
//                    APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
//                    field.caption = NSLocalizedString(@"Reminder Time", @"");
//                    field.pickerData = @[[APCTasksReminderManager reminderTimesArray]];
//                    field.textAlignnment = NSTextAlignmentRight;
//                    field.identifier = kAPCDefaultTableViewCellIdentifier;
//                    APCAppDelegate * appDelegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
//                    field.selectedRowIndices = @[@([[APCTasksReminderManager reminderTimesArray] indexOfObject:appDelegate.tasksReminder.reminderTime])];
//                    
//                    APCTableViewRow *row = [APCTableViewRow new];
//                    row.item = field;
//                    row.itemType = kAPCSettingsItemTypeReminderTime;
//                    [rowItems addObject:row];
//                }
//            }
//        }
//    }
//    
//    APCTableViewSection *section = [APCTableViewSection new];
//    
//    section.rows = [NSArray arrayWithArray:rowItems];
//    [items addObject:section];

    
    /*************/
    
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
    
    APCTableViewSection *sectionItem = self.items[section];
    headerLabel.text = sectionItem.sectionTitle;
    
    return headerView;
}

#pragma mark - Setup

- (void)setupNavAppearance
{
    UIBarButtonItem  *backster = [APCCustomBackButton customBackBarButtonItemWithTarget:self action:@selector(back) tintColor:[UIColor appPrimaryColor]];
    [self.navigationItem setLeftBarButtonItem:backster];
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewItemType itemType = [self itemTypeForIndexPath:indexPath];
    
    switch (itemType) {
        case kAPCSettingsItemTypePasscode:
        {
            APCChangePasscodeViewController *changePasscodeViewController = [[UIStoryboard storyboardWithName:@"APCProfile" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"ChangePasscodeVC"];
            [self.navigationController presentViewController:changePasscodeViewController animated:YES completion:nil];
        }
            break;
        case kAPCSettingsItemTypePermissions:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
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
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.section == 0 && indexPath.row == 2) {
        APCAppDelegate * appDelegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
        NSInteger index = ((NSNumber *)selectedIndices[0]).integerValue;
        appDelegate.tasksReminder.reminderTime = [APCTasksReminderManager reminderTimesArray][index];
    }
}


- (void)setupDefaultCellAppearance:(APCDefaultTableViewCell *)cell
{
    [cell.textLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    
    [cell.detailTextLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    [cell.detailTextLabel setTextColor:[UIColor blackColor]];

}

- (void)setupSwitchCellAppearance:(APCSwitchTableViewCell *)cell
{
    [cell.textLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    [cell.textLabel setTextColor:[UIColor blackColor]];
}

/*********************************************************************************/
#pragma mark - Switch Cell Delegate
/*********************************************************************************/

- (void)switchTableViewCell:(APCSwitchTableViewCell *)cell switchValueChanged:(BOOL)on
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    BOOL allReminders = indexPath.section == 0 && indexPath.row == 0;
    if (allReminders) {
        
        dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            APCAppDelegate * appDelegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
            appDelegate.tasksReminder.reminderOn = on;
        });
        
        if (self.pickerShowing) {
            [self hidePickerCell];            
        }
    }
    self.items = [self prepareContent];
    [self.tableView reloadData];

    if (allReminders) {
        [self.tableView reloadData];
    } else {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Getter

- (APCParameters *)parameters
{
    _parameters = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.parameters;
    
    return _parameters;
   
}

#pragma mark - Selectors / IBActions

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
