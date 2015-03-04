// 
//  APCDashboardEditViewController.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCDashboardEditViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

@interface APCDashboardEditViewController ()


@end

@implementation APCDashboardEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.items = [NSMutableArray new];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.rowItemsOrder = [NSMutableArray arrayWithArray:[defaults objectForKey:kAPCDashboardRowItemsOrder]];
    
    self.tableView.editing = YES;
    
    [self setupAppearance];
}

- (void)setupAppearance
{
    [self.headerLabel setFont:[UIFont appLightFontWithSize:14.0f]];
    [self.headerLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.headerLabel setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *) __unused tableView numberOfRowsInSection:(NSInteger) __unused section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewDashboardItem *item = self.items[indexPath.row];
    
    APCDashboardEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAPCDashboardEditTableViewCellIdentifier];
    cell.textLabel.text = item.caption;
    cell.tintColor = item.tintColor;

    cell.shouldIndentWhileEditing = NO;
    cell.editingAccessoryType = UITableViewCellAccessoryNone;
    cell.showsReorderControl = NO;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (BOOL)tableView:(UITableView *) __unused tableView canMoveRowAtIndexPath:(NSIndexPath *) __unused indexPath
{
    return YES;
}

- (void)     tableView: (UITableView *) __unused tableView
    moveRowAtIndexPath: (NSIndexPath *) sourceIndexPath
           toIndexPath: (NSIndexPath *) destinationIndexPath
{
    NSNumber *rowTypeNumber = [self.rowItemsOrder objectAtIndex:sourceIndexPath.row];
    
    [self.rowItemsOrder removeObjectAtIndex:sourceIndexPath.row];
    [self.rowItemsOrder insertObject:rowTypeNumber atIndex:destinationIndexPath.row];

}

- (UITableViewCellEditingStyle) tableView: (UITableView *) __unused tableView
			editingStyleForRowAtIndexPath: (NSIndexPath *) __unused indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)                         tableView: (UITableView *) __unused tableView
    shouldIndentWhileEditingRowAtIndexPath: (NSIndexPath *) __unused indexPath
{
    return NO;
}

#pragma mark - IB Actions

- (IBAction) done: (id) __unused sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.rowItemsOrder forKey:kAPCDashboardRowItemsOrder];
    [defaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) cancel: (id) __unused sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
