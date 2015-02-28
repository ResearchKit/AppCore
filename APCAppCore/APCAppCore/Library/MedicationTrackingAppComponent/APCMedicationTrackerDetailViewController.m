//
//  APCMedicationTrackerDetailViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationTrackerDetailViewController.h"
#import "APCSetupTableViewCell.h"
#import "APCLozengeButton.h"

#import "APCMedTrackerDailyDosageRecord.h"

#import "APCMedicationDetailsTableViewCell.h"
#import "APCConfirmationView.h"

#import "APCMedTrackerMedication+Helper.h"
#import "APCMedTrackerPrescription+Helper.h"
#import "APCMedTrackerPossibleDosage+Helper.h"
#import "APCMedTrackerPrescriptionColor+Helper.h"

#import "APCAppCore.h"

#import "NSDictionary+APCAdditions.h"

static  NSString  *viewControllerTitle           = @"Medication Details";

static  NSString  *kMedicationDetailsName        = @"APCMedicationDetailsTableViewCell";

static  NSInteger  numberOfSectionsInTableView   = 1;

static  NSInteger  kDailyDosesTakenSection       = 0;

static  CGFloat    kHeightForDosesTakenHeader    = 36.0;
static  CGFloat    kPointSizeForDosesTakenHeader = 15.0;

static  NSString  *mainTableCategories[] = { @"Medication", @"Frequency", @"Label Color", @"Dosage" };

static  NSString  *daysOfWeekNames[]     = { @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday" };

@interface APCMedicationTrackerDetailViewController  ( )  <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak)  IBOutlet  UIBarButtonItem  *todayMedicineTitle;

@property (nonatomic, weak)  IBOutlet  UITableView      *tabulator;

@property (nonatomic, assign)          NSUInteger        numberOfTickMarksToSet;

@end

@implementation APCMedicationTrackerDetailViewController

#pragma  mark  -  Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *) __unused tableView
{
    return  numberOfSectionsInTableView;
}

- (NSInteger)tableView:(UITableView *) __unused tableView numberOfRowsInSection:(NSInteger) __unused section
{
    NSInteger  numberOfRows = 0;
    
    if (self.lozenge != nil) {
        numberOfRows = [self.lozenge.prescription.numberOfTimesPerDay integerValue];
    }
    return  numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) __unused indexPath
{
    APCMedicationDetailsTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:kMedicationDetailsName];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.colorSwatch.backgroundColor = self.lozenge.prescription.color.UIColor;
    cell.medicationName.text = self.lozenge.prescription.medication.name;
    NSString  *doseNumberString = [NSString stringWithFormat:@"Dose %ld", (indexPath.row + 1)];
    cell.doseNumber.text = doseNumberString;
    NSString  *doseAmountString = [NSString stringWithFormat:@"(%@)", self.lozenge.prescription.dosage.name];
    cell.doseAmount.text = doseAmountString;
    if (self.numberOfTickMarksToSet > 0) {
        cell.confirmer.completed = YES;
        self.numberOfTickMarksToSet = self.numberOfTickMarksToSet - 1;
    }
    return  cell;
}

#pragma  mark  -  Update Data Store Methods

- (void)updateNumberOfDosesTaken
{
    NSInteger   numberOfRowsInDosesSection = [self.tabulator numberOfRowsInSection:kDailyDosesTakenSection];
    NSUInteger  totalNumberOfDosesTaken = 0;
    for (NSUInteger  row = 0;  row < numberOfRowsInDosesSection;  row++) {
        APCMedicationDetailsTableViewCell  *doseCell = (APCMedicationDetailsTableViewCell *)[self.tabulator cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:kDailyDosesTakenSection]];
        if (doseCell.confirmer.completed == YES) {
            totalNumberOfDosesTaken = totalNumberOfDosesTaken + 1;
        }
    }
    NSDate  *dateOfLozenge = self.lozenge.currentDate;
    [self.lozenge.prescription recordThisManyDoses: totalNumberOfDosesTaken
                                       takenOnDate: dateOfLozenge
                                   andUseThisQueue: [NSOperationQueue mainQueue]
                                  toDoThisWhenDone: ^(NSTimeInterval __unused operationDuration,
                                                      NSError *error)
     {
         if (error != nil) {
             APCLogError2(error);
         } else {
             [self.lozenge.prescription fetchDosesTakenFromDate:dateOfLozenge
                                                         toDate:dateOfLozenge
                                                andUseThisQueue:[NSOperationQueue mainQueue]
                                               toDoThisWhenDone:^(APCMedTrackerPrescription * __unused prescription,
                                                                  NSArray *dailyDosageRecords,
                                                                  NSTimeInterval  __unused operationDuration,
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

- (UIView *)tableView:(UITableView *) __unused tableView viewForHeaderInSection:(NSInteger)section
{
    UIView  *view = nil;
    
    if (section == kDailyDosesTakenSection) {
        
        CGFloat  width = CGRectGetWidth(self.view.frame);
        CGFloat  offset = 17.0;
        
        CGRect  frame = CGRectMake(0.0, 0.0, width, kHeightForDosesTakenHeader);
        UIView  *container = [[UIView alloc] initWithFrame:frame];
        
        frame = CGRectMake(offset, 0.0, width - 2.0 * offset, kHeightForDosesTakenHeader);
        UILabel  *label = [[UILabel alloc] initWithFrame:frame];
        label.numberOfLines = 0;
        label.font = [UIFont appLightFontWithSize:kPointSizeForDosesTakenHeader];
        label.textColor = [UIColor blackColor];
        label.text = NSLocalizedString(@"Select which scheduled doses you have taken", nil);
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [container addSubview:label];
        
        frame = CGRectMake(0.0, (kHeightForDosesTakenHeader - 1.0), width, 1.0);
        UIView  *line = [[UIView alloc] initWithFrame:frame];
        line.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
        [container addSubview:line];
        
        view = container;
    }
    return  view;
}

- (CGFloat)tableView:(UITableView *) __unused tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat  height = 18.0;
    
    if (section == kDailyDosesTakenSection) {
        height = kHeightForDosesTakenHeader;
    }
    
    return  height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kDailyDosesTakenSection) {
        APCMedicationDetailsTableViewCell  *cell = (APCMedicationDetailsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (cell.confirmer.completed == NO) {
            cell.confirmer.completed = YES;
        } else {
            cell.confirmer.completed = NO;
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

    UINib  *medicationDetailsCellNib = [UINib nibWithNibName:kMedicationDetailsName bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:medicationDetailsCellNib forCellReuseIdentifier:kMedicationDetailsName];
    
    self.numberOfTickMarksToSet = [self.lozenge.numberOfDosesTaken unsignedIntegerValue];
    
    NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterFullStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    NSString  *todayDate = [formatter stringFromDate:self.lozenge.currentDate];
    self.todayMedicineTitle.title = todayDate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
