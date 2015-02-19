//
//  APCMedicationTrackerCalendarViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationTrackerCalendarViewController.h"
#import "APCMedicationTrackerCalendarWeeklyView.h"
#import "APCMedicationTrackerMedicationsDisplayView.h"
#import "APCMedicationTrackerDetailViewController.h"
#import "APCMedicationTrackerSetupViewController.h"
#import "APCMedicationSummaryTableViewCell.h"
#import "APCMedicationModel.h"
#import "APCMedicationFollower.h"
#import "APCLozengeButton.h"

#import "NSBundle+Helper.h"

static  NSString  *viewControllerTitle   = @"Medication Tracker";

static  NSString  *kSummaryTableViewCell = @"APCMedicationSummaryTableViewCell";

static  NSString   *daysOfWeekNames[]    = { @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday" };
static  NSUInteger  numberOfDaysOfWeek   = (sizeof(daysOfWeekNames) / sizeof(NSString *));

static  CGFloat  kLozengeButtonWidth     = 40.0;
static  CGFloat  kLozengeButtonHeight    = 25.0;
static  CGFloat  kLozengeBaseYCoordinate = 10.0;
static  CGFloat  kLozengeBaseYStepOver   = 45.0;

@interface APCMedicationTrackerCalendarViewController  ( ) <UITableViewDataSource, UITableViewDelegate, APCMedicationTrackerSetupViewControllerDelegate, APCMedicationTrackerCalendarWeeklyViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak)  IBOutlet  UIView                     *weekContainer;

@property (nonatomic, weak)  IBOutlet  UIScrollView               *exScrollibur;
@property (nonatomic, assign)          NSUInteger                  exScrolliburNumberOfPages;
@property (nonatomic, assign)          NSUInteger                  exScrolliburCurrentPage;
@property (nonatomic, assign)          BOOL                        exScrolliburScrolledByUser;

@property (nonatomic, weak)  IBOutlet  UITableView                *tabulator;

@property (nonatomic, weak)            APCMedicationTrackerCalendarWeeklyView      *weekCalendar;

@property (nonatomic, weak)  IBOutlet  UIView                     *noMedicationView;

@property (nonatomic, weak)            APCMedicationTrackerMedicationsDisplayView  *medicationsDisplayer;

@property (nonatomic, strong)          NSArray                    *medications;
@property (nonatomic, strong)          NSArray                    *weeksArray;
@property (nonatomic, strong)          NSDictionary               *colormap;

@property (nonatomic, assign)          BOOL                        viewsWereCreated;

@end

@implementation APCMedicationTrackerCalendarViewController

#pragma  mark  -  Medication Tracker Setup Delegate Methods

- (void)medicationSetup:(APCMedicationTrackerSetupViewController *)medicationSetup didCreateMedications:(NSArray *)theMedications
{
    if ([theMedications count] > 0) {
        if ([self.medications count] == 0) {
            self.medications = theMedications;
        } else {
            NSMutableArray  *temp = [self.medications mutableCopy];
            [temp addObjectsFromArray:theMedications];
            self.medications = temp;
        }
        if ([self.medications count] > 0) {
            self.tabulator.hidden        = NO;
            self.exScrollibur.hidden     = NO;
            self.weekContainer.hidden    = NO;
            self.noMedicationView.hidden = YES;
            [self.tabulator reloadData];
        }
    }
}

#pragma  mark  -  Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.medications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCMedicationSummaryTableViewCell  *cell = (APCMedicationSummaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kSummaryTableViewCell];

    APCMedicationModel  *model = self.medications[indexPath.row];

    cell.colorswatch.backgroundColor = self.colormap[model.medicationLabelColor];
    cell.medicationName.text = model.medicationName;
    cell.medicationDosage.text = model.medicationDosageText;

    NSDictionary  *frequencyAndDays = model.frequencyAndDays;

    NSMutableString  *daysAndNumbers = [NSMutableString string];
    for (NSUInteger  day = 0;  day < numberOfDaysOfWeek;  day++) {
        NSString  *key = daysOfWeekNames[day];
        NSNumber  *number = [frequencyAndDays objectForKey:key];
        if ([number integerValue] > 0) {
            if (daysAndNumbers.length == 0) {
                [daysAndNumbers appendFormat:@"%ld\u2009\u00d7, %@", [number integerValue], [key substringToIndex:3]];
            } else {
                [daysAndNumbers appendFormat:@", %@", [key substringToIndex:3]];
            }
        }
    }
    cell.medicationUseDays.text = daysAndNumbers;

    return  cell;
}

#pragma  mark  -  Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCMedicationTrackerDetailViewController  *controller = [[APCMedicationTrackerDetailViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
    APCMedicationModel  *model = self.medications[indexPath.row];
    controller.model = model;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma  mark  -  Calendar View Delegate Methods

- (void)dailyCalendarViewDidSelect:(NSDate *)date
{
}

- (NSUInteger)currentScrollablePageNumber:(APCMedicationTrackerCalendarWeeklyView *)calendarView
{
    return self.exScrolliburCurrentPage;
}

- (void)dailyCalendarViewDidSwipeLeft
{
    if (self.exScrolliburScrolledByUser == NO) {
        if (self.exScrolliburCurrentPage < (self.exScrolliburNumberOfPages - 1)) {
            CGRect  rect = CGRectMake(CGRectGetWidth(self.exScrollibur.frame) * (self.exScrolliburCurrentPage + 1), 0.0, CGRectGetWidth(self.exScrollibur.frame), CGRectGetHeight(self.exScrollibur.frame));
            [self.exScrollibur scrollRectToVisible:rect animated:YES];
            self.exScrolliburCurrentPage = self.exScrolliburCurrentPage + 1;
        }
    }
    self.exScrolliburScrolledByUser = NO;
}

- (void)dailyCalendarViewDidSwipeRight
{
    if (self.exScrolliburScrolledByUser == NO) {
        if (self.exScrolliburCurrentPage > 0) {
            CGRect  rect = CGRectMake(CGRectGetWidth(self.exScrollibur.frame) * (self.exScrolliburCurrentPage - 1), 0.0, CGRectGetWidth(self.exScrollibur.frame), CGRectGetHeight(self.exScrollibur.frame));
            [self.exScrollibur scrollRectToVisible:rect animated:YES];
            self.exScrolliburCurrentPage = self.exScrolliburCurrentPage - 1;
        }
    }
    self.exScrolliburScrolledByUser = NO;
}

#pragma  mark  -  Add Medications Action Method

- (IBAction)addMedicationsButtonTapped:(id)sender
{
    APCMedicationTrackerSetupViewController  *controller = [[APCMedicationTrackerSetupViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma  mark  -  Lozenge Buttons Methods

- (void)lozengeButtonWasTapped:(APCLozengeButton *)sender
{
    APCMedicationTrackerDetailViewController  *controller = [[APCMedicationTrackerDetailViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
    controller.model = sender.model;
    controller.follower = sender;
    [self.navigationController pushViewController:controller animated:YES];
}

- (APCLozengeButton *)medicationLozengeCenteredAtPoint:(CGPoint)point andColor:(UIColor *)color withTitle:(NSString *)title
{
    APCLozengeButton  *button = [APCLozengeButton buttonWithType:UIButtonTypeCustom];
    CGRect  frame = CGRectMake(0.0, 0.0, kLozengeButtonWidth, kLozengeButtonHeight);
    frame.origin = point;
    frame.origin.x = point.x - (kLozengeButtonWidth / 2.0);
    button.frame = frame;

    button.backgroundColor = [UIColor whiteColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];

    [button addTarget:self action:@selector(lozengeButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];

    return  button;
}

- (APCMedicationFollower *)makeMedicationFollowerWithModel:(APCMedicationModel *)model forDayOfWeek:(NSString *)weekday
{
    APCMedicationFollower  *follower = [[APCMedicationFollower alloc] init];
    follower.medicationName = model.medicationName;
    NSDictionary  *dictionary = model.frequencyAndDays;
    follower.numberOfDosesPrescribed = dictionary[weekday];
    return  follower;
}

- (void)makeLozengesLayout
{
    NSDictionary  *map = @{ @"Monday" : @(0.0), @"Tuesday" : @(1.0), @"Wednesday" : @(2.0), @"Thursday" : @(3.0), @"Friday" : @(4.0), @"Saturday" : @(5.0), @"Sunday" : @(6.0), };

    CGFloat  disp = CGRectGetWidth(self.view.bounds) / 7.0;
    CGFloat  baseYCoordinate = kLozengeBaseYCoordinate;
        //
        //    NSNumber objects in the code below are initalised with integer values
        //
    APCMedicationTrackerMedicationsDisplayView  *view = [[self.exScrollibur subviews] objectAtIndex:self.exScrolliburCurrentPage];

    for (APCMedicationModel  *model  in  self.medications) {
        NSDictionary  *dictionary = model.frequencyAndDays;
        for (NSUInteger  day = 0;  day < numberOfDaysOfWeek;  day++) {
            NSString  *dayOfWeek = daysOfWeekNames[day];
            NSNumber  *number = dictionary[dayOfWeek];
            if ([number integerValue] > 0) {
                CGFloat  xPosition = ([map[dayOfWeek] floatValue] + 1) * disp - disp / 2.0;
                NSString  *colorName = model.medicationLabelColor;
                UIColor  *color = self.colormap[colorName];
                APCLozengeButton  *button = [self medicationLozengeCenteredAtPoint:CGPointMake(xPosition, baseYCoordinate) andColor:color withTitle:@"0\u2009/\u20093"];
                button.follower = [self makeMedicationFollowerWithModel:model forDayOfWeek:dayOfWeek];
                button.model = model;
                [view addSubview:button];
            }
        }
        baseYCoordinate = baseYCoordinate + kLozengeBaseYStepOver;
    }
    [view setNeedsDisplay];
}

#pragma  mark  -  Scroll View Delegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.exScrollibur) {
        self.exScrolliburScrolledByUser = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.exScrollibur) {
        NSUInteger  oldPage = self.exScrolliburCurrentPage;
        CGFloat  pageWidth = CGRectGetWidth(self.exScrollibur.frame);
        NSUInteger  newPage = floor((self.exScrollibur.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        if (newPage != oldPage) {
            self.exScrolliburCurrentPage = newPage;
            if (newPage > oldPage) {
                [self.weekCalendar swipeLeft:nil];
            } else {
                [self.weekCalendar swipeRight:nil];
            }
        }
    }
}

#pragma  mark  -  View Controller Methods

- (void)makeCalendar
{
   APCMedicationTrackerCalendarWeeklyView  *weekly = [[APCMedicationTrackerCalendarWeeklyView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.weekContainer.bounds))];
    self.weekCalendar = weekly;
    self.weekCalendar.firstDayOfWeek = [NSNumber numberWithInteger:1];

    [self.weekContainer addSubview:self.weekCalendar];

    [self.weekCalendar setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.weekContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.weekContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.weekCalendar attribute:NSLayoutAttributeTop
                                                              multiplier:1 constant:0]];

    [self.weekContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.weekContainer attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.weekCalendar attribute:NSLayoutAttributeLeading
                                                              multiplier:1 constant:0]];

    [self.weekContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.weekContainer attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.weekCalendar attribute:NSLayoutAttributeTrailing
                                                              multiplier:1 constant:0]];

    [self.weekContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.weekContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.weekCalendar attribute:NSLayoutAttributeBottom
                                                              multiplier:1 constant:0]];
    [self.weekCalendar setupViews];
    self.weekCalendar.delegate = self;
}

- (void)makePages
{
    self.exScrollibur.pagingEnabled = YES;
    self.exScrollibur.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * 4, CGRectGetHeight(self.view.frame));
    self.exScrollibur.showsHorizontalScrollIndicator = NO;
    self.exScrollibur.showsVerticalScrollIndicator = NO;
    self.exScrollibur.scrollsToTop = NO;
    self.exScrolliburCurrentPage = 0;
    self.exScrollibur.delegate = self;

    for (NSUInteger  page = 0;  page < 4;  page++) {
        CGRect viewFrame = self.view.frame;
        CGRect scrollerFrame = self.exScrollibur.frame;
        CGRect  frame = CGRectZero;
        frame.origin.x = CGRectGetWidth(viewFrame) * page;
        frame.origin.y = 0;
        frame.size.width = CGRectGetWidth(viewFrame);
        frame.size.height = CGRectGetHeight(scrollerFrame);
        APCMedicationTrackerMedicationsDisplayView  *view = [[APCMedicationTrackerMedicationsDisplayView alloc] initWithFrame:frame];
        view.backgroundColor = [UIColor whiteColor];
        [self.exScrollibur addSubview:view];
    }
}

- (void)setupHiddenStates
{
    if ([self.medications count] == 0) {
        self.tabulator.hidden        = YES;
        self.exScrollibur.hidden     = YES;
        self.weekContainer.hidden    = YES;
        self.noMedicationView.hidden = NO;
    } else {
        self.noMedicationView.hidden = YES;
        self.tabulator.hidden        = NO;
        self.exScrollibur.hidden     = NO;
        self.weekContainer.hidden    = NO;
    }
}

- (void)makeDummyModels
{
    APCMedicationModel  *model01 = [[APCMedicationModel alloc] init];
    model01.medicationName = @"Aspirin";
    model01.medicationLabelColor = @"Green";
    model01.medicationDosageValue = @(10);
    model01.medicationDosageText = @"10mg";
    model01.frequencyAndDays = @{
                                 @"Monday"  : @(3),
                                 @"Tuesday" : @(0),
                                 @"Wednesday" : @(3),
                                 @"Thursday" : @(0),
                                 @"Friday" : @(3),
                                 @"Saturday" : @(0),
                                 @"Sunday" : @(0)
                                 };
    APCMedicationModel  *model02 = [[APCMedicationModel alloc] init];
    model02.medicationName = @"Dopamine";
    model02.medicationLabelColor = @"Purple";
    model02.medicationDosageValue = @(2.5);
    model02.medicationDosageText = @"2.5mg";
    model02.frequencyAndDays = @{
                                 @"Monday"  : @(0),
                                 @"Tuesday" : @(2),
                                 @"Wednesday" : @(0),
                                 @"Thursday" : @(2),
                                 @"Friday" : @(0),
                                 @"Saturday" : @(2),
                                 @"Sunday" : @(0)
                                 };
    APCMedicationModel  *model03 = [[APCMedicationModel alloc] init];
    model03.medicationName = @"Marijuana";
    model03.medicationLabelColor = @"Orange";
    model03.medicationDosageValue = @(5);
    model03.medicationDosageText = @"5mg";
    model03.frequencyAndDays = @{
                                 @"Monday"  : @(0),
                                 @"Tuesday" : @(0),
                                 @"Wednesday" : @(2),
                                 @"Thursday" : @(0),
                                 @"Friday" : @(0),
                                 @"Saturday" : @(2),
                                 @"Sunday" : @(0)
                                 };
    self.medications = @[  model01, model02, model03 ];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.cancelButtonItem.title = NSLocalizedString(@"Done", @"Done");
    if (self.viewsWereCreated == NO) {
        [self makeCalendar];
        [self makePages];
        if ([self.medications count] == 0) {
            [self makeDummyModels];
        }
        [self setupHiddenStates];
        [self makeLozengesLayout];
        self.viewsWereCreated = YES;
    }
    [self.tabulator reloadData];
    [self.view setNeedsDisplay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = viewControllerTitle;

    self.colormap = @{
                      @"Gray"    : [UIColor grayColor],
                      @"Red"     : [UIColor redColor],
                      @"Green"   : [UIColor greenColor],
                      @"Blue"    : [UIColor blueColor],
                      @"Cyan"    : [UIColor cyanColor],
                      @"Magenta" : [UIColor magentaColor],
                      @"Yellow"  : [UIColor yellowColor],
                      @"Orange"  : [UIColor orangeColor],
                      @"Purple"  : [UIColor purpleColor]
                      };

    UINib  *summaryCellNib = [UINib nibWithNibName:kSummaryTableViewCell bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:summaryCellNib forCellReuseIdentifier:kSummaryTableViewCell];
};

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
