//
//  APCWithdrawSurveyViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCTableViewItem.h"
#import "APCCheckTableViewCell.h"

@interface APCWithdrawSurveyViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@property (weak, nonatomic) IBOutlet UIButton *withdrawButton;

@property (nonatomic, strong) NSMutableArray *items;

- (void)surveyFromJSONFile:(NSString *)jsonFileName;

- (IBAction)cancel:(id)sender;
@end
