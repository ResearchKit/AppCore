//
//  APCMedicationDosageViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationDosageViewController.h"

#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerPossibleDosage+Helper.h"

static  NSString  *kViewControllerName = @"Medication Dosages";

    //
    //    for a measure of typographic elegance,
    //        the Unicode characters below have these meanings
    //
    //    2004    three per em space
    //    2005    four per em space
    //    2006    six per em space
    //    2008    punctuation space
    //    2009    thin space
    //    200A    hairline space
    //    200B    zero width space
    //    2010    hyphen
    //    2013    en dash
    //    2014    em dash
    //    00bc    1/4
    //    00bd    1/2


    //
    //    Commented out Code here will be removed to
    //        APCMedTrackerPredefinedPossibleDosages.plist soon
    //
//static  NSString  *dosageStrings[] = {
//                        @"\u2007\u2007\u00bd\u2008mg",
//                        @"\u2007\u20071\u2008mg",
//                        @"\u2007\u20072\u00bd\u2008mg",
//                        @"\u2007\u20075\u2008mg",
//                        @"\u200710\u2008mg",
//                        @"\u200720\u2008mg",
//                        @"\u200725\u2008mg",
//                        @"\u200750\u2008mg",
//                        @"\u200775\u2008mg",
//                        @"100\u2008mg"
//                    };
//

@interface APCMedicationDosageViewController  ( )  <UITableViewDataSource, UITableViewDelegate>

@property  (nonatomic, weak)  IBOutlet  UITableView  *tabulator;

@property  (nonatomic, strong)          NSArray      *dosageAmounts;

@property  (nonatomic, strong)          NSIndexPath  *selectedIndex;

@end

@implementation APCMedicationDosageViewController

#pragma  mark  -  Toolbar Button Action Methods

- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma  mark  -  Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger  numberOfRows = [self.dosageAmounts count];
    return  numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
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
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(dosageController:didSelectDosageAmount:)] == YES) {
            APCMedTrackerPossibleDosage  *dosage = self.dosageAmounts[indexPath.row];
            [self.delegate performSelector:@selector(dosageController:didSelectDosageAmount:) withObject:self withObject:dosage];
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
                                                                        NSTimeInterval operationDuration,
                                                                        NSError *error)
     {
         self.dosageAmounts = arrayOfGeneratedObjects;
         [self.tabulator reloadData];
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
