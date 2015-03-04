// 
//  APCWithdrawSurveyViewController.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCTableViewItem.h"
#import "APCCheckTableViewCell.h"

@interface APCWithdrawSurveyViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectAllLabel;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (nonatomic, strong) NSArray *items;

- (NSArray *)prepareContent;

- (NSArray *)surveyFromJSONFile:(NSString *)jsonFileName;

- (IBAction)submit:(id)sender;

@end
