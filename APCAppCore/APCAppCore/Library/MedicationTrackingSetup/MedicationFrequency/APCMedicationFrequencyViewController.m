//
//  APCMedicationFrequencyViewController.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationFrequencyViewController.h"
#import "APCFrequencyTableViewTimesCell.h"
#import "APCFrequencyDayTableViewCell.h"

#import "UIColor+APCAppearance.h"
#import "NSBundle+Helper.h"

static  NSString  *kViewControllerName          = @"Medication Frequency";

static  NSString  *kFrequencyTableTimesCellName = @"APCFrequencyTableViewTimesCell";

static  NSString  *kFrequencyDayTableCellName   = @"APCFrequencyDayTableViewCell";

static  NSString  *kEveryDayOfWeekCaption       = @"Every Day";

static  NSString  *daysOfWeekNames[]            = { @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday" };
static  NSString  *daysOfWeekNamesAbbreviated[] = { @"Mon",    @"Tue",     @"Wed",       @"Thu",      @"Fri",    @"Sat",      @"Sun"    };

static  NSUInteger  numberOfDaysOfWeekNames     = (sizeof(daysOfWeekNames) / sizeof(NSString *));

static  NSInteger  kNumberOfSections                =    3;

static  NSInteger  kFrequencySection                =    0;
static  NSInteger  kNumberOfRowsInFrequencySection  =    1;
static  CGFloat    kRowHeightForFrequencySection    =   56.0;

static  NSInteger  kEveryDayOfWeekSection           =    1;
static  NSInteger  kNumberOfRowsEveryDayWeekSection =    1;

static  NSInteger  kDaysOfWeekSection               =    2;
static  NSInteger  kNumberOfRowsInDaysOfWeekSection =    7;

static  NSInteger  kBaseButtonTagValue              = 1000;
static  NSInteger  kFirstButtonTagValue             = 1001;
static  NSInteger  kLastButtonTagValue              = 1005;

static  CGFloat    kSectionHeaderHeights[]          = { 48.0, 48.0, 8.0 };
static  CGFloat    kSectionHeaderLabelOffset        =   16.0;


@interface APCMedicationFrequencyViewController  ( )  <UITableViewDataSource, UITableViewDelegate>

@property  (nonatomic, weak)  IBOutlet  UITableView          *tabulator;
@property  (nonatomic, assign)          BOOL                  everyDayWasSelected;

@property  (nonatomic, strong)          NSArray              *valueButtons;
@property  (nonatomic, assign)          BOOL                  aValueButtonWasSelected;

@property  (nonatomic, assign)          BOOL                  oneOrMoreDaysWereSelected;

@property  (nonatomic, strong)          NSMutableDictionary  *daysAndDoses;

@end

@implementation APCMedicationFrequencyViewController

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
    return  kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *) __unused tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger  numberOfRows = 0;
    
    if (section == kFrequencySection) {
        numberOfRows = kNumberOfRowsInFrequencySection;
    } else if (section == kEveryDayOfWeekSection) {
        numberOfRows = kNumberOfRowsEveryDayWeekSection;
    } else if (section == kDaysOfWeekSection) {
        numberOfRows = kNumberOfRowsInDaysOfWeekSection;
    }
    return  numberOfRows;
}

static  NSString  *sectionTitles[] = { @"How many times a day do you take this medication?", @"On what days do you take this medication?", @"        " };

- (CGFloat)tableView:(UITableView *) __unused tableView heightForHeaderInSection:(NSInteger)section
{
    return  kSectionHeaderHeights[section];
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

- (CGFloat)tableView:(UITableView *) __unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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
        freqCell.accessoryType = UITableViewCellAccessoryNone;
    } else if (indexPath.section == kEveryDayOfWeekSection) {
        dayCell = (APCFrequencyDayTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kFrequencyDayTableCellName];
    } else if (indexPath.section == kDaysOfWeekSection) {
        dayCell = (APCFrequencyDayTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kFrequencyDayTableCellName];
    }
    
    if ((indexPath.section == kFrequencySection) && (freqCell != nil)) {
        freqCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self processFrequencyButtonsForCell:freqCell];
        cell = freqCell;
    } else if (indexPath.section == kEveryDayOfWeekSection) {
        dayCell.selectionStyle = UITableViewCellSelectionStyleNone;
        dayCell.dayTitle.text = kEveryDayOfWeekCaption;
        cell = dayCell;
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
        self.aValueButtonWasSelected = YES;
    } else if (selectedButton == tappedButton) {
        [self setStateForFrequencyButton:tappedButton toState:UIControlStateNormal];
        self.aValueButtonWasSelected = NO;
    } else {
        [self setStateForFrequencyButton:selectedButton toState:UIControlStateNormal];
        [self setStateForFrequencyButton:tappedButton toState:UIControlStateSelected];
        self.aValueButtonWasSelected = YES;
    }
    self.oneOrMoreDaysWereSelected = [self areAnyDaysSelected];
}

#pragma  mark  -  Table View Delegate Methods

- (BOOL)areAnyDaysSelected
{
    BOOL  answer = NO;
    
    for (NSInteger  day = 0;  day < kNumberOfRowsInDaysOfWeekSection;  day++) {
        UITableViewCell  *cell = [self.tabulator cellForRowAtIndexPath:[NSIndexPath indexPathForRow:day inSection:kDaysOfWeekSection]];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            answer = YES;
            break;
        }
    }
    return  answer;
}

- (void)setCell:(APCFrequencyDayTableViewCell *)cell toSelectedState:(BOOL)selected
{
    if (selected == YES) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.dayTitle.textColor = [UIColor appPrimaryColor];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.dayTitle.textColor = [UIColor blackColor];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCFrequencyDayTableViewCell  *selectedCell = (APCFrequencyDayTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == kEveryDayOfWeekSection) {
        if (self.everyDayWasSelected == NO) {
            self.everyDayWasSelected = YES;
        } else {
            self.everyDayWasSelected = NO;
        }
        [self setCell:selectedCell toSelectedState:self.everyDayWasSelected];
        
        for (NSUInteger  day = 0;  day < numberOfDaysOfWeekNames;  day++) {
            NSIndexPath  *path = [NSIndexPath indexPathForRow:day inSection:kDaysOfWeekSection];
            APCFrequencyDayTableViewCell  *cell = (APCFrequencyDayTableViewCell *)[tableView cellForRowAtIndexPath:path];
            [self setCell:cell toSelectedState:self.everyDayWasSelected];
        }
    } else if (indexPath.section == kDaysOfWeekSection) {
        if (selectedCell.accessoryType == UITableViewCellAccessoryNone) {
            [self setCell:selectedCell toSelectedState:YES];
        } else {
            [self setCell:selectedCell toSelectedState:NO];
        }
        NSString  *key = daysOfWeekNames[indexPath.row];
        [self.daysAndDoses setObject:[NSNumber numberWithInteger:0] forKey:key];
        
        self.oneOrMoreDaysWereSelected = [self areAnyDaysSelected];
    }
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
    if ((valueButton != nil) && ([self areAnyDaysSelected] == YES)) {
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(frequencyController:didSelectFrequency:)] == YES) {
                [self.delegate performSelector:@selector(frequencyController:didSelectFrequency:) withObject:self withObject:self.daysAndDoses];
            }
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
