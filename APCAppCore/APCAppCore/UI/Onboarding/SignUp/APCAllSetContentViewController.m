// 
//  APCAllSetContentViewController.m 
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
 
#import "APCAllSetContentViewController.h"
#import "APCAppCore.h"
#import "APCAllSetTableViewCell.h"
#import "APCDemographicUploader.h"

static  NSString *kAllSetCellIdentifier = @"AllSetCell";

typedef NS_ENUM(NSUInteger, APCAllSetRows)
{
    APCAllSetRowActivities = 0,
    APCAllSetRowDashboard,
    APCAllSetRowsTotalNumberOfRows
};

@interface APCAllSetContentViewController ()

@property (weak, nonatomic) IBOutlet UILabel *appName;

@property (strong, nonatomic) NSArray *textBlocks;

@property (strong, nonatomic) APCDemographicUploader  *demographicUploader;

@end

@implementation APCAllSetContentViewController

#pragma  mark  -  View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appName.text = [APCUtilities appName];
    
    self.tableView.estimatedRowHeight = 108.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self configureTextBlocks];    
    
    APCAppDelegate *appDelegate = (APCAppDelegate *)[UIApplication sharedApplication].delegate;
    APCUser  *user = appDelegate.dataSubstrate.currentUser;
    
    self.demographicUploader = [[APCDemographicUploader alloc] initWithUser:user];
    [self.demographicUploader uploadNonIdentifiableDemographicData];
    
    [self.tableView reloadData];
}

- (void)configureTextBlocks
{
    APCAppDelegate *appDelegate = ((APCAppDelegate*) [UIApplication sharedApplication].delegate);
    
    self.textBlocks = [appDelegate allSetTextBlocks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma  mark  -  Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *) __unused tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *) __unused tableView numberOfRowsInSection:(NSInteger) __unused section
{
    return APCAllSetRowsTotalNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCAllSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAllSetCellIdentifier
                                                                 forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case APCAllSetRowActivities:
        {
            NSString *original = NSLocalizedString(@"You’ll find your list of daily surveys and tasks on the “Activities” tab. New surveys and tasks will appear over the next few weeks.",
                                                   @"You’ll find your list of daily surveys and tasks on the “Activities” tab. New surveys and tasks will appear over the next few weeks.");
            
            if (self.textBlocks) {
                for (NSDictionary *textBlock in self.textBlocks) {
                    if (textBlock[kAllSetActivitiesTextOriginal]) {
                        cell.originalText = textBlock[kAllSetActivitiesTextOriginal];
                    } else {
                        cell.originalText = original;
                    }
                    
                    if (textBlock[kAllSetActivitiesTextAdditional]) {
                        cell.additonalText = textBlock[kAllSetActivitiesTextAdditional];
                    } else {
                        cell.additonalText = nil;
                    }
                }
            } else {
                cell.originalText = original;
            }
            
            cell.icon = [UIImage imageNamed:@"tab_activities_selected"];
        }
            break;
            
        default:
        {
            NSString *original = NSLocalizedString(@"To see your results from surveys and tasks, check your “Dashboard” tab.",
                                                   @"To see your results from surveys and tasks, check your “Dashboard” tab.");

            if (self.textBlocks) {
                for (NSDictionary *textBlock in self.textBlocks) {
                    if (textBlock[kAllSetDashboardTextOriginal]) {
                        cell.originalText = textBlock[kAllSetDashboardTextOriginal];
                    } else {
                        cell.originalText = original;
                    }
                    
                    if (textBlock[kAllSetDashboardTextAdditional]) {
                        cell.additonalText = textBlock[kAllSetDashboardTextAdditional];
                    } else {
                        cell.additonalText = nil;
                    }
                }
            } else {
                cell.originalText = original;
            }
            cell.icon = [UIImage imageNamed:@"tab_dashboard_selected"];
        }
            break;
    }
    
    return cell;
}

@end
