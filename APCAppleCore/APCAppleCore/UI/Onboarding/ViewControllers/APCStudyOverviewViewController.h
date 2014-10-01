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
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) NSString *diseaseName;

- (IBAction)signInTapped:(id)sender;
- (IBAction)signUpTapped:(id)sender;

- (NSArray *)studyDetailsFromJSONFile:(NSString *)jsonFileName;

@end

@interface APCStudyDetails : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *details;

@end
