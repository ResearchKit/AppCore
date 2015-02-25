//
//  APCMedicationTrackerSetupViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
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

#import "APCMedicationSummaryTableViewCell.h"

#import "APCSetupTableViewCell.h"

typedef  enum  _SetupTableRowTypes
{
    SetupTableRowTypesName = 0,
    SetupTableRowTypesFrequency,
    SetupTableRowTypesLabelColor,
    SetupTableRowTypesDosage
}  SetupTableRowTypes;

static  NSString  *kViewControllerName   = @"Set Up Medications";

static  NSString  *kSetupTableCellName   = @"APCSetupTableViewCell";

static  NSString  *kSummaryTableViewCell = @"APCMedicationSummaryTableViewCell";

static  NSInteger  kAPCMedicationNameRow      = 0;
static  NSInteger  kAPCMedicationFrequencyRow = 1;
static  NSInteger  kAPCMedicationColorRow     = 2;
static  NSInteger  kAPCMedicationDosageRow    = 3;

static  NSString  *mainTableCategories[]          = { @"Name",        @"Frequency",     @"Label Color",  @"Dosage (optional)"        };
static  NSInteger  kNumberOfMainTableCategories = (sizeof(mainTableCategories) / sizeof(NSString *));

static  NSString  *addTableCategories[]           = { @"Select Name", @"Add Frequency", @"Select Color", @"Select Dosage" };

static  NSString  *mainColorCategories[]          = { @"Red", @"Green", @"Blue", @"Yellow", @"Cyan", @"Magenta", @"Orange", @"Purple" };

static  NSString  *daysOfWeekNames[]              = { @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday" };
static  NSString  *daysOfWeekNamesAbbreviations[] = { @"Mon",    @"Tue",     @"Wed",       @"Thu",      @"Fri",    @"Sat",      @"Sun"    };
static  NSUInteger  numberOfDaysOfWeek = (sizeof(daysOfWeekNames) / sizeof(NSString *));

@interface APCMedicationTrackerSetupViewController  ( )  <UITableViewDataSource, UITableViewDelegate,
                                                APCMedicationNameViewControllerDelegate, APCMedicationFrequencyViewControllerDelegate,
                                                APCMedicationColorViewControllerDelegate, APCMedicationDosageViewControllerDelegate>

@property  (nonatomic, weak)  IBOutlet  UITableView             *setupTabulator;
@property  (nonatomic, weak)  IBOutlet  UITableView             *listTabulator;

@property  (nonatomic, weak)  IBOutlet  UIButton                *doneButton;

@property  (nonatomic, assign)          BOOL                     medicationNameWasSet;
@property  (nonatomic, assign)          BOOL                     medicationColorWasSet;
@property  (nonatomic, assign)          BOOL                     medicationFrequencyWasSet;
@property  (nonatomic, assign)          BOOL                     medicationDosageWasSet;

@property  (nonatomic, strong)          NSIndexPath             *selectedIndexPath;

@property  (nonatomic, strong)          NSMutableArray          *currentMedicationRecords;

@property (nonatomic, strong)           APCMedTrackerMedication  *theMedicationObject;
@property (nonatomic, strong)           APCMedTrackerPossibleDosage  *possibleDosage;
@property (nonatomic, strong)           APCMedTrackerPrescriptionColor  *colorObject;
@property (nonatomic, strong)           NSDictionary             *frequenciesAndDaysObject;

@end

@implementation APCMedicationTrackerSetupViewController

#pragma  mark  -  Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger  numberOfRows = 0;
    
    if (tableView == self.setupTabulator) {
        numberOfRows = kNumberOfMainTableCategories;
    } else if (tableView == self.listTabulator) {
        numberOfRows = [self.currentMedicationRecords count];
    }
    return  numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString  *title = nil;
    
    if (tableView == self.setupTabulator) {
        title = @"Add Your Medication Details";
    } else if (tableView == self.listTabulator) {
        title = nil;
    }
    
    return  title;
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

- (void)formatCellTopicForRow:(SetupTableRowTypes)row withCell:(APCSetupTableViewCell *)aCell
{
    aCell.addTopicLabel.hidden = NO;
    aCell.colorSwatch.hidden   = YES;
    if (row == SetupTableRowTypesName) {
        if (self.medicationNameWasSet == YES) {
            aCell.addTopicLabel.text = self.theMedicationObject.name;
            [aCell setNeedsDisplay];
        } else {
            aCell.addTopicLabel.text = addTableCategories[row];
        }
    } else if (row == SetupTableRowTypesFrequency) {
        if (self.medicationFrequencyWasSet == YES) {
            aCell.addTopicLabel.text = [self formatNumbersAndDays:self.frequenciesAndDaysObject];
        } else {
            aCell.addTopicLabel.text = addTableCategories[row];
        }
    } else if (row == SetupTableRowTypesLabelColor) {
        if (self.medicationColorWasSet == YES) {
            aCell.addTopicLabel.hidden = YES;
            aCell.colorSwatch.hidden   = NO;
            aCell.colorSwatch.backgroundColor = self.colorObject.UIColor;
        } else {
            aCell.addTopicLabel.text = addTableCategories[row];
        }
    } else if (row == SetupTableRowTypesDosage) {
        if (self.medicationDosageWasSet == YES) {
            aCell.addTopicLabel.text = self.possibleDosage.name;
        } else {
            aCell.addTopicLabel.text = addTableCategories[row];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell  *cell = nil;
        //
        //    if we re-instate the summary table,
        //        we will need to revisit the code in the listTabulator branch
        //
    if (tableView == self.setupTabulator) {
        APCSetupTableViewCell  *aCell = (APCSetupTableViewCell *)[self.setupTabulator dequeueReusableCellWithIdentifier:kSetupTableCellName];
        aCell.topicLabel.text = mainTableCategories[indexPath.row];
        [self formatCellTopicForRow:(SetupTableRowTypes)indexPath.row withCell:aCell];
        cell = aCell;
    } else if (tableView == self.listTabulator) {
        APCMedicationSummaryTableViewCell  *aCell = (APCMedicationSummaryTableViewCell *)[self.listTabulator dequeueReusableCellWithIdentifier:kSummaryTableViewCell];
        aCell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString  *usesAndDays = [self formatNumbersAndDays:self.frequenciesAndDaysObject];
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
            [self.navigationController pushViewController:controller animated:YES];
        } else if (indexPath.row == kAPCMedicationFrequencyRow) {
            APCMedicationFrequencyViewController  *controller = [[APCMedicationFrequencyViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
            controller.delegate = self;
            [self.navigationController pushViewController:controller animated:YES];
        } else if (indexPath.row == kAPCMedicationColorRow) {
            APCMedicationColorViewController  *controller = [[APCMedicationColorViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
            controller.delegate = self;
            [self.navigationController pushViewController:controller animated:YES];
        } else if (indexPath.row == kAPCMedicationDosageRow) {
            APCMedicationDosageViewController  *controller = [[APCMedicationDosageViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
            controller.delegate = self;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma  mark  -  Add New Medication Method

- (void)addNewMedication:(id)sender
{
    self.medicationNameWasSet      = NO;
    self.medicationColorWasSet     = NO;
    self.medicationFrequencyWasSet = NO;
    self.medicationDosageWasSet    = NO;
}

#pragma  mark  -  Finished Button Action Method

- (IBAction)finishedButtonWasTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma  mark  -  Done Button Action Method

- (IBAction)doneButtonWasTapped:(id)sender
{
    [self.listTabulator reloadData];
    
    [APCMedTrackerPrescription newPrescriptionWithMedication: self.theMedicationObject
                                                        dosage: self.possibleDosage
                                                         color: self.colorObject
                                            frequencyAndDays: self.frequenciesAndDaysObject
                                               andUseThisQueue: [NSOperationQueue mainQueue]
                                              toDoThisWhenDone: ^(id createdObject,
                                                                  NSTimeInterval operationDuration)
    {
                                              }];
    self.medicationNameWasSet      = NO;
    self.medicationColorWasSet     = NO;
    self.medicationFrequencyWasSet = NO;
    self.medicationDosageWasSet    = NO;
    [self.setupTabulator reloadData];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.doneButton.enabled = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)enableDoneButtonIfValuesSet
{
    if ((self.medicationNameWasSet == YES) && (self.medicationColorWasSet == YES) &&
        (self.medicationFrequencyWasSet == YES)) {
        self.doneButton.enabled = YES;
    }
}

#pragma  mark  -  Delegate Methods Of Subordinate Setup Screens

- (void)nameController:(APCMedicationNameViewController *)nameController didSelectMedicineName:(APCMedTrackerMedication *)medicationObject
{
    self.theMedicationObject = medicationObject;
    self.medicationNameWasSet = YES;
    [self enableDoneButtonIfValuesSet];
    [self.setupTabulator reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:SetupTableRowTypesName inSection:0] ] withRowAnimation:NO];
}

- (void)frequencyController:(APCMedicationFrequencyViewController *)frequencyController didSelectFrequency:(NSDictionary *)daysAndNumbers
{
    self.frequenciesAndDaysObject = daysAndNumbers;
    self.medicationFrequencyWasSet = YES;
    [self enableDoneButtonIfValuesSet];
    [self.setupTabulator reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:SetupTableRowTypesFrequency inSection:0] ] withRowAnimation:NO];
}

- (void)colorController:(APCMedicationColorViewController *)colorController didSelectColorLabelName:(APCMedTrackerPrescriptionColor *)colorObject
{
    self.colorObject = colorObject;
    self.medicationColorWasSet = YES;
    [self enableDoneButtonIfValuesSet];
    [self.setupTabulator reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:SetupTableRowTypesLabelColor inSection:0] ] withRowAnimation:NO];
}

- (void)dosageController:(APCMedicationDosageViewController *)dosageController didSelectDosageAmount:(APCMedTrackerPossibleDosage *)dosageAmount
{
    self.possibleDosage = dosageAmount;
    self.medicationDosageWasSet = YES;
    [self.setupTabulator reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:SetupTableRowTypesDosage inSection:0] ] withRowAnimation:NO];
}

#pragma  mark  -  View Controller Methods

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
    
    self.setupTabulator.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.listTabulator.tableFooterView  = [[UIView alloc] initWithFrame:CGRectZero];
    
    UINib  *setupTableCellNib = [UINib nibWithNibName:kSetupTableCellName bundle:[NSBundle appleCoreBundle]];
    [self.setupTabulator registerNib:setupTableCellNib forCellReuseIdentifier:kSetupTableCellName];
    
    UINib  *summaryCellNib = [UINib nibWithNibName:kSummaryTableViewCell bundle:[NSBundle appleCoreBundle]];
    [self.listTabulator registerNib:summaryCellNib forCellReuseIdentifier:kSummaryTableViewCell];
    
    self.currentMedicationRecords = [NSMutableArray array];
    
    [APCMedTrackerDataStorageManager startupReloadingDefaults:YES andThenUseThisQueue:nil toDoThis:NULL];
    self.theMedicationObject = nil;
    
    self.doneButton.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
