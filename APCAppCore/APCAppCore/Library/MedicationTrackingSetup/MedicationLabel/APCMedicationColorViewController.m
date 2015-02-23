//
//  APCMedicationColorViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationColorViewController.h"
#import "APCColorSwatchTableViewCell.h"
#import "APCMedSetupNotificationKeys.h"

#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerPrescriptionColor+Helper.h"

#import "NSBundle+Helper.h"

static  NSString  *kViewControllerName       = @"Medication Colors";

static  NSString  *kColorSwatchTableCellName = @"APCColorSwatchTableViewCell";

@interface APCMedicationColorViewController  ( )  <UITableViewDataSource, UITableViewDelegate>

@property  (nonatomic, weak)  IBOutlet  UITableView   *tabulator;

@property  (nonatomic, strong)          NSArray       *colorsList;

@property  (nonatomic, strong)          NSIndexPath   *selectedIndex;

@end

@implementation APCMedicationColorViewController

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
     NSInteger  numberOfRows = [self.colorsList count];
    return  numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
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
    NSDictionary  *info = nil;
    if (self.selectedIndex == nil) {
        info = @{ APCMedSetupNameColorKey : [UIColor grayColor] };
    } else {
        APCMedTrackerPrescriptionColor  *schedulColor = self.colorsList[indexPath.row];
        NSString  *colorName = schedulColor.name;
        info = @{
                 APCMedSetupNameColorKey : colorName
                };
    }
    NSNotificationCenter  *centre = [NSNotificationCenter defaultCenter];
    NSNotification  *notification = [NSNotification notificationWithName:APCMedSetupNameColorNotificationKey object:nil userInfo:info];
    [centre postNotification:notification];
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
                                                                    NSTimeInterval operationDuration,
                                                                    NSError *error)
     {
         self.colorsList = arrayOfGeneratedObjects;
         [self.tabulator reloadData];
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
