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

#import "NSBundle+Helper.h"

#import "APCMedicationSummaryTableViewCell.h"

#import "APCMedicationModel.h"

#import "APCSetupTableViewCell.h"

#import "APCMedSetupNotificationKeys.h"

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

static  NSString  *mainTableCategories[]          = { @"Name",        @"Frequency",     @"Label Color",  @"Dosage"        };
static  NSString  *addTableCategories[]           = { @"Select Name", @"Add Frequency", @"Select Color", @"Select Dosage" };

static  NSString  *mainColorCategories[]          = { @"Red", @"Green", @"Blue", @"Yellow", @"Cyan", @"Magenta", @"Orange", @"Purple" };

static  NSString  *daysOfWeekNames[]              = { @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday" };
static  NSString  *daysOfWeekNamesAbbreviations[] = { @"Mon",    @"Tue",     @"Wed",       @"Thu",      @"Fri",    @"Sat",      @"Sun"    };
static  NSUInteger  numberOfDaysOfWeek = (sizeof(daysOfWeekNames) / sizeof(NSString *));

@interface APCMedicationTrackerSetupViewController  ( )  <UITableViewDataSource, UITableViewDelegate>

@property  (nonatomic, weak)  IBOutlet  UITableView             *setupTabulator;
@property  (nonatomic, weak)  IBOutlet  UITableView             *listTabulator;

@property  (nonatomic, weak)  IBOutlet  UIButton                *doneButton;

@property  (nonatomic, strong)          NSArray                 *classesToInstantiate;
@property  (nonatomic, strong)          NSArray                 *notificationNames;
@property  (nonatomic, strong)          NSArray                 *resultsDictionaryKeys;
@property  (nonatomic, strong)          NSArray                 *resultsNotificationSelectors;
@property  (nonatomic, strong)          NSDictionary            *colormap;

@property  (nonatomic, assign)          BOOL                     medicationNameWasSet;
@property  (nonatomic, assign)          BOOL                     medicationColorWasSet;
@property  (nonatomic, assign)          BOOL                     medicationFrequencyWasSet;
@property  (nonatomic, assign)          BOOL                     medicationDosageWasSet;

@property  (nonatomic, strong)          NSIndexPath             *selectedIndexPath;

//@property  (nonatomic, strong)          NSArray                 *medicationRecords;
@property  (nonatomic, strong)          NSMutableArray          *currentMedicationRecords;
@property  (nonatomic, strong)          APCMedicationModel      *currentMedicationModel;

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
        numberOfRows = [self.classesToInstantiate count];
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

- (NSString *)formatNumbersAndDays:(APCMedicationModel *)model
{
    NSDictionary  *frequencyAndDays = model.frequencyAndDays;
    
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
            aCell.addTopicLabel.text = self.currentMedicationModel.medicationName;
            [aCell setNeedsDisplay];
        } else {
            aCell.addTopicLabel.text = addTableCategories[row];
        }
    } else if (row == SetupTableRowTypesFrequency) {
        if (self.medicationFrequencyWasSet == YES) {
            aCell.addTopicLabel.text = [self formatNumbersAndDays:self.currentMedicationModel];
        } else {
            aCell.addTopicLabel.text = addTableCategories[row];
        }
    } else if (row == SetupTableRowTypesLabelColor) {
        if (self.medicationColorWasSet == YES) {
            aCell.addTopicLabel.hidden = YES;
            aCell.colorSwatch.hidden   = NO;
            aCell.colorSwatch.backgroundColor = self.colormap[self.currentMedicationModel.medicationLabelColor];
        } else {
            aCell.addTopicLabel.text = addTableCategories[row];
        }
    } else if (row == SetupTableRowTypesDosage) {
        if (self.medicationDosageWasSet == YES) {
            aCell.addTopicLabel.text = self.currentMedicationModel.medicationDosageText;
        } else {
            aCell.addTopicLabel.text = addTableCategories[row];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell  *cell = nil;
    
    if (tableView == self.setupTabulator) {
        APCSetupTableViewCell  *aCell = (APCSetupTableViewCell *)[self.setupTabulator dequeueReusableCellWithIdentifier:kSetupTableCellName];
        aCell.topicLabel.text = mainTableCategories[indexPath.row];
        [self formatCellTopicForRow:(SetupTableRowTypes)indexPath.row withCell:aCell];
        cell = aCell;
    } else if (tableView == self.listTabulator) {
        APCMedicationSummaryTableViewCell  *aCell = (APCMedicationSummaryTableViewCell *)[self.listTabulator dequeueReusableCellWithIdentifier:kSummaryTableViewCell];
        aCell.selectionStyle = UITableViewCellSelectionStyleNone;
        APCMedicationModel  *model = self.currentMedicationRecords[indexPath.row];
        aCell.medicationName.text = model.medicationName;
        aCell.colorswatch.backgroundColor = self.colormap[model.medicationLabelColor];
        aCell.medicationDosage.text = self.currentMedicationModel.medicationDosageText;
        NSString  *usesAndDays = [self formatNumbersAndDays:model];
        aCell.medicationUseDays.text = usesAndDays;
        cell = aCell;
    }
    return  cell;
}

#pragma  mark  -  Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
      SEL  selectors[] = {
        @selector(didReceiveNotificationOfNameResults:),
        @selector(didReceiveNotificationOfFrequencyResults:),
        @selector(didReceiveNotificationOfColorResults:),
        @selector(didReceiveNotificationOfDosageResults:),
    };
    if (tableView == self.setupTabulator) {
        if (indexPath.row < [self.classesToInstantiate count]) {
            Class  klass = self.classesToInstantiate[indexPath.row];
            UIViewController  *controller = [[klass alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
            self.selectedIndexPath = indexPath;
            
            NSNotificationCenter  *centre = [NSNotificationCenter defaultCenter];
            [centre addObserver:self selector:selectors[indexPath.row] name:self.notificationNames[indexPath.row] object:nil];
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma  mark  -  Add New Medication Method

- (void)addNewMedication:(id)sender
{
    self.currentMedicationModel = [[APCMedicationModel alloc] init];
    self.medicationNameWasSet      = NO;
    self.medicationColorWasSet     = NO;
    self.medicationFrequencyWasSet = NO;
    self.medicationDosageWasSet    = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma  mark  -  Done Button Action Method

- (IBAction)doneButtonWasTapped:(id)sender
{
    [self.currentMedicationRecords addObject:self.currentMedicationModel];
    [self.listTabulator reloadData];
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(medicationSetup:didCreateMedications:)] == YES) {
            [self.delegate performSelector:@selector(medicationSetup:didCreateMedications:) withObject:self withObject:self.currentMedicationRecords];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    self.medicationNameWasSet      = NO;
    self.medicationColorWasSet     = NO;
    self.medicationFrequencyWasSet = NO;
    self.medicationDosageWasSet    = NO;
    [self.setupTabulator reloadData];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.doneButton.enabled = NO;
}

#pragma  mark  -  Notification Methods

- (void)enableDoneButtonIfValuesSet
{
    if ((self.medicationNameWasSet == YES) && (self.medicationColorWasSet == YES) &&
        (self.medicationFrequencyWasSet == YES) &&  (self.medicationDosageWasSet == YES)) {
        self.doneButton.enabled = YES;
    }
}

- (void)didReceiveNotificationOfNameResults:(NSNotification *)notification
{
    NSDictionary  *info = notification.userInfo;
    
    NSString  *medicationName = info[APCMedSetupNameResultKey];
    self.currentMedicationModel.medicationName = medicationName;
    self.medicationNameWasSet = YES;
    [self enableDoneButtonIfValuesSet];
    [self.setupTabulator reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:SetupTableRowTypesName inSection:0] ] withRowAnimation:NO];
}

- (void)didReceiveNotificationOfFrequencyResults:(NSNotification *)notification
{
    NSDictionary  *info = notification.userInfo;
    
    NSDictionary  *frequencyInformation = info[APCMedSetupFrequencyResultKey];
    self.currentMedicationModel.frequencyAndDays = frequencyInformation;
    self.medicationFrequencyWasSet = YES;
    [self enableDoneButtonIfValuesSet];
    [self.setupTabulator reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:SetupTableRowTypesFrequency inSection:0] ] withRowAnimation:NO];
}

- (void)didReceiveNotificationOfColorResults:(NSNotification *)notification
{
    NSDictionary  *info = notification.userInfo;
    NSString  *colorname = info[APCMedSetupNameColorKey];
    self.currentMedicationModel.medicationLabelColor = colorname;
    self.medicationColorWasSet = YES;
    [self enableDoneButtonIfValuesSet];
    [self.setupTabulator reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:SetupTableRowTypesLabelColor inSection:0] ] withRowAnimation:NO];
}

- (void)didReceiveNotificationOfDosageResults:(NSNotification *)notification
{
    NSDictionary  *info = notification.userInfo;
    
    NSNumber  *dosageNumber = info[APCMedSetupNameDosageValueKey];
    self.currentMedicationModel.medicationDosageValue = dosageNumber;
    NSString  *dosageString = info[APCMedSetupNameDosageStringKey];
    self.currentMedicationModel.medicationDosageText = dosageString;
    self.medicationDosageWasSet = YES;
    [self enableDoneButtonIfValuesSet];
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
        //
        //    class names of view controllers to instantiate
        //
    self.classesToInstantiate = @[
                                    [APCMedicationNameViewController class],
                                    [APCMedicationFrequencyViewController class],
                                    [APCMedicationColorViewController class],
                                    [APCMedicationDosageViewController class]
                                ];
        //
        //    notification names for results passed back from view controllers
        //
    self.notificationNames = @[  APCMedSetupNameResultNotificationKey,
                                 APCMedSetupFrequencyResultNotificationKey,
                                 APCMedSetupNameColorNotificationKey,
                                 APCMedSetupNameDosageNotificationKey
                               ];
        //
        //    keys for results in user info dictionaries
        //
    self.resultsDictionaryKeys = @[
                                   APCMedSetupNameResultKey,
                                   APCMedSetupFrequencyResultKey,
                                   APCMedSetupNameColorKey,
                                   APCMedSetupNameDosageValueKey
                                ];
    
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
    
    
    self.setupTabulator.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.listTabulator.tableFooterView  = [[UIView alloc] initWithFrame:CGRectZero];
    
    UINib  *setupTableCellNib = [UINib nibWithNibName:kSetupTableCellName bundle:[NSBundle appleCoreBundle]];
    [self.setupTabulator registerNib:setupTableCellNib forCellReuseIdentifier:kSetupTableCellName];
    
    UINib  *summaryCellNib = [UINib nibWithNibName:kSummaryTableViewCell bundle:[NSBundle appleCoreBundle]];
    [self.listTabulator registerNib:summaryCellNib forCellReuseIdentifier:kSummaryTableViewCell];
    
    self.currentMedicationRecords = [NSMutableArray array];
    self.currentMedicationModel = [[APCMedicationModel alloc] init];
    
    self.doneButton.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
