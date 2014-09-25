//
//  APCStudyOverviewViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 9/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <APCAppleCore/APCAppleCore.h>

@interface APCStudyOverviewViewController : APCViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *diseaseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;

- (IBAction)signInTapped:(id)sender;
- (IBAction)signUpTapped:(id)sender;

@end
