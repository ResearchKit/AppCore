//
//  APCMedicationNameViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationNameViewController.h"

#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerMedication+Helper.h"
#import "APCMedicationNameTableViewCell.h"

#import "NSBundle+Helper.h"

#import "APCLog.h"

static  NSString  *kViewControllerName       = @"Medication Name";

static  NSString  *kMedicationNameTableCell  = @"APCMedicationNameTableViewCell";

static  CGFloat    kNumberOfSectionsInTable  =  1.0;

static  CGFloat    kSectionHeaderHeight      = 77.0;
static  CGFloat    kSectionHeaderLabelOffset = 10.0;

static  CGFloat    kAPCMedicationRowHeight   = 64.0;

@interface APCMedicationNameViewController  ( )  <UITableViewDataSource, UITableViewDelegate>

@property  (nonatomic, weak)  IBOutlet  UITableView      *tabulator;

@property  (nonatomic, weak)            UIBarButtonItem  *donester;

@property  (nonatomic, strong)          NSArray          *medicationList;

@property  (nonatomic, strong)          NSIndexPath      *selectedIndex;

@end

@implementation APCMedicationNameViewController

#pragma  mark  -  Navigation Bar Button Action Methods

- (void)doneButtonTapped:(UIBarButtonItem *) __unused sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma  mark  -  Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *) __unused tableView
{
    return  kNumberOfSectionsInTable;
}

- (NSInteger)tableView:(UITableView *) __unused tableView numberOfRowsInSection:(NSInteger) __unused section
{
    NSInteger  numberOfRows = [self.medicationList count];
    return  numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCMedicationNameTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:kMedicationNameTableCell];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    APCMedTrackerMedication  *medication = self.medicationList[indexPath.row];
    NSString  *medicationName = medication.name;
    NSRange  range = [medicationName rangeOfString:@" ("];
    NSString  *firstString = nil;
    NSString  *secondString = nil;
    if (range.location == NSNotFound) {
        firstString = medicationName;
        cell.topLabel.hidden    = YES;
        cell.middleLabel.hidden = NO;
        cell.bottomLabel.hidden = YES;
        cell.middleLabel.text   = firstString;
    } else {
        firstString = [medicationName substringToIndex:range.location];
        secondString = [medicationName substringFromIndex:(range.location + 1)];
        cell.topLabel.hidden    = NO;
        cell.middleLabel.hidden = YES;
        cell.bottomLabel.hidden = NO;
        cell.topLabel.text      = firstString;
        cell.bottomLabel.text   = secondString;
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell  *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.selectedIndex == nil) {
        self.selectedIndex = indexPath;
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.donester.enabled = YES;
    } else {
        UITableViewCell  *oldSelectedCell = [tableView cellForRowAtIndexPath:self.selectedIndex];
        if (selectedCell == oldSelectedCell) {
            selectedCell.accessoryType = UITableViewCellAccessoryNone;
            self.selectedIndex = nil;
            self.donester.enabled = NO;
        } else {
            oldSelectedCell.accessoryType = UITableViewCellAccessoryNone;
            selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedIndex = indexPath;
            self.donester.enabled = YES;
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
        label.text = NSLocalizedString(@"Select the Medication You Are Currently Taking", nil);
        [view addSubview:label];
    }
    return  view;
}

- (void)setupIndexPathForMedicationDescriptor:(APCMedTrackerMedication *)aMedicationRecord
{
    for (NSUInteger  index = 0;  index < [self.self.medicationList count];  index++) {
        APCMedTrackerMedication  *medication = self.medicationList[index];
        if ([medication.name isEqualToString:aMedicationRecord.name] == YES) {
            NSIndexPath  *path = [NSIndexPath indexPathForRow:index inSection:0];
            self.selectedIndex = path;
            break;
        }
    }
}

- (CGFloat)tableView:(UITableView *) __unused tableView heightForRowAtIndexPath:(NSIndexPath *) __unused indexPath
{
    return  kAPCMedicationRowHeight;
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
    
    UIBarButtonItem  *donester = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
    self.donester = donester;
    self.navigationItem.rightBarButtonItem = self.donester;
    self.donester.enabled = NO;
    
    UINib  *medicationNameTableCellNib = [UINib nibWithNibName:kMedicationNameTableCell bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:medicationNameTableCellNib forCellReuseIdentifier:kMedicationNameTableCell];
    
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
             NSArray  *sorted = [arrayOfGeneratedObjects sortedArrayUsingDescriptors:descriptors];
             
             NSMutableArray  *copyOfSorted = [sorted mutableCopy];
             APCMedTrackerMedication  *foundMedication = nil;
             NSUInteger  foundIndex = 0;
             for (NSUInteger  index = 0;  index < [copyOfSorted count];  index++) {
                 APCMedTrackerMedication  *medication = [copyOfSorted objectAtIndex:index];
                 if ([medication.name isEqualToString:@"Other"] == YES) {
                     foundMedication = medication;
                     foundIndex = index;
                     break;
                 }
             }
             if (foundMedication != nil) {
                 [copyOfSorted removeObjectAtIndex:foundIndex];
                 [copyOfSorted addObject:foundMedication];
             }
             self.medicationList = copyOfSorted;
             
             if (self.medicationRecord != nil) {
                 [self setupIndexPathForMedicationDescriptor:self.medicationRecord];
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
