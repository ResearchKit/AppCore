// 
//  APCMedicationDosageViewController.m 
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
 
#import "APCMedicationDosageViewController.h"

#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerPossibleDosage+Helper.h"

#import "APCLog.h"

static  NSString  *kViewControllerName       = @"Medication Dosage";

static  CGFloat    kSectionHeaderHeight      = 77.0;
static  CGFloat    kSectionHeaderLabelOffset = 10.0;

static  CGFloat    kAPCMedicationRowHeight   = 64.0;

@interface APCMedicationDosageViewController  ( )  <UITableViewDataSource, UITableViewDelegate>

@property  (nonatomic, weak)  IBOutlet  UITableView  *tabulator;

@property  (nonatomic, strong)          NSArray      *dosageAmounts;

@property  (nonatomic, strong)          NSIndexPath  *selectedIndex;
@property  (nonatomic, assign)          BOOL          doneButtonWasTapped;

@end

@implementation APCMedicationDosageViewController

#pragma  mark  -  Navigation Bar Button Action Methods

- (void)doneButtonTapped:(UIBarButtonItem *) __unused sender
{
    self.doneButtonWasTapped = YES;
    
    APCMedTrackerPossibleDosage  *dosage = nil;
    
    if (self.selectedIndex == nil) {
        dosage = [self findDosageWithZeroAmount];
    } else {
        dosage = self.dosageAmounts[self.selectedIndex.row];
    }
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(dosageController:didSelectDosageAmount:)] == YES) {
            [self.delegate performSelector:@selector(dosageController:didSelectDosageAmount:) withObject:self withObject:dosage];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma  mark  -  Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *) __unused tableView
{
    return  1;
}

- (NSInteger)tableView:(UITableView *) __unused tableView numberOfRowsInSection:(NSInteger) __unused section
{
    NSInteger  numberOfRows = [self.dosageAmounts count];
    return  numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString  *identifier = @"DosageTableViewCell";
    
    UITableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    APCMedTrackerPossibleDosage  *dosage = self.dosageAmounts[indexPath.row];
    NSString  *amountText = dosage.name;
    cell.textLabel.text = amountText;
    
    if (self.selectedIndex != nil) {
        if ([self.selectedIndex isEqual:indexPath] == YES) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return  cell;
}

#pragma  mark  -  Table View Delegate Methods

- (APCMedTrackerPossibleDosage *)findDosageWithZeroAmount
{
    APCMedTrackerPossibleDosage  *answer = nil;
    
    for (APCMedTrackerPossibleDosage  *dosage  in  self.dosageAmounts) {
        if ([dosage.amount floatValue] == 0) {
            answer = dosage;
            break;
        }
    }
    return  answer;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell  *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.selectedIndex == nil) {
        self.selectedIndex = indexPath;
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        UITableViewCell  *oldSelectedCell = [tableView cellForRowAtIndexPath:self.selectedIndex];
        if (selectedCell == oldSelectedCell) {
            selectedCell.accessoryType = UITableViewCellAccessoryNone;
            self.selectedIndex = nil;
        } else {
            oldSelectedCell.accessoryType = UITableViewCellAccessoryNone;
            selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedIndex = indexPath;
        }
    }
}

- (CGFloat)tableView:(UITableView *) __unused tableView heightForRowAtIndexPath:(NSIndexPath *) __unused indexPath
{
    return  kAPCMedicationRowHeight;
}

- (CGFloat)tableView:(UITableView *) __unused tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat  answer = 0;
    
    if (section == 0) {
        answer = kSectionHeaderHeight;
    }
    return  answer;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView  *view = nil;
    
    if (section == 0) {
        CGFloat  width  = CGRectGetWidth(tableView.frame);
        CGFloat  height = [self tableView:tableView heightForHeaderInSection:section];
        CGRect   frame  = CGRectMake(0.0, 0.0, width, height);
        view = [[UIView alloc] initWithFrame:frame];
        view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        
        frame.origin.x = kSectionHeaderLabelOffset;
        frame.size.width = frame.size.width - 2.0 * kSectionHeaderLabelOffset;
        UILabel  *label = [[UILabel alloc] initWithFrame:frame];
        label.numberOfLines = 2;
        label.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = NSLocalizedString(@"Select Your Medication's Single Dose Amount", nil);
        [view addSubview:label];
    }
    return  view;
}

- (void)setupIndexPathForDosageDescriptor:(APCMedTrackerPossibleDosage *)record
{
    for (NSUInteger  index = 0;  index < [self.dosageAmounts count];  index++) {
        APCMedTrackerPossibleDosage  *dosage = self.dosageAmounts[index];
        if ([dosage.name isEqualToString:record.name] == YES) {
            NSIndexPath  *path = [NSIndexPath indexPathForRow:index inSection:0];
            self.selectedIndex = path;
            break;
        }
    }
}

#pragma  mark  -  View Controller Methods

- (NSString *)title
{
    return  kViewControllerName;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.doneButtonWasTapped == NO) {
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(dosageControllerDidCancel:)] == YES) {
                [self.delegate performSelector:@selector(dosageControllerDidCancel:) withObject:self];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabulator.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIBarButtonItem  *donester = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.rightBarButtonItem = donester;
    
    self.dosageAmounts = [NSArray array];
    
    [APCMedTrackerPossibleDosage fetchAllFromCoreDataAndUseThisQueue: [NSOperationQueue mainQueue]
                                                    toDoThisWhenDone: ^(NSArray *arrayOfGeneratedObjects,
                                                                        NSTimeInterval  __unused operationDuration,
                                                                        NSError *error)
     {
         if (error != nil) {
             APCLogError2(error);
         } else {
             NSSortDescriptor *amountSorter = [[NSSortDescriptor alloc] initWithKey:@"amount" ascending:YES];
             NSArray  *descriptors = @[ amountSorter ];
             self.dosageAmounts = [arrayOfGeneratedObjects sortedArrayUsingDescriptors:descriptors];
             if (self.dosageRecord != nil) {
                 [self setupIndexPathForDosageDescriptor:self.dosageRecord];
             }
             [self.tabulator reloadData];
         }
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
