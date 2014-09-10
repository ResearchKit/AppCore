//
//  SignUpGeneralInfoViewController.m
//  OnBoarding
//
//  Created by Karthik Keyan on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCProfile.h"
#import "APHUserInfoCell.h"
#import "APCUserInfoField.h"
#import "APCHealthKitProxy.h"
#import "APCStepProgressBar.h"
#import "UITableView+AppearanceCategory.h"
#import "APHSignUpGeneralInfoViewController.h"
#import "APHSignUpMedicalInfoViewController.h"


// Regular Expressions
static NSString * const kAPCUserInfoFieldUserNameRegEx          = @"[A-Za-z0-9_.]+";
static NSString * const kAPCUserInfoFieldEmailRegEx             = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
static NSString * const kAPCUserInfoFieldWeightRegEx            = @"[0-9]{1,3}";

// Date Formatter
static NSString * const kAPCUserInfoFieldDateOfBirthFormat      = @"MMM dd, yyyy";


@interface APHSignUpGeneralInfoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *agreeButton;

@property (nonatomic, strong) APCHealthKitProxy *healthKitProxy;

@end

@implementation APHSignUpGeneralInfoViewController


#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.profile = [APCProfile new];
        
        [self prepareFields];
    }
    return self;
}

- (void) prepareFields {
    NSMutableArray *fields = [NSMutableArray array];
    
    {
        APCUserInfoTextField *field = [APCUserInfoTextField new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Username", @"");
        field.placeholder = NSLocalizedString(@"Add Username", @"");
        field.value = nil;
        field.keyboardType = UIKeyboardTypeDefault;
        field.regularExpression = kAPCUserInfoFieldUserNameRegEx;
        field.identifier = NSStringFromClass([APCUserInfoTextField class]);
        
        [fields addObject:field];
    }
    
    {
        APCUserInfoTextField *field = [APCUserInfoTextField new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Password", @"");
        field.placeholder = NSLocalizedString(@"Add Password", @"");
        field.value = nil;
        field.secure = YES;
        field.keyboardType = UIKeyboardTypeDefault;
        field.identifier = NSStringFromClass([APCUserInfoTextField class]);
        
        [fields addObject:field];
    }
    
    {
        APCUserInfoTextField *field = [APCUserInfoTextField new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Email", @"");
        field.placeholder = NSLocalizedString(@"Add Email Address", @"");
        field.value = nil;
        field.keyboardType = UIKeyboardTypeEmailAddress;
        field.identifier = NSStringFromClass([APCUserInfoTextField class]);
        
        [fields addObject:field];
    }
    
    {
        APCUserInfoDatePickerField *field = [APCUserInfoDatePickerField new];
        field.style = UITableViewCellStyleValue1;
        field.caption = NSLocalizedString(@"Birthdate", @"");
        field.placeholder = NSLocalizedString(@"MMMM DD, YYYY", @"");
        field.dateFormate = kAPCUserInfoFieldDateOfBirthFormat;
        field.date = nil;
        field.identifier = NSStringFromClass([APCUserInfoDatePickerField class]);
        
        [fields addObject:field];
    }
    
    {
        APCUserInfoSegmentField *field = [APCUserInfoSegmentField new];
        field.style = UITableViewCellStyleValue1;
        field.segments = @[ NSLocalizedString(@"Male", @""), NSLocalizedString(@"Female", @""), NSLocalizedString(@"Other", @"") ];
        field.selectedIndex = 0;
        field.identifier = NSStringFromClass([APCUserInfoSegmentField class]);
        
        [fields addObject:field];
    }
    
    self.fields = fields;
}


#pragma mark - View Life Cycle

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self addNavigationItems];
    [self addFooterView];
    [self setupProgressBar];
    [self loadHealthKitValues];
}


#pragma mark - UI Methods

- (void) addNavigationItems {
    self.title = NSLocalizedString(@"General Information", @"");
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
}

- (void) setupProgressBar {
    self.stepProgressBar.rightLabel.text = NSLocalizedString(@"Mandatory", @"");
}

- (void) addFooterView {
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 44);
    label.font = [UITableView footerFont];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UITableView footerTextColor];
    label.text = NSLocalizedString(@"All fields on this screen are required.", @"");
    self.tableView.tableFooterView = label;
}


#pragma mark - IBActions

- (IBAction) agree {
    self.agreeButton.selected = !self.agreeButton.isSelected;
}


#pragma mark - Public Methods

- (Class) cellClass {
    return [APHUserInfoCell class];
}


#pragma mark - Private Methods

- (void) loadHealthKitValues {
    typeof(self) __weak weakSelf = self;
    [self.healthKitProxy authenticate:^(BOOL granted, NSError *error) {
        if (granted) {
            [weakSelf loadBiologicalInfo];
            [weakSelf loadHeight];
            [weakSelf loadWidth];
        }
    }];
}

- (void) loadHeight {
    typeof(self) __weak weakSelf = self;
    [self.healthKitProxy latestHeight:^(HKQuantity *quantity, NSError *error) {
        if (!error) {
            weakSelf.profile.height = [NSString stringWithFormat:@"%f", [quantity doubleValueForUnit:[HKUnit unitFromLengthFormatterUnit:NSLengthFormatterUnitInch]]];
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void) loadWidth {
    typeof(self) __weak weakSelf = self;
    
    [self.healthKitProxy latestHeight:^(HKQuantity *quantity, NSError *error) {
        if (!error) {
            weakSelf.profile.weight = @([quantity doubleValueForUnit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitKilogram]]);
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void) loadBiologicalInfo {
    [self.healthKitProxy fillBiologicalInfo:self.profile];
    [self.tableView reloadData];
}

- (void) next {
    APHSignUpMedicalInfoViewController *medicalInfoViewController = [APHSignUpMedicalInfoViewController new];
    medicalInfoViewController.profile = self.profile;
    
    [self.navigationController pushViewController:medicalInfoViewController animated:YES];
}

@end
