//
//  APCMedicationNameViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationNameViewController.h"

#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerMedication+Helper.h"

#import "APCLog.h"

static  NSString  *kViewControllerName = @"Medication Name";

@interface APCMedicationNameViewController  ( )  <UITableViewDataSource, UITableViewDelegate>

@property  (nonatomic, weak)  IBOutlet  UITableView  *tabulator;

@property  (nonatomic, strong)          NSArray      *medicationList;

@property  (nonatomic, strong)          NSIndexPath  *selectedIndex;

@end

@implementation APCMedicationNameViewController

#pragma  mark  -  Toolbar Button Action Methods

- (void)cancelButtonTapped:(UIBarButtonItem *) __unused sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)doneButtonTapped:(UIBarButtonItem *) __unused sender
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
    NSInteger  numberOfRows = [self.medicationList count];
    return  numberOfRows;
}

- (NSString *)tableView:(UITableView *) __unused tableView titleForHeaderInSection:(NSInteger) __unused section
{
    NSString  *title = NSLocalizedString(@"Select the Medication You Are Currently Taking", nil);
    return  title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString  *identifier = @"MedicationNameTableViewCell";
    
    UITableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    APCMedTrackerMedication  *medication = self.medicationList[indexPath.row];
    cell.textLabel.text = medication.name;
    
    return  cell;
}

#pragma  mark  -  Table View Delegate Methods

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
    if (self.selectedIndex != nil) {
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(nameController:didSelectMedicineName:)] == YES) {
                APCMedTrackerMedication  *medication = self.medicationList[indexPath.row];
                [self.delegate performSelector:@selector(nameController:didSelectMedicineName:) withObject:self withObject:medication];
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
    
    self.medicationList = [NSArray array];
    
    [APCMedTrackerMedication fetchAllFromCoreDataAndUseThisQueue: [NSOperationQueue mainQueue]
                                                toDoThisWhenDone: ^(NSArray *arrayOfGeneratedObjects,
                                                                    NSTimeInterval  __unused operationDuration,
                                                                    NSError *error)
     {
         if (error != nil) {
             APCLogError2(error);
         } else {
             NSSortDescriptor *nameSorter = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
             NSArray  *descriptors = @[ nameSorter ];
             self.medicationList = [arrayOfGeneratedObjects sortedArrayUsingDescriptors:descriptors];
            [self.tabulator reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
