// 
//  APCDashboardEditViewController.m 
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
    
    // update the items array to reflect the updated item order.
    APCTableViewDashboardItem *selectedItem = [self.items objectAtIndex:sourceIndexPath.row];
    
    [self.items removeObjectAtIndex:sourceIndexPath.row];
    [self.items insertObject:selectedItem atIndex:destinationIndexPath.row];
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
