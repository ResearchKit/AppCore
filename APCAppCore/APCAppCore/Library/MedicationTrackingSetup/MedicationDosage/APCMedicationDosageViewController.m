//
//  APCMedicationDosageViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationDosageViewController.h"

#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerPossibleDosage+Helper.h"

#import "APCLog.h"

static  NSString  *kViewControllerName = @"Medication Dosages";

@interface APCMedicationDosageViewController  ( )  <UITableViewDataSource, UITableViewDelegate>

@property  (nonatomic, weak)  IBOutlet  UITableView  *tabulator;

@property  (nonatomic, strong)          NSArray      *dosageAmounts;

@property  (nonatomic, strong)          NSIndexPath  *selectedIndex;

@end

@implementation APCMedicationDosageViewController

#pragma  mark  -  Toolbar Button Action Methods

- (IBAction)cancelButtonTapped:(UIBarButtonItem *) __unused sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)doneButtonTapped:(UIBarButtonItem *) __unused sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
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

- (NSString *)tableView:(UITableView *) __unused tableView titleForHeaderInSection:(NSInteger) __unused section
{
    NSString  *title = NSLocalizedString(@"Select Your Medication's Single Dose Amount", nil);
    return  title;
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
    APCMedTrackerPossibleDosage  *dosage = nil;
    if (self.selectedIndex == nil) {
        dosage = [self findDosageWithZeroAmount];
    } else {
        dosage = self.dosageAmounts[indexPath.row];
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(dosageController:didSelectDosageAmount:)] == YES) {
                [self.delegate performSelector:@selector(dosageController:didSelectDosageAmount:) withObject:self withObject:dosage];
            }
        }
    }
}

#pragma  mark  -  View Controller Methods

- (NSString *)title
{
    return  kViewControllerName;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabulator.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
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
             [self.tabulator reloadData];
         }
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
