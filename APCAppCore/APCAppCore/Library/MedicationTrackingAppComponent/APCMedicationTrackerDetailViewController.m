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

#import "APCMedTrackerMedication+Helper.h"
#import "APCMedTrackerMedicationSchedule+Helper.h"
#import "APCMedTrackerPossibleDosage+Helper.h"
#import "APCMedTrackerScheduleColor+Helper.h"
#import "APCMedTrackerMedicationSchedule+Helper.h"

#import "APCAppCore.h"

static  NSString  *viewControllerTitle   = @"Medication Tracker";

static  NSString  *kSetupTableCellName   = @"APCSetupTableViewCell";

static  NSInteger  kSummarySectionNameRow      = 0;
static  NSInteger  kSummarySectionFrequencyRow = 1;
static  NSInteger  kSummarySectionColorRow     = 2;
static  NSInteger  kSummarySectionDosageRow    = 3;

static  NSInteger  numberOfSectionsInTableView = 2;

static  NSInteger  kDailyDosesTakenSection     = 0;
static  NSInteger  kMedicineSummarySection     = 1;

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
    
    if (section == kDailyDosesTakenSection) {
        if (self.lozenge != nil) {
            numberOfRows = [self.lozenge.numberOfDosesPrescribed integerValue];
        }
    } else if (section == kMedicineSummarySection) {
        numberOfRows = 4;
    }
    return  numberOfRows;
}

- (NSString *)formatNumbersAndDays:(NSDictionary *)frequencyAndDays
{
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

    if (indexPath.section == kDailyDosesTakenSection) {
        NSString  *identifier = @"Simple Cell Identifier";
        UITableViewCell  *aCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (aCell == nil) {
            aCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
        aCell.selectionStyle = UITableViewCellSelectionStyleNone;
        aCell.textLabel.text = self.schedule.medicine.name;
        aCell.detailTextLabel.text = self.schedule.dosage.name;
        cell = aCell;
    } else if (indexPath.section == kMedicineSummarySection) {

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

        if (indexPath.row == kSummarySectionNameRow) {
            aCell.addTopicLabel.text = self.schedule.medicine.name;
        } else if (indexPath.row == kSummarySectionFrequencyRow) {
            aCell.addTopicLabel.text = [self formatNumbersAndDays:self.schedule.frequenciesAndDays];
        } else if (indexPath.row == kSummarySectionColorRow) {
            aCell.colorSwatch.backgroundColor = self.schedule.color.UIColor;
        } else if (indexPath.row == kSummarySectionDosageRow) {
            aCell.addTopicLabel.text = self.schedule.dosage.name;
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
    if (section == kDailyDosesTakenSection) {
        title = @"Select which scheduled doses you have taken today";
    } else {
        title = @"          ";
    }
    return  title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kDailyDosesTakenSection) {
        UITableViewCell  *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
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
