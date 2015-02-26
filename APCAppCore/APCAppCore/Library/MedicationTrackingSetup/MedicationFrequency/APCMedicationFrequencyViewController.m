//
//  APCMedicationFrequencyViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationFrequencyViewController.h"
#import "APCFrequencyTableViewTimesCell.h"
#import "APCFrequencyDayTableViewCell.h"

#import "NSBundle+Helper.h"

static  NSString  *kViewControllerName          = @"Medication Frequency";

static  NSString  *kFrequencyTableTimesCellName = @"APCFrequencyTableViewTimesCell";

static  NSString  *kFrequencyDayTableCellName   = @"APCFrequencyDayTableViewCell";

static  NSString  *daysOfWeekNames[]            = { @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday" };
static  NSString  *daysOfWeekNamesAbbreviated[] = { @"Mon",    @"Tue",     @"Wed",       @"Thu",      @"Fri",    @"Sat",      @"Sun"    };

static  NSUInteger  numberOfDaysOfWeekNames     = (sizeof(daysOfWeekNames) / sizeof(NSString *));

static  NSInteger  kNumberOfSections                =    2;

static  NSInteger  kFrequencySection                =    0;
static  NSInteger  kNumberOfRowsInFrequencySection  =    1;
static  CGFloat    kRowHeightForFrequencySection    =   56.0;

static  NSInteger  kDaysOfWeekSection               =    1;
static  NSInteger  kNumberOfRowsInDaysOfWeekSection =    7;

static  NSInteger  kBaseButtonTagValue              = 1000;
static  NSInteger  kFirstButtonTagValue             = 1001;
static  NSInteger  kLastButtonTagValue              = 1005;

static  CGFloat    kSectionHeaderHeight             =   48.0;
static  CGFloat    kSectionHeaderLabelOffset        =   16.0;


@interface APCMedicationFrequencyViewController  ( )  <UITableViewDataSource, UITableViewDelegate>

@property  (nonatomic, weak)  IBOutlet  UITableView          *tabulator;

@property  (nonatomic, strong)          NSArray              *valueButtons;

@property  (nonatomic, strong)          NSMutableDictionary  *daysAndDoses;

@end

@implementation APCMedicationFrequencyViewController

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
    return  kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger  numberOfRows = 0;
    
    if (section == kFrequencySection) {
        numberOfRows = kNumberOfRowsInFrequencySection;
    } else if (section == kDaysOfWeekSection) {
        numberOfRows = kNumberOfRowsInDaysOfWeekSection;
    }
    return  numberOfRows;
}

static  NSString  *sectionTitles[] = { @"How many times a day do you take this medication?", @"On what days do you take this medication?" };

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return  kSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView  *view = nil;
    
    if (section < kNumberOfSections) {
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
        NSString  *title = sectionTitles[section];
        title = NSLocalizedString(title, nil);
        label.text = title;
        [view addSubview:label];
    }
    return  view;
}

- (void)processFrequencyButtonsForCell:(UITableViewCell *)cell
{
    NSMutableArray  *buttons = [NSMutableArray array];
    for (NSInteger  i = kFirstButtonTagValue;  i <= kLastButtonTagValue;  i++) {
        UIButton  *aButton = (UIButton *)[cell viewWithTag:i];
        [aButton addTarget:self action:@selector(valueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [aButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [buttons addObject:aButton];
        
        CALayer  *layer = aButton.layer;
        layer.cornerRadius = CGRectGetWidth(aButton.frame) / 2.0;
        layer.masksToBounds = YES;
        [self setStateForFrequencyButton:aButton toState:UIControlStateNormal];
    }
    self.valueButtons = buttons;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat  answer = 44.0;
    
    if (indexPath.section == kFrequencySection) {
        answer = kRowHeightForFrequencySection;
    }
    return  answer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell                 *cell     = nil;
    
    APCFrequencyTableViewTimesCell  *freqCell = nil;
    APCFrequencyDayTableViewCell    *dayCell  = nil;
    
    if (indexPath.section == kFrequencySection) {
        freqCell = (APCFrequencyTableViewTimesCell *)[tableView dequeueReusableCellWithIdentifier:kFrequencyTableTimesCellName];
    } else if (indexPath.section == kDaysOfWeekSection) {
        dayCell = (APCFrequencyDayTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kFrequencyDayTableCellName];
    }
    
    if ((indexPath.section == kFrequencySection) && (freqCell != nil)) {
        freqCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self processFrequencyButtonsForCell:freqCell];
        cell = freqCell;
    } else if (indexPath.section == kDaysOfWeekSection) {
        dayCell.selectionStyle = UITableViewCellSelectionStyleNone;
        dayCell.dayTitle.text = daysOfWeekNames[indexPath.row];
        cell = dayCell;
    }
    
    return  cell;
}

- (UIButton *)findSelectedButton
{
    UIButton  *selectedButton = nil;
    
    for (UIButton  *aButton  in  self.valueButtons) {
        if ((aButton.state & UIControlStateSelected) != 0) {
            selectedButton = aButton;
            break;
        }
    }
    return  selectedButton;
}

- (void)setStateForFrequencyButton:(UIButton *)button toState:(UIControlState)state
{
    CALayer  *layer = button.layer;
    
    if (state == UIControlStateNormal) {
        button.selected = NO;
        layer.borderWidth = 2.0;
        layer.borderColor = [[UIColor lightGrayColor] CGColor];
        layer.backgroundColor = [[UIColor whiteColor] CGColor];
        [button setTitleColor:[UIColor lightGrayColor] forState:state];
    } else {
        button.selected = YES;
        layer.borderWidth = 0.0;
        layer.borderColor = NULL;
        layer.backgroundColor = [[UIColor redColor] CGColor];
        [button setTitleColor:[UIColor whiteColor] forState:state];
    }
}

- (void)valueButtonTapped:(UIButton *)sender
{
    UIButton  *tappedButton   = sender;
    UIButton  *selectedButton = [self findSelectedButton];
    
    if (selectedButton == nil) {
        [self setStateForFrequencyButton:tappedButton toState:UIControlStateSelected];
    } else if (selectedButton == tappedButton) {
        [self setStateForFrequencyButton:tappedButton toState:UIControlStateNormal];
    } else {
        [self setStateForFrequencyButton:selectedButton toState:UIControlStateNormal];
        [self setStateForFrequencyButton:tappedButton toState:UIControlStateSelected];
    }
}

#pragma  mark  -  Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell  *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (selectedCell.accessoryType == UITableViewCellAccessoryNone) {
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        selectedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    NSString  *key = daysOfWeekNames[indexPath.row];
    [self.daysAndDoses setObject:[NSNumber numberWithInteger:0] forKey:key];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIButton  *valueButton = [self findSelectedButton];
    
    for (NSUInteger  day = 0;  day < numberOfDaysOfWeekNames;  day++) {
        UITableViewCell  *dayCell = [self.tabulator cellForRowAtIndexPath:[NSIndexPath indexPathForRow:day inSection:kDaysOfWeekSection]];
        if (dayCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            NSString  *dayName = daysOfWeekNames[day];
            self.daysAndDoses[dayName] = [NSNumber numberWithInteger:(valueButton.tag - kBaseButtonTagValue)];
        }
    }
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(frequencyController:didSelectFrequency:)] == YES) {
            [self.delegate performSelector:@selector(frequencyController:didSelectFrequency:) withObject:self withObject:self.daysAndDoses];
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
    
    UINib  *frequencyTableTimesCellNib = [UINib nibWithNibName:kFrequencyTableTimesCellName bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:frequencyTableTimesCellNib forCellReuseIdentifier:kFrequencyTableTimesCellName];
    
    UINib  *kFrequencyDayTableCellNib = [UINib nibWithNibName:kFrequencyDayTableCellName bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:kFrequencyDayTableCellNib forCellReuseIdentifier:kFrequencyDayTableCellName];
    
    self.daysAndDoses = [NSMutableDictionary dictionary];
    for (NSUInteger  day = 0;  day < numberOfDaysOfWeekNames;  day++) {
        [self.daysAndDoses setObject:[NSNumber numberWithInteger:0] forKey:daysOfWeekNames[day]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
