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

static  CGFloat    kSectionHeaderHeight      = 42.0;
static  CGFloat    kSectionHeaderLabelOffset = 10.0;

@interface APCMedicationColorViewController  ( )  <UITableViewDataSource, UITableViewDelegate>

@property  (nonatomic, weak)  IBOutlet  UITableView   *tabulator;

@property  (nonatomic, strong)          NSArray       *colorsList;

@property  (nonatomic, strong)          NSIndexPath   *selectedIndex;

@end

@implementation APCMedicationColorViewController

#pragma  mark  -  Navigation Bar Button Action Methods

- (IBAction)doneButtonTapped:(UIBarButtonItem *) __unused sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCColorSwatchTableViewCell  *cell = (APCColorSwatchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kColorSwatchTableCellName];
    
    APCMedTrackerPrescriptionColor  *schedulColor = self.colorsList[indexPath.row];
    
    NSString  *colorname = schedulColor.name;
    colorname = NSLocalizedString(colorname, nil);
    cell.colorNameLabel.text = colorname;
    
    if (self.selectedIndex != nil) {
        if ([self.selectedIndex isEqual:indexPath] == YES) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
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
        label.text = NSLocalizedString(@"Select a Color Code for Your Medication", nil);
        [view addSubview:label];
    }
    return  view;
}

- (void)setupIndexPathForColorDescriptor:(APCMedTrackerPrescriptionColor *)descriptor
{
    for (NSUInteger  index = 0;  index < [self.colorsList count];  index++) {
        APCMedTrackerPrescriptionColor  *color = self.colorsList[index];
        if ([color.name isEqualToString:descriptor.name] == YES) {
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tabulator.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIBarButtonItem  *donester = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.rightBarButtonItem = donester;
    
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
             NSSortDescriptor *nameSorter = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
             NSArray  *descriptors = @[ nameSorter ];
             NSArray  *sorted = [arrayOfGeneratedObjects sortedArrayUsingDescriptors:descriptors];
             self.colorsList = sorted;
             if (self.oneColorDescriptor != nil) {
                 [self setupIndexPathForColorDescriptor:self.oneColorDescriptor];
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
