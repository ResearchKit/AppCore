//
//  APCMedicationTrackerDetailViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationTrackerDetailViewController.h"
#import "APCSetupTableViewCell.h"
#import "APCMedicationModel.h"
#import "APCLozengeButton.h"
#import "APCMedicationFollower.h"

#import "APCAppCore.h"

static  NSString  *viewControllerTitle = @"Medication Tracker";

static  NSString  *kSetupTableCellName   = @"APCSetupTableViewCell";

static  NSInteger  numberOfSectionsInTableView = 2;

static  NSString  *mainTableCategories[] = { @"Medication", @"Frequency", @"Label Color", @"Dosage" };

static  NSString  *daysOfWeekNames[]     = { @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday" };
static  NSUInteger  numberOfDaysOfWeek = (sizeof(daysOfWeekNames) / sizeof(NSString *));

@interface APCMedicationTrackerDetailViewController  ( )  <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak)  IBOutlet  UITableView    *tabulator;

@property (nonatomic, strong)           NSDictionary  *colormap;

@end

@implementation APCMedicationTrackerDetailViewController

#pragma  mark  -  Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  numberOfSectionsInTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger  numberOfRows = 0;

    if (section == 0) {
        if (self.follower != nil) {
            numberOfRows = [self.follower.follower.numberOfDosesPrescribed integerValue];
        }
    } else if (section == 1) {
        numberOfRows = 4;
    }
    return  numberOfRows;
}

- (NSString *)formatNumbersAndDays:(APCMedicationModel *)model
{
    NSDictionary  *frequencyAndDays = model.frequencyAndDays;

    NSMutableString  *daysAndNumbers = [NSMutableString string];
    for (NSUInteger  day = 0;  day < numberOfDaysOfWeek;  day++) {
        NSString  *key = daysOfWeekNames[day];
        NSNumber  *number = [frequencyAndDays objectForKey:key];
        if ([number integerValue] > 0) {
            if (daysAndNumbers.length == 0) {
                [daysAndNumbers appendFormat:@"%ld\u2009\u00d7, %@", [number integerValue], [key substringToIndex:3]];
            } else {
                [daysAndNumbers appendFormat:@", %@", [key substringToIndex:3]];
            }
        }
    }
    return  daysAndNumbers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell  *cell = nil;

    if (indexPath.section == 0) {
        NSString  *identifier = @"Simple Cell Identifier";
        UITableViewCell  *aCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (aCell == nil) {
            aCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
        aCell.selectionStyle = UITableViewCellSelectionStyleNone;
        aCell.textLabel.text = self.follower.follower.medicationName;
        aCell.detailTextLabel.text = [NSString stringWithFormat:@"Dose %ld, (%@)", (long)(indexPath.row + 1), self.follower.model.medicationDosageText];
        cell = aCell;
    } else if (indexPath.section == 1) {

        APCSetupTableViewCell  *aCell = (APCSetupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kSetupTableCellName];

        aCell.topicLabel.text = mainTableCategories[indexPath.row];
        aCell.accessoryType = UITableViewCellAccessoryNone;
        aCell.selectionStyle = UITableViewCellSelectionStyleNone;

        if (indexPath.row == 2) {
            aCell.colorSwatch.hidden = NO;
            aCell.addTopicLabel.hidden = YES;
        } else {
            aCell.colorSwatch.hidden = YES;
            aCell.addTopicLabel.hidden = NO;
        }

        if (indexPath.row == 0) {
            aCell.addTopicLabel.text = self.model.medicationName;
        } else if (indexPath.row == 1) {
            aCell.addTopicLabel.text = [self formatNumbersAndDays:self.model];
        } else if (indexPath.row == 2) {
            aCell.colorSwatch.backgroundColor = self.colormap[self.model.medicationLabelColor];
        } else if (indexPath.row == 3) {
            aCell.addTopicLabel.text = self.model.medicationDosageText;
        }
        cell = aCell;
    }

    return  cell;
}

#pragma  mark  -  Table View Delegate Methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
        //
        //    provide a non-empty blank string to get a section header at the bottom of the section
        //
    NSString  *title = @"";
    if (section == 0) {
        title = @"Select which scheduled doses you have taken today";
    } else {
        title = @"          ";
    }
    return  title;
}

#pragma  mark  -  View Controller Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = viewControllerTitle;

    UINib  *setupTableCellNib = [UINib nibWithNibName:kSetupTableCellName bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:setupTableCellNib forCellReuseIdentifier:kSetupTableCellName];

    self.colormap = @{
                      @"Gray"    : [UIColor grayColor],
                      @"Red"     : [UIColor redColor],
                      @"Green"   : [UIColor greenColor],
                      @"Blue"    : [UIColor blueColor],
                      @"Cyan"    : [UIColor cyanColor],
                      @"Magenta" : [UIColor magentaColor],
                      @"Yellow"  : [UIColor yellowColor],
                      @"Orange"  : [UIColor orangeColor],
                      @"Purple"  : [UIColor purpleColor]
                      };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
