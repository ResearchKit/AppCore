//
//  APCMedicationFrequencyViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
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

static  NSUInteger kAllDaysOfWeekCount              =    7;

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

@property  (nonatomic, weak)            UIBarButtonItem      *donester;

@property  (nonatomic, strong)          NSArray              *valueButtons;

@property  (nonatomic, strong)          NSMutableDictionary  *daysAndDoses;

@end

@implementation APCMedicationFrequencyViewController

#pragma  mark  -  Navigation Bar Button Action Methods

- (IBAction)doneButtonTapped:(UIBarButtonItem *) __unused sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
        if ([self numberOfSelectedDays] >= kAllDaysOfWeekCount) {
            [self setupSelectedCell:dayCell toSelectedState:YES];
        }
        cell = dayCell;
    } else if (indexPath.section == kDaysOfWeekSection) {
        dayCell.selectionStyle = UITableViewCellSelectionStyleNone;
        dayCell.dayTitle.text = daysOfWeekNames[indexPath.row];
        NSString  *weekday = daysOfWeekNames[indexPath.row];
        NSNumber  *number = self.daysAndDoses[weekday];
        if ([number unsignedIntegerValue] > 0) {
            [self setupSelectedCell:dayCell toSelectedState:YES];
        }
        cell = dayCell;
    }
    [self setupEverydayCellState];
    return  cell;
}

#pragma  mark  -  Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCFrequencyDayTableViewCell  *selectedCell = (APCFrequencyDayTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == kEveryDayOfWeekSection) {
        if (self.everyDayWasSelected == NO) {
            self.everyDayWasSelected = YES;
        } else {
            self.everyDayWasSelected = NO;
        }
        [self setupSelectedCell:selectedCell toSelectedState:self.everyDayWasSelected];
        
        for (NSUInteger  day = 0;  day < numberOfDaysOfWeekNames;  day++) {
            NSIndexPath  *path = [NSIndexPath indexPathForRow:day inSection:kDaysOfWeekSection];
            APCFrequencyDayTableViewCell  *cell = (APCFrequencyDayTableViewCell *)[tableView cellForRowAtIndexPath:path];
            [self setupSelectedCell:cell toSelectedState:self.everyDayWasSelected];
        }
    } else if (indexPath.section == kDaysOfWeekSection) {
        if (selectedCell.accessoryType == UITableViewCellAccessoryNone) {
            [self setupSelectedCell:selectedCell toSelectedState:YES];
        } else {
            [self setupSelectedCell:selectedCell toSelectedState:NO];
        }
        NSString  *key = daysOfWeekNames[indexPath.row];
        [self.daysAndDoses setObject:[NSNumber numberWithInteger:0] forKey:key];
    }
    [self setupDoneButtonState];
    [self setupEverydayCellState];
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

- (CGFloat)tableView:(UITableView *) __unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat  answer = 44.0;
    
    if (indexPath.section == kFrequencySection) {
        answer = kRowHeightForFrequencySection;
    }
    return  answer;
}

#pragma  mark  -  A Gallimaufry of Helper Methods

- (NSUInteger)findDosageValueForValueButton
{
    NSUInteger  answer = 0;
    
    for (NSUInteger  index = 0;  index < kAllDaysOfWeekCount;  index++) {
        NSString  *weekday = daysOfWeekNames[index];
        NSNumber  *number = self.daysAndDoses[weekday];
        if ([number unsignedIntegerValue] > 0) {
            answer = [number unsignedIntegerValue];
            break;
        }
    }
    return  answer;
}

- (void)processFrequencyButtonsForCell:(UITableViewCell *)cell
{
    NSMutableArray  *buttons = [NSMutableArray array];
    for (NSInteger  index = kFirstButtonTagValue;  index <= kLastButtonTagValue;  index++) {
        UIButton  *aButton = (UIButton *)[cell viewWithTag:index];
        [aButton addTarget:self action:@selector(valueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [aButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [buttons addObject:aButton];
        
        CALayer  *layer = aButton.layer;
        layer.cornerRadius = CGRectGetWidth(aButton.frame) / 2.0;
        layer.masksToBounds = YES;
        [self setStateForFrequencyButton:aButton toState:UIControlStateNormal];
    }
    self.valueButtons = buttons;
    NSUInteger  frequency = [self findDosageValueForValueButton];
    if (frequency > 0) {
        UIButton  *button = self.valueButtons[frequency - 1];
        [self setStateForFrequencyButton:button toState:UIControlStateSelected];
    }
}

- (void)setupDoneButtonState
{
    self.donester.enabled = NO;
    if (([self findSelectedButton] != nil) && ([self numberOfSelectedDays] > 0)) {
        self.donester.enabled = YES;
    }
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
        layer.backgroundColor = [[UIColor appPrimaryColor] CGColor];
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
    [self setupDoneButtonState];
}

- (NSUInteger)numberOfSelectedDays
{
    NSUInteger answer = 0;
    
    for (NSInteger  day = 0;  day < kNumberOfRowsInDaysOfWeekSection;  day++) {
        UITableViewCell  *cell = [self.tabulator cellForRowAtIndexPath:[NSIndexPath indexPathForRow:day inSection:kDaysOfWeekSection]];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            answer = answer + 1;
        }
    }
    return  answer;
}

- (void)setupEverydayCellState
{
    NSUInteger  numberOfSelectedDays = [self numberOfSelectedDays];
    NSIndexPath  *everyday = [NSIndexPath indexPathForRow:0 inSection:kEveryDayOfWeekSection];
    APCFrequencyDayTableViewCell  *cell = (APCFrequencyDayTableViewCell *)[self.tabulator cellForRowAtIndexPath:everyday];
    if (numberOfSelectedDays >= kAllDaysOfWeekCount) {
        [self setupSelectedCell:cell toSelectedState:YES];
    } else {
        [self setupSelectedCell:cell toSelectedState:NO];
    }
}

- (void)setupSelectedCell:(APCFrequencyDayTableViewCell *)cell toSelectedState:(BOOL)selected
{
    if (selected == YES) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.dayTitle.textColor = [UIColor appPrimaryColor];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.dayTitle.textColor = [UIColor blackColor];
    }
}

#pragma  mark  -  View Controller Methods

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
    if ((valueButton == nil) || ([self numberOfSelectedDays] == 0)) {
        self.donester.enabled = NO;
    } else if ((valueButton != nil) && ([self numberOfSelectedDays] > 0)) {
        self.donester.enabled = YES;
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(frequencyController:didSelectFrequency:)] == YES) {
                [self.delegate performSelector:@selector(frequencyController:didSelectFrequency:) withObject:self withObject:self.daysAndDoses];
            }
        }
    }
}

- (NSString *)title
{
    return  kViewControllerName;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabulator.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIBarButtonItem  *donester = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
    self.donester = donester;
    self.navigationItem.rightBarButtonItem = donester;
    self.donester.enabled = NO;
    
    UINib  *frequencyTableTimesCellNib = [UINib nibWithNibName:kFrequencyTableTimesCellName bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:frequencyTableTimesCellNib forCellReuseIdentifier:kFrequencyTableTimesCellName];
    
    UINib  *kFrequencyDayTableCellNib = [UINib nibWithNibName:kFrequencyDayTableCellName bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:kFrequencyDayTableCellNib forCellReuseIdentifier:kFrequencyDayTableCellName];
    
    if (self.daysNumbersDictionary != nil) {
        self.daysAndDoses = [self.daysNumbersDictionary mutableCopy];
        [self.tabulator reloadData];
        [self setupEverydayCellState];
    } else {
        self.daysAndDoses = [NSMutableDictionary dictionary];
        for (NSUInteger  day = 0;  day < numberOfDaysOfWeekNames;  day++) {
            [self.daysAndDoses setObject:[NSNumber numberWithInteger:0] forKey:daysOfWeekNames[day]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
