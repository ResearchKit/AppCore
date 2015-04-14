// 
//  APCMedicationFrequencyViewController.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCMedicationFrequencyViewController.h"
#import "APCFrequencyTableViewTimesCell.h"
#import "APCFrequencyEverydayTableViewCell.h"
#import "APCFrequencyDayTableViewCell.h"

#import "UIColor+APCAppearance.h"
#import "NSBundle+Helper.h"

static  NSString  *kViewControllerName              = @"Medication Frequency";

static  NSString  *kFrequencyTableTimesCellName     = @"APCFrequencyTableViewTimesCell";
static  NSString  *kFrequencyEverydayTableCellName  = @"APCFrequencyEverydayTableViewCell";
static  NSString  *kFrequencyDayTableCellName       = @"APCFrequencyDayTableViewCell";

static  NSString  *kEveryDayOfWeekCaption           = @"Every Day";

static  NSString  *daysOfWeekNames[]                = { @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday" };
static  NSString  *daysOfWeekNamesAbbreviated[]     = { @"Mon",    @"Tue",     @"Wed",       @"Thu",      @"Fri",    @"Sat",      @"Sun"    };

static  NSUInteger  numberOfDaysOfWeekNames         = (sizeof(daysOfWeekNames) / sizeof(NSString *));

static  NSUInteger kAllDaysOfWeekCount              =    7;

static  NSInteger  kNumberOfSections                =    3;

static  NSInteger  kFrequencySection                =    0;
static  NSInteger  kNumberOfRowsInFrequencySection  =    1;
static  CGFloat    kRowHeightForFrequencySection    =   64.0;

static  NSInteger  kEveryDayOfWeekSection           =    1;
static  NSInteger  kNumberOfRowsEveryDayWeekSection =    0;

static  NSInteger  kDaysOfWeekSection               =    2;
static  NSInteger  kNumberOfRowsInDaysOfWeekSection =    7;

static  NSInteger  kBaseButtonTagValue              = 1000;
static  NSInteger  kFirstButtonTagValue             = 1001;
static  NSInteger  kLastButtonTagValue              = 1005;

static  CGFloat    kSectionHeaderHeights[]          = { 48.0, 48.0, 8.0 };
static  CGFloat    kSectionHeaderLabelOffset        =   16.0;

static  CGFloat    kAPCMedicationRowHeight          = 64.0;


@interface APCMedicationFrequencyViewController  ( )  <UITableViewDataSource, UITableViewDelegate>

@property  (nonatomic, weak)  IBOutlet  UITableView          *tabulator;
@property  (nonatomic, assign)          BOOL                  everyDayWasSelected;

@property  (nonatomic, weak)            UIBarButtonItem      *donester;
@property  (nonatomic, assign)          BOOL                  doneButtonWasTapped;

@property  (nonatomic, strong)          NSArray              *valueButtons;
@property  (nonatomic, strong)          UIButton             *selectedValueButton;

@property  (nonatomic, strong)          NSMutableDictionary  *daysAndDoses;

@property  (nonatomic, strong)          NSMutableArray       *selectedDays;

@end

@implementation APCMedicationFrequencyViewController

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
    UITableViewCell  *cell = nil;
    
    if (indexPath.section == kFrequencySection) {
        APCFrequencyTableViewTimesCell  *frequencyCell = (APCFrequencyTableViewTimesCell *)[tableView dequeueReusableCellWithIdentifier:kFrequencyTableTimesCellName];
        frequencyCell.accessoryType = UITableViewCellAccessoryNone;
        frequencyCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self processFrequencyButtonsForCell:frequencyCell];
        if (self.selectedValueButton != nil) {
            [self setStateForFrequencyButton:self.selectedValueButton toState:UIControlStateSelected];
        } else {
        }
        cell = frequencyCell;
    } else if (indexPath.section == kEveryDayOfWeekSection) {
        APCFrequencyEverydayTableViewCell  *everydayCell = (APCFrequencyEverydayTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kFrequencyEverydayTableCellName];
        everydayCell.selectionStyle = UITableViewCellSelectionStyleNone;
        everydayCell.everydayTitle.text = kEveryDayOfWeekCaption;
        if ([self numberOfSelectedDays] >= kAllDaysOfWeekCount) {
            everydayCell.accessoryType = UITableViewCellAccessoryCheckmark;
            everydayCell.everydayTitle.textColor = [UIColor appPrimaryColor];
        } else {
            everydayCell.accessoryType = UITableViewCellAccessoryNone;
            everydayCell.everydayTitle.textColor = [UIColor blackColor];
        }
        cell = everydayCell;
    } else if (indexPath.section == kDaysOfWeekSection) {
        APCFrequencyDayTableViewCell  *dayOfWeekCell = (APCFrequencyDayTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kFrequencyDayTableCellName];
        dayOfWeekCell.selectionStyle = UITableViewCellSelectionStyleNone;
        dayOfWeekCell.dayTitle.text = daysOfWeekNames[indexPath.row];

        BOOL  value = [self fetchSelectedStateForRow:indexPath.row];
        if (value == YES) {
            [self setupSelectedCell:dayOfWeekCell toSelectedState:YES];
        } else {
            [self setupSelectedCell:dayOfWeekCell toSelectedState:NO];
        }
        cell = dayOfWeekCell;
    }
    [self setupEverydayCellState];
    return  cell;
}

#pragma  mark  -  Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kEveryDayOfWeekSection) {
        APCFrequencyEverydayTableViewCell  *everydayCell = (APCFrequencyEverydayTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (self.everyDayWasSelected == NO) {
            self.everyDayWasSelected = YES;
            [self updateAllSelectedDaysListToState:YES];
            everydayCell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            self.everyDayWasSelected = NO;
            everydayCell.accessoryType = UITableViewCellAccessoryNone;
            [self updateAllSelectedDaysListToState:NO];
        }
        for (NSUInteger  day = 0;  day < numberOfDaysOfWeekNames;  day++) {
            NSIndexPath  *path = [NSIndexPath indexPathForRow:day inSection:kDaysOfWeekSection];
            APCFrequencyDayTableViewCell  *cell = (APCFrequencyDayTableViewCell *)[tableView cellForRowAtIndexPath:path];
            [self setupSelectedCell:cell toSelectedState:self.everyDayWasSelected];
        }
    } else if (indexPath.section == kDaysOfWeekSection) {
        APCFrequencyDayTableViewCell  *selectedCell = (APCFrequencyDayTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if ([self fetchSelectedStateForRow:indexPath.row] == NO) {
            [self setupSelectedCell:selectedCell toSelectedState:YES];
            [self updateSelectedDaysListAtRow:indexPath.row forState:YES];
        } else {
            [self setupSelectedCell:selectedCell toSelectedState:NO];
            [self updateSelectedDaysListAtRow:indexPath.row forState:NO];
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
    CGFloat  answer = kAPCMedicationRowHeight;
    
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
    if (self.valueButtons == nil) {
        NSMutableArray  *buttons = [NSMutableArray array];
        for (NSInteger  index = kFirstButtonTagValue;  index <= kLastButtonTagValue;  index++) {
            UIButton  *aButton = (UIButton *)[cell viewWithTag:index];
            [aButton addTarget:self action:@selector(valueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [aButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            aButton.enabled = YES;
            aButton.selected = NO;
            aButton.highlighted = NO;
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
            self.selectedValueButton = button;
            [self setStateForFrequencyButton:button toState:UIControlStateSelected];
        }
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
        if (aButton.isSelected == YES) {
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
        self.selectedValueButton = tappedButton;
    } else if (selectedButton == tappedButton) {
        [self setStateForFrequencyButton:tappedButton toState:UIControlStateNormal];
        self.selectedValueButton = nil;
    } else {
        [self setStateForFrequencyButton:selectedButton toState:UIControlStateNormal];
        [self setStateForFrequencyButton:tappedButton toState:UIControlStateSelected];
        self.selectedValueButton = tappedButton;
    }
    [self setupDoneButtonState];
}

- (BOOL)fetchSelectedStateForRow:(NSInteger)row
{
    NSInteger  answer = NO;
    
    NSNumber  *selected = self.selectedDays[row];
    answer = [selected boolValue];
    return  answer;
}

- (void)updateSelectedDaysListAtRow:(NSInteger)row forState:(BOOL)selected
{
    NSNumber  *number = [NSNumber numberWithBool:selected];
    [self.selectedDays replaceObjectAtIndex:row withObject:number];
}

- (void)updateAllSelectedDaysListToState:(BOOL)selected
{
    for (NSUInteger  index = 0;  index < kAllDaysOfWeekCount;  index++) {
        [self updateSelectedDaysListAtRow:index forState:selected];
    }
}

- (NSUInteger)numberOfSelectedDays
{
    NSUInteger answer = 0;
    
    for (NSUInteger  day = 0;  day < kAllDaysOfWeekCount;  day++) {
        NSNumber  *selected = self.selectedDays[day];
        if ([selected boolValue] == YES) {
            answer = answer + 1;
        }
    }
    return  answer;
}

- (void)setupEverydayCellState
{
    NSUInteger  numberOfSelectedDays = [self numberOfSelectedDays];
    NSIndexPath  *everyday = [NSIndexPath indexPathForRow:0 inSection:kEveryDayOfWeekSection];
    APCFrequencyEverydayTableViewCell  *cell = (APCFrequencyEverydayTableViewCell *)[self.tabulator cellForRowAtIndexPath:everyday];
    if (numberOfSelectedDays >= kAllDaysOfWeekCount) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
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

#pragma  mark  -  Navigation Bar Button Action Methods

- (void)doneButtonTapped:(UIBarButtonItem *) __unused sender
{
    self.doneButtonWasTapped = YES;
    
    UIButton  *valueButton = [self findSelectedButton];
    
    for (NSUInteger  day = 0;  day < numberOfDaysOfWeekNames;  day++) {
        NSNumber  *number = self.selectedDays[day];
        if ([number boolValue] == YES) {
            NSString  *dayName = daysOfWeekNames[day];
            self.daysAndDoses[dayName] = [NSNumber numberWithInteger:(valueButton.tag - kBaseButtonTagValue)];
        }
    }
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(frequencyController:didSelectFrequency:)] == YES) {
            [self.delegate performSelector:@selector(frequencyController:didSelectFrequency:) withObject:self withObject:self.daysAndDoses];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma  mark  -  View Controller Methods

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.doneButtonWasTapped == NO) {
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(frequencyControllerDidCancel:)] == YES) {
                [self.delegate performSelector:@selector(frequencyControllerDidCancel:) withObject:self];
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
    
    self.selectedDays = [NSMutableArray arrayWithCapacity:kAllDaysOfWeekCount];
    for (NSUInteger  index = 0;  index < kAllDaysOfWeekCount;  index++) {
        NSNumber  *selected = [NSNumber numberWithBool:NO];
        [self.selectedDays addObject:selected];
    }
    
    UINib  *frequencyTableTimesCellNib = [UINib nibWithNibName:kFrequencyTableTimesCellName bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:frequencyTableTimesCellNib forCellReuseIdentifier:kFrequencyTableTimesCellName];
    
    UINib  *kFrequencyEverydayTableCellNib = [UINib nibWithNibName:kFrequencyEverydayTableCellName bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:kFrequencyEverydayTableCellNib forCellReuseIdentifier:kFrequencyEverydayTableCellName];
    
    UINib  *kFrequencyDayTableCellNib = [UINib nibWithNibName:kFrequencyDayTableCellName bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:kFrequencyDayTableCellNib forCellReuseIdentifier:kFrequencyDayTableCellName];
    
    if (self.daysNumbersDictionary != nil) {
        self.daysAndDoses = [self.daysNumbersDictionary mutableCopy];
        for (NSUInteger  day = 0;  day < kAllDaysOfWeekCount;  day++) {
            NSString  *key = daysOfWeekNames[day];
            NSNumber  *number = self.daysAndDoses[key];
            if ([number unsignedIntegerValue] > 0) {
                [self updateSelectedDaysListAtRow:day forState:YES];
            }
        }
        self.donester.enabled = YES;
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
