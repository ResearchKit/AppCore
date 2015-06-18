// 
//  APCMedicationTrackerSetupViewController.m 
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
 
#import "APCMedicationTrackerSetupViewController.h"
#import "APCMedicationColorViewController.h"
#import "APCMedicationDosageViewController.h"
#import "APCMedicationFrequencyViewController.h"
#import "APCMedicationNameViewController.h"

#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerMedication+Helper.h"
#import "APCMedTrackerPrescription+Helper.h"
#import "APCMedTrackerPossibleDosage+Helper.h"
#import "APCMedTrackerPrescriptionColor+Helper.h"

#import "NSBundle+Helper.h"
#import "NSDictionary+APCAdditions.h"

#import "APCMedicationSummaryTableViewCell.h"

#import "APCSetupTableViewCell.h"
#import "APCSetupButtonTableViewCell.h"
#import "APCButton.h"

typedef  enum  _SetupTableRowTypes
{
    SetupTableRowTypesName = 0,
    SetupTableRowTypesFrequency,
    SetupTableRowTypesLabelColor,
    SetupTableRowTypesDosage
}  SetupTableRowTypes;

static  NSString  *kViewControllerName            = @"Set Up Medications";

static  NSString  *kSetupTableCellName            = @"APCSetupTableViewCell";
static  NSString  *kSetupTableButtonCellName      = @"APCSetupButtonTableViewCell";

static  NSString  *kSummaryTableViewCell          = @"APCMedicationSummaryTableViewCell";

static  NSInteger  kNumberOfSectionsInTable       =  1;

static  NSInteger  kAPCMedicationNameRow          =  0;
static  NSInteger  kAPCMedicationFrequencyRow     =  1;
static  NSInteger  kAPCMedicationColorRow         =  2;

static  NSInteger  kAPCMedicationButtonRow        =  3;

static  CGFloat    kAPCMedicationRowHeight        = 64.0;
static  CGFloat    kAPCDoneButtonRowHeight        = 88.0;

static  NSString  *mainTableCategories[]          = { @"Name",        @"Frequency",     @"Label Color" };
static  NSInteger  kNumberOfMainTableCategories   = (sizeof(mainTableCategories) / sizeof(NSString *));
static  NSString  *extraTableCategories[]         = { @"Required",    @"Required",      @"Optional" };

static  CGFloat    kSectionHeaderHeight           = 77.0;
static  CGFloat    kSectionHeaderLabelOffset      = 10.0;

static  NSString  *addTableCategories[]           = { @"Select Name", @"Select Frequency", @"Select Color" };

@interface APCMedicationTrackerSetupViewController  ( )  <UITableViewDataSource, UITableViewDelegate,
                                                APCMedicationNameViewControllerDelegate, APCMedicationFrequencyViewControllerDelegate,
                                                APCMedicationColorViewControllerDelegate>

@property  (nonatomic, weak)  IBOutlet  UITableView                     *setupTabulator;
@property  (nonatomic, weak)  IBOutlet  UITableView                     *listTabulator;

@property  (nonatomic, weak)            UIButton                        *doneButton;

@property  (nonatomic, strong)          NSIndexPath                     *selectedIndexPath;

@property  (nonatomic, strong)          NSMutableArray                  *currentMedicationRecords;
@property  (nonatomic, strong)          APCMedTrackerMedication         *theMedicationObject;
@property  (nonatomic, assign)          BOOL                             medicationNameWasSet;

@property  (nonatomic, strong)          NSDictionary                    *frequenciesAndDaysObject;
@property  (nonatomic, assign)          BOOL                             medicationFrequencyWasSet;

@property  (nonatomic, strong)          APCMedTrackerPrescriptionColor  *defaultColorObject;
@property  (nonatomic, strong)          APCMedTrackerPrescriptionColor  *selectedColorObject;
@property  (nonatomic, strong)          NSArray                         *colorsList;
@property  (nonatomic, assign)          BOOL                             medicationColorWasSet;

@property  (nonatomic, strong)          APCMedTrackerPossibleDosage     *defaultPossibleDosage;

@property  (nonatomic, copy)            NSBundle                        *resourceBundle;
@property  (nonatomic, copy)            NSDictionary                    *resourceNames;

@end

@implementation APCMedicationTrackerSetupViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
             withResourceBundle:(NSBundle *)resourceBundle
               andResourceNames:(NSDictionary *)resourceNames
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _resourceBundle = resourceBundle;
        _resourceNames = resourceNames;
    }
    
    return self;
}

#pragma  mark  -  Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *) __unused tableView
{
    return  kNumberOfSectionsInTable;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) __unused section
{
    NSInteger  numberOfRows = 0;
    
    if (tableView == self.setupTabulator) {
        numberOfRows = kNumberOfMainTableCategories + 1;    //    plus one for the 'Done' Button
    } else if (tableView == self.listTabulator) {
        numberOfRows = [self.currentMedicationRecords count];
    }
    return  numberOfRows;
}

- (void)formatCellTopicForRow:(SetupTableRowTypes)row withCell:(APCSetupTableViewCell *)aCell
{
    aCell.addTopicLabel.hidden = NO;
    aCell.colorSwatch.hidden   = YES;
    if (row == SetupTableRowTypesName) {
        if (self.medicationNameWasSet) {
            aCell.addTopicLabel.text = self.theMedicationObject.name;
            [aCell setNeedsDisplay];
        } else {
            aCell.addTopicLabel.text = addTableCategories[row];
        }
    } else if (row == SetupTableRowTypesFrequency) {
        if (self.medicationFrequencyWasSet) {
            aCell.addTopicLabel.text = [self.frequenciesAndDaysObject formatNumbersAndDays];
        } else {
            aCell.addTopicLabel.text = addTableCategories[row];
        }
    } else if (row == SetupTableRowTypesLabelColor) {
        if (self.medicationColorWasSet) {
            aCell.addTopicLabel.hidden = NO;
            aCell.colorSwatch.hidden   = NO;
            aCell.addTopicLabel.text = self.selectedColorObject.name;
            aCell.colorSwatch.backgroundColor = self.selectedColorObject.UIColor;
        } else {
            aCell.addTopicLabel.text = addTableCategories[row];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat  height = kAPCMedicationRowHeight;
    
    if (tableView == self.setupTabulator) {
        if (indexPath.row == kAPCMedicationButtonRow) {
            height = kAPCDoneButtonRowHeight;
        }
    }
    return  height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell  *cell = nil;
        //
        //    if we re-instate the summary table,
        //        we will need to revisit the code in the listTabulator branch
        //
    if (tableView == self.setupTabulator) {
        if (indexPath.row < kAPCMedicationButtonRow) {
            APCSetupTableViewCell  *aCell = (APCSetupTableViewCell *)[self.setupTabulator dequeueReusableCellWithIdentifier:kSetupTableCellName];
            aCell.topicLabel.text = mainTableCategories[indexPath.row];
            aCell.extraLabel.text = extraTableCategories[indexPath.row];
            CGRect  frame = aCell.separator.frame;
            frame.size.height = 0.5;
            aCell.separator.frame = frame;
            [self formatCellTopicForRow:(SetupTableRowTypes)indexPath.row withCell:aCell];
            cell = aCell;
        } else {
            APCSetupButtonTableViewCell  *aCell = (APCSetupButtonTableViewCell *)[self.setupTabulator dequeueReusableCellWithIdentifier:kSetupTableButtonCellName];
            aCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.doneButton = aCell.doneButton;
            self.doneButton.enabled = NO;
            [aCell.doneButton addTarget:self action:@selector(doneButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
            [aCell.doneButton setTitle:@"Done" forState:UIControlStateNormal];
            cell = aCell;
        }
    } else if (tableView == self.listTabulator) {
        APCMedicationSummaryTableViewCell  *aCell = (APCMedicationSummaryTableViewCell *)[self.listTabulator dequeueReusableCellWithIdentifier:kSummaryTableViewCell];
        aCell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString  *usesAndDays = [self.frequenciesAndDaysObject formatNumbersAndDays];
        aCell.medicationUseDays.text = usesAndDays;
        cell = aCell;
    }
    return  cell;
}

#pragma  mark  -  Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.setupTabulator) {
        self.selectedIndexPath = indexPath;
        if (indexPath.row == kAPCMedicationNameRow) {
            APCMedicationNameViewController  *controller = [[APCMedicationNameViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
            controller.delegate = self;
            if ((self.theMedicationObject != nil) && (self.medicationNameWasSet)) {
                controller.medicationRecord = self.theMedicationObject;
            }
            [self.navigationController pushViewController:controller animated:YES];
        } else if (indexPath.row == kAPCMedicationFrequencyRow) {
            APCMedicationFrequencyViewController  *controller = [[APCMedicationFrequencyViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
            controller.delegate = self;
            if ((self.frequenciesAndDaysObject != nil) && (self.medicationFrequencyWasSet)) {
                controller.daysNumbersDictionary = self.frequenciesAndDaysObject;
            }
            [self.navigationController pushViewController:controller animated:YES];
        } else if (indexPath.row == kAPCMedicationColorRow) {
            APCMedicationColorViewController  *controller = [[APCMedicationColorViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
            controller.delegate = self;
            if ((self.selectedColorObject != nil) && (self.medicationColorWasSet)){
                controller.oneColorDescriptor = self.selectedColorObject;
            }
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
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
        label.text = NSLocalizedString(@"Add Your Medication Details", nil);;
        [view addSubview:label];
    }
    return  view;
}

- (CGFloat)tableView:(UITableView *) __unused tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat  answer = 0;
    
    if (section == 0) {
        answer = kSectionHeaderHeight;
    }
    return  answer;
}

#pragma  mark  -  Done Button Action Method

- (void)doneButtonWasTapped:(id) __unused sender
{
    [self.listTabulator reloadData];
    
    if (self.selectedColorObject == nil) {
        self.selectedColorObject = self.defaultColorObject;
    }

    [APCMedTrackerPrescription newPrescriptionWithMedication: self.theMedicationObject
                                                        dosage: self.defaultPossibleDosage
                                                         color: self.selectedColorObject
                                            frequencyAndDays: self.frequenciesAndDaysObject
                                               andUseThisQueue: [NSOperationQueue mainQueue]
                                              toDoThisWhenDone: ^(id __unused createdObject,
                                                                  NSTimeInterval __unused operationDuration)
    {
                                              }];
    self.medicationNameWasSet      = NO;
    self.medicationColorWasSet     = NO;
    self.medicationFrequencyWasSet = NO;
    [self.setupTabulator reloadData];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.doneButton.enabled = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)enableDoneButtonIfValuesSet
{
    if ((self.medicationNameWasSet) && (self.medicationFrequencyWasSet)) {
        self.doneButton.enabled = YES;
    }
}

#pragma  mark  -  Delegate Methods Of Subordinate Setup Screens

#pragma  mark  -  Medication Name Delegates

- (void)nameController:(APCMedicationNameViewController *) __unused nameController didSelectMedicineName:(APCMedTrackerMedication *)medicationObject
{
    self.theMedicationObject = medicationObject;
    self.medicationNameWasSet = YES;
    [self enableDoneButtonIfValuesSet];
    [self.setupTabulator reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:SetupTableRowTypesName inSection:0] ] withRowAnimation:YES];
}

- (void)nameControllerDidCancel:(APCMedicationNameViewController *) __unused nameController
{
    self.medicationNameWasSet = NO;
    [self enableDoneButtonIfValuesSet];
    [self.setupTabulator reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:SetupTableRowTypesName inSection:0] ] withRowAnimation:YES];
}

#pragma  mark  -          Frequency and Days Delegates

- (void)frequencyController:(APCMedicationFrequencyViewController *) __unused frequencyController didSelectFrequency:(NSDictionary *)daysAndNumbers
{
    self.frequenciesAndDaysObject = daysAndNumbers;
    self.medicationFrequencyWasSet = YES;
    [self enableDoneButtonIfValuesSet];
    [self.setupTabulator reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:SetupTableRowTypesFrequency inSection:0] ] withRowAnimation:YES];
}

- (void)frequencyControllerDidCancel:(APCMedicationFrequencyViewController *) __unused frequencyController
{
    self.medicationFrequencyWasSet = NO;
    [self enableDoneButtonIfValuesSet];
    [self.setupTabulator reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:SetupTableRowTypesFrequency inSection:0] ] withRowAnimation:YES];
}

#pragma  mark  -          Color Label Delegates

- (void)colorController:(APCMedicationColorViewController *) __unused colorController didSelectColorLabelName:(APCMedTrackerPrescriptionColor *)colorObject
{
    self.selectedColorObject = colorObject;
    self.medicationColorWasSet = YES;
    [self enableDoneButtonIfValuesSet];
    [self.setupTabulator reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:SetupTableRowTypesLabelColor inSection:0] ] withRowAnimation:YES];
}

- (void)colorControllerDidCancel:(APCMedicationColorViewController *) __unused colorController
{
    self.medicationColorWasSet = NO;
    self.selectedColorObject = nil;
    [self.setupTabulator reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:SetupTableRowTypesLabelColor inSection:0] ] withRowAnimation:YES];
}

#pragma  mark  -  View Controller Methods  kSetupTableButtonCellName

- (NSString *)title
{
    return  kViewControllerName;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.selectedIndexPath != nil) {
        [self.setupTabulator deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    }
    self.selectedIndexPath = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = kViewControllerName;
    
    UINib  *setupTableCellNib = [UINib nibWithNibName:kSetupTableCellName bundle:[NSBundle appleCoreBundle]];
    [self.setupTabulator registerNib:setupTableCellNib forCellReuseIdentifier:kSetupTableCellName];
    
    UINib  *setupTableButtonCellNib = [UINib nibWithNibName:kSetupTableButtonCellName bundle:[NSBundle appleCoreBundle]];
    [self.setupTabulator registerNib:setupTableButtonCellNib forCellReuseIdentifier:kSetupTableButtonCellName];
    
    UINib  *summaryCellNib = [UINib nibWithNibName:kSummaryTableViewCell bundle:[NSBundle appleCoreBundle]];
    [self.listTabulator registerNib:summaryCellNib forCellReuseIdentifier:kSummaryTableViewCell];
    
    self.currentMedicationRecords = [NSMutableArray array];
    
    
    if (self.resourceBundle && self.resourceNames) {
        [APCMedTrackerDataStorageManager startupWithCustomDataInBundle:self.resourceBundle
                                                     withResourceNames:self.resourceNames
                                                   andThenUseThisQueue:nil
                                                              toDoThis:NULL];
    } else {
        [APCMedTrackerDataStorageManager startupReloadingDefaults:YES andThenUseThisQueue:nil toDoThis:NULL];
    }
    
    self.theMedicationObject = nil;
    
    self.doneButton.enabled = NO;
    
    self.medicationNameWasSet      = NO;
    self.medicationColorWasSet     = NO;
    self.medicationFrequencyWasSet = NO;
    
    [APCMedTrackerPossibleDosage fetchAllFromCoreDataAndUseThisQueue: [NSOperationQueue mainQueue]
                                                    toDoThisWhenDone: ^(NSArray *arrayOfGeneratedObjects,
                                                                        NSTimeInterval __unused operationDuration,
                                                                        NSError __unused *error)
     {
         NSSortDescriptor *amountSorter = [[NSSortDescriptor alloc] initWithKey:@"amount" ascending:YES];
         NSArray  *descriptors = @[ amountSorter ];
         NSArray  *sorted = [arrayOfGeneratedObjects sortedArrayUsingDescriptors:descriptors];
         self.defaultPossibleDosage = [sorted lastObject];
    }];
    
    self.colorsList = [NSArray array];
    
    [APCMedTrackerPrescriptionColor fetchAllFromCoreDataAndUseThisQueue: [NSOperationQueue mainQueue]
                                                       toDoThisWhenDone: ^(NSArray *arrayOfGeneratedObjects,
                                                                           NSTimeInterval  __unused operationDuration,
                                                                           NSError * __unused error)
     {
         self.colorsList = arrayOfGeneratedObjects;
         self.defaultColorObject = [self.colorsList lastObject];
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
