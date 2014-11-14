//
//  APCDashboardEditViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDashboardEditViewController.h"

@implementation APCDashboardEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.editing = YES;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneTapped)];
    [self.navigationItem setRightBarButtonItem:doneButton];
}


#pragma mark - UITableViewDelegate methods

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPat
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSNumber *sectionData = [self.sectionsOrder objectAtIndex:sourceIndexPath.row];
    
    [self.items removeObjectAtIndex:sourceIndexPath.row];
    [self.items insertObject:sectionData atIndex:destinationIndexPath.row];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.sectionsOrder forKey:kDashboardSectionsOrder];
    [defaults synchronize];
}

#pragma mark - UITableViewDelegate methods

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark - Selector Actions

- (void)doneTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Public Methods

- (APCTableViewItem *)itemForIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewSection *sectionItem = self.items[indexPath.section];
    APCTableViewRow *rowItem = sectionItem.rows[indexPath.row];
    
    APCTableViewItem *dashboardItem = rowItem.item;
    
    return dashboardItem;
}

- (APCTableViewItemType)itemTypeForIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewSection *sectionItem = self.items[indexPath.section];
    APCTableViewRow *rowItem = sectionItem.rows[indexPath.row];
    
    APCTableViewItemType dashboardItemType = rowItem.itemType;
    
    return dashboardItemType;
}
@end
