//
//  APCMedicationColorViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationColorViewController.h"
#import "APCColorSwatchTableViewCell.h"

#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerPrescriptionColor+Helper.h"

#import "NSBundle+Helper.h"

#import "APCLog.h"

static  NSString  *kViewControllerName       = @"Medication Colors";

static  NSString  *kColorSwatchTableCellName = @"APCColorSwatchTableViewCell";

@interface APCMedicationColorViewController  ( )  <UITableViewDataSource, UITableViewDelegate>

@property  (nonatomic, weak)  IBOutlet  UITableView   *tabulator;

@property  (nonatomic, strong)          NSArray       *colorsList;

@property  (nonatomic, strong)          NSIndexPath   *selectedIndex;

@end

@implementation APCMedicationColorViewController

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
     NSInteger  numberOfRows = [self.colorsList count];
    return  numberOfRows;
}

- (NSString *)tableView:(UITableView *) __unused tableView titleForHeaderInSection:(NSInteger) __unused section
{
    NSString  *title = NSLocalizedString(@"Select a Color Code for Your Medication", nil);
    return  title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCColorSwatchTableViewCell  *cell = (APCColorSwatchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kColorSwatchTableCellName];
    
    APCMedTrackerPrescriptionColor  *schedulColor = self.colorsList[indexPath.row];
    
    NSString  *colorname = schedulColor.name;
    colorname = NSLocalizedString(colorname, nil);
    cell.colorNameLabel.text = colorname;
    
    cell.colorSwatchView.backgroundColor = schedulColor.UIColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            if ([self.delegate respondsToSelector:@selector(colorController:didSelectColorLabelName:)] == YES) {
                APCMedTrackerPrescriptionColor  *schedulColor = self.colorsList[indexPath.row];
                [self.delegate performSelector:@selector(colorController:didSelectColorLabelName:) withObject:self withObject:schedulColor];
            }
        }
    }
}

- (NSString *)title
{
    return  kViewControllerName;
}

#pragma  mark  -  View Controller Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tabulator.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UINib  *colorSwatchTableCellNib = [UINib nibWithNibName:kColorSwatchTableCellName bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:colorSwatchTableCellNib forCellReuseIdentifier:kColorSwatchTableCellName];
    
    self.colorsList = [NSArray array];
    
    [APCMedTrackerPrescriptionColor fetchAllFromCoreDataAndUseThisQueue: [NSOperationQueue mainQueue]
                                                toDoThisWhenDone: ^(NSArray *arrayOfGeneratedObjects,
                                                                    NSTimeInterval  __unused operationDuration,
                                                                    NSError * __unused error)
     {
         if (error != nil) {
             APCLogError2(error);
         } else {
             self.colorsList = arrayOfGeneratedObjects;
             [self.tabulator reloadData];
         }
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
