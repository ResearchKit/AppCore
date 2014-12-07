// 
//  APCDashboardEditViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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
    [self.headerLabel setTextColor:[UIColor appSecondaryColor2]];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSNumber *rowTypeNumber = [self.rowItemsOrder objectAtIndex:sourceIndexPath.row];
    
    [self.rowItemsOrder removeObjectAtIndex:sourceIndexPath.row];
    [self.rowItemsOrder insertObject:rowTypeNumber atIndex:destinationIndexPath.row];

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - IB Actions

- (IBAction)done:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.rowItemsOrder forKey:kAPCDashboardRowItemsOrder];
    [defaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
