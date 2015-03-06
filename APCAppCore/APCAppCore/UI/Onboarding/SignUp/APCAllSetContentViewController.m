//
//  APCAllSetContentViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCAllSetContentViewController.h"
#import "APCAppCore.h"
#import "APCAllSetTableViewCell.h"

static NSString *kAllSetCellIdentifier = @"AllSetCell";

typedef NS_ENUM(NSUInteger, APCAllSetRows)
{
    APCAllSetRowActivities = 0,
    APCAllSetRowDashboard,
    APCAllSetRowsTotalNumberOfRows
};

@interface APCAllSetContentViewController ()

@property (weak, nonatomic) IBOutlet UILabel *appName;

@property (strong, nonatomic) NSArray *textBlocks;

@end

@implementation APCAllSetContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appName.text = [APCUtilities appName];
    
    self.tableView.estimatedRowHeight = 108.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self configureTextBlocks];
}

- (void)configureTextBlocks
{
    APCAppDelegate *appDelegate = ((APCAppDelegate*) [UIApplication sharedApplication].delegate);
    
    self.textBlocks = [appDelegate allSetTextBlocks];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

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
                        APCLogError(@"Received a key that is not supported. Data Received: %@", textBlock);
                    }
                }
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
                        APCLogError(@"Received a key that is not supported. Data Received: %@", textBlock);
                    }
                }
            }
            cell.icon = [UIImage imageNamed:@"tab_dashboard_selected"];
        }
            break;
    }
    
    return cell;
}

@end