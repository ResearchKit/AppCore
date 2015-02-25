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

#import "APCMedTrackerDailyDosageRecord.h"

#import "APCMedTrackerMedication+Helper.h"
#import "APCMedTrackerPrescription+Helper.h"
#import "APCMedTrackerPossibleDosage+Helper.h"
#import "APCMedTrackerPrescriptionColor+Helper.h"

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

@property (nonatomic, assign)          NSUInteger      numberOfTickMarksToSet;

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
            numberOfRows = [self.lozenge.prescription.numberOfTimesPerDay integerValue];
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
        aCell.textLabel.text = self.lozenge.prescription.medication.name;
        aCell.detailTextLabel.text = self.lozenge.prescription.dosage.name;
        if (self.numberOfTickMarksToSet > 0) {
            aCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.numberOfTickMarksToSet = self.numberOfTickMarksToSet - 1;
        }
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
            aCell.addTopicLabel.text = self.lozenge.prescription.medication.name;
        } else if (indexPath.row == kSummarySectionFrequencyRow) {
            aCell.addTopicLabel.text = [self formatNumbersAndDays:self.lozenge.prescription.frequencyAndDays];
        } else if (indexPath.row == kSummarySectionColorRow) {
            aCell.colorSwatch.backgroundColor = self.lozenge.prescription.color.UIColor;
        } else if (indexPath.row == kSummarySectionDosageRow) {
            aCell.addTopicLabel.text = self.lozenge.prescription.dosage.name;
        }
        cell = aCell;
    }

    return  cell;
}

#pragma  mark  -  Update Data Store Methods

- (void)updateNumberOfDosesTaken
{
    NSInteger   numberOfRowsInDosesSection = [self.tabulator numberOfRowsInSection:kDailyDosesTakenSection];
    NSUInteger  totalNumberOfDosesTaken = 0;
    for (NSUInteger  row = 0;  row < numberOfRowsInDosesSection;  row++) {
        UITableViewCell  *doseCell = [self.tabulator cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:kDailyDosesTakenSection]];
        if (doseCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            totalNumberOfDosesTaken = totalNumberOfDosesTaken + 1;
        }
    }
    NSDate  *dateOfLozenge = self.lozenge.currentDate;
    [self.lozenge.prescription recordThisManyDoses: totalNumberOfDosesTaken
                                       takenOnDate: dateOfLozenge
                                   andUseThisQueue: [NSOperationQueue mainQueue]
                                  toDoThisWhenDone: ^(NSTimeInterval operationDuration,
                                                      NSError *error)
     {
         if (error != nil) {
             APCLogError2(error);
         } else {
             [self.lozenge.prescription fetchDosesTakenFromDate:dateOfLozenge
                                                         toDate:dateOfLozenge
                                                andUseThisQueue:[NSOperationQueue mainQueue]
                                               toDoThisWhenDone:^(APCMedTrackerPrescription *prescription,
                                                                  NSArray *dailyDosageRecords,
                                                                  NSTimeInterval operationDuration,
                                                                  NSError *error)
              {
                  APCMedTrackerDailyDosageRecord  *record = nil;
                  
                  if (error != nil) {
                      APCLogError2(error);
                  } else if (dailyDosageRecords.count == 0) {
                      self.lozenge.numberOfDosesTaken = [NSNumber numberWithUnsignedInteger:0];
                  } else {
                      record = [dailyDosageRecords firstObject];
                      self.lozenge.numberOfDosesTaken = record.numberOfDosesTakenForThisDate;
                  }
              }];
         }
         
     }];
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
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [self updateNumberOfDosesTaken];
    }
}

#pragma  mark  -  View Controller Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = viewControllerTitle;
    
    self.tabulator.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    UINib  *setupTableCellNib = [UINib nibWithNibName:kSetupTableCellName bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:setupTableCellNib forCellReuseIdentifier:kSetupTableCellName];
    
    self.numberOfTickMarksToSet = [self.lozenge.numberOfDosesTaken unsignedIntegerValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
