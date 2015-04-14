// 
//  APCMedicationTrackerDetailViewController.m 
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

static  CGFloat    kAPCMedicationRowHeight       = 64.0;

@interface APCMedicationTrackerDetailViewController  ( )  <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak)  IBOutlet  UIBarButtonItem  *todayMedicineTitle;

@property (nonatomic, weak)  IBOutlet  UITableView      *tabulator;

@property  (nonatomic, weak)           UIBarButtonItem  *donester;;

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

- (NSString *)extractMedicationNamePrefix:(NSString *)medicationName
{
    NSRange  range = [medicationName rangeOfString:@" ("];
    NSString  *answer = nil;
    if (range.location == NSNotFound) {
        answer = medicationName;
    } else {
        answer = [medicationName substringToIndex:range.location];
    }
    return  answer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) __unused indexPath
{
    APCMedicationDetailsTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:kMedicationDetailsName];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.colorSwatch.backgroundColor = self.lozenge.prescription.color.UIColor;
    
    cell.medicationName.text = [self extractMedicationNamePrefix:self.lozenge.prescription.medication.name];
    
    NSString  *doseNumberString = [NSString stringWithFormat:@"Dose %ld", (indexPath.row + 1)];
    cell.doseNumber.text = doseNumberString;
    
    cell.doseAmount.text = self.lozenge.prescription.dosage.name;
    
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
    for (NSInteger  row = 0;  row < numberOfRowsInDosesSection;  row++) {
        APCMedicationDetailsTableViewCell  *doseCell = (APCMedicationDetailsTableViewCell *)[self.tabulator cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:kDailyDosesTakenSection]];
        if (doseCell.confirmer.completed == YES) {
            totalNumberOfDosesTaken = totalNumberOfDosesTaken + 1;
        }
    }
    self.lozenge.dailyDosageRecord.numberOfDosesTakenForThisDate = [NSNumber numberWithUnsignedInteger:totalNumberOfDosesTaken];
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
                  if (error != nil) {
                      APCLogError2(error);
                  } else {
                      APCMedTrackerDailyDosageRecord  *record = nil;
                      
                      for (APCMedTrackerDailyDosageRecord  *thisRecord  in  dailyDosageRecords) {
                          if ([thisRecord.dateThisRecordRepresents.startOfDay isEqualToDate: dateOfLozenge.startOfDay]) {
                              record = thisRecord;
                              break;
                          }
                      }
                      if (record != nil) {
                          self.lozenge.dailyDosageRecord = record;
                          [self.lozenge setNeedsDisplay];
                      } else {
                          self.lozenge.dailyDosageRecord = nil;
                      }
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
        container.backgroundColor = [UIColor colorWithWhite:0.90 alpha:0.85];
        
        frame = CGRectMake(offset, 0.0, width - 2.0 * offset, kHeightForDosesTakenHeader);
        UILabel  *label = [[UILabel alloc] initWithFrame:frame];
        label.numberOfLines = 0;
        label.font = [UIFont appRegularFontWithSize:kPointSizeForDosesTakenHeader];
        label.textColor = [UIColor blackColor];
        label.text = NSLocalizedString(@"Log Your Medications", nil);
        label.textAlignment = NSTextAlignmentCenter;
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

- (CGFloat)tableView:(UITableView *) __unused tableView heightForRowAtIndexPath:(NSIndexPath *) __unused indexPath
{
    return  kAPCMedicationRowHeight;
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

#pragma  mark  -  Done Button Action Method

- (IBAction)doneButtonWasTapped:(id) __unused sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma  mark  -  View Controller Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = viewControllerTitle;
    
    self.tabulator.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIBarButtonItem  *donester = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonWasTapped:)];
    self.donester = donester;
    self.navigationItem.rightBarButtonItem = self.donester;
    self.donester.enabled = YES;


    UINib  *medicationDetailsCellNib = [UINib nibWithNibName:kMedicationDetailsName bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:medicationDetailsCellNib forCellReuseIdentifier:kMedicationDetailsName];
    
    NSUInteger  numberOfTickMarks = 0;
    if (self.lozenge.dailyDosageRecord != nil) {
        numberOfTickMarks = [self.lozenge.dailyDosageRecord.numberOfDosesTakenForThisDate unsignedIntegerValue];
    }
    self.numberOfTickMarksToSet = numberOfTickMarks;
    
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
