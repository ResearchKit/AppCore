//
//  SignUpMedicalInfoViewController.m
//  UI
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "UIView+Category.h"
#import "APCTableViewItem.h"
#import "APCStepProgressBar.h"
#import "UITableView+Appearance.h"
#import "APCSignupTouchIDViewController.h"
#import "APHSignUpMedicalInfoViewController.h"

// Regular Expression
static NSString * const kAPCUserInfoFieldWeightRegEx            = @"[0-9]{1,3}";


@interface APHSignUpMedicalInfoViewController ()

@property (nonatomic, strong) NSArray *medicalConditions;

@property (nonatomic, strong) NSArray *medications;

@property (nonatomic, strong) NSArray *bloodTypes;

@property (nonatomic, strong) NSArray *heightValues;

@end

@implementation APHSignUpMedicalInfoViewController

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadValues];
        [self prepareFields];
    }
    return self;
}

- (void) loadValues {
    self.medicalConditions = @[ @[@"Not listed", @"Condition 1" , @"Condition 2"] ];
    
    self.medications = @[ @[@"Not listed", @"Medication 1" , @"Medication 2"] ];
    
    self.bloodTypes = @[ @[@" ", @"A+", @"A-", @"B+", @"B-", @"AB+", @"AB-", @"O+", @"O-"] ];
    
    self.heightValues = @[ @[@"3'", @"4'", @"5'", @"6'", @"7'"], @[@"0''", @"1''", @"2''", @"3''", @"4''", @"5''", @"6''", @"7''", @"8''", @"9''"] ];
}

- (void) prepareFields {
    NSMutableArray *fields = [NSMutableArray array];
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Medical Conditions", @"");
        field.detailDiscloserStyle = YES;
        field.selectedRowIndices = @[ @(0) ];
        field.pickerData = self.medicalConditions;
        
        [fields addObject:field];
    }
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Medication", @"");
        field.detailDiscloserStyle = YES;
        field.selectedRowIndices = @[ @(0) ];
        field.pickerData = self.medications;
        
        [fields addObject:field];
    }
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Blood Type", @"");
        field.detailDiscloserStyle = YES;
        field.selectedRowIndices = @[ @(0) ];
        field.pickerData = self.bloodTypes;
        
        [fields addObject:field];
    }
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Height", @"");
        field.detailDiscloserStyle = YES;
        field.selectedRowIndices = @[ @(2), @(5) ];
        field.pickerData = self.heightValues;
        
        [fields addObject:field];
    }
    
    {
        APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Weight", @"");
        field.placeholder = NSLocalizedString(@"lb", @"");
        field.regularExpression = kAPCUserInfoFieldWeightRegEx;
        field.value = nil;
        field.keyboardType = UIKeyboardTypeNumberPad;
        field.textAlignnment = NSTextAlignmentRight;
        
        [fields addObject:field];
    }
    
    self.fields = fields;
}


#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = nil;
    
    [self addNavigationItems];
    [self setupProgressBar];
    [self addFooterView];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:1 animation:YES];
}

- (void) addNavigationItems {
    self.title = NSLocalizedString(@"Medical Information", @"");
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
}

- (void) setupProgressBar {
    self.stepProgressBar.rightLabel.text = NSLocalizedString(@"optional", @"");
}

- (void) addFooterView {
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(0, 0, self.tableView.width, 44);
    label.font = [UITableView footerFont];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UITableView footerTextColor];
    label.text = NSLocalizedString(@"All fields on this screen are optional.", @"");
    self.tableView.tableFooterView = label;
}


#pragma mark - Private Methods

- (void) next {
    APCSignupTouchIDViewController *touchIDViewController = [[APCSignupTouchIDViewController alloc] initWithNibName:@"APCSignupTouchIDViewController" bundle:nil];
    [self.navigationController pushViewController:touchIDViewController animated:YES];
}

@end
