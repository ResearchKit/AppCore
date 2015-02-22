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
#import "APCLozengeButton.h"

#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerMedication+Helper.h"
#import "APCMedTrackerMedicationSchedule+Helper.h"
#import "APCMedTrackerPossibleDosage+Helper.h"
#import "APCMedTrackerScheduleColor+Helper.h"
#import "APCMedTrackerMedicationSchedule+Helper.h"

#import "NSBundle+Helper.h"

static  NSString  *viewControllerTitle   = @"Medication Tracker";

static  NSString  *kSummaryTableViewCell = @"APCMedicationSummaryTableViewCell";

static  NSString   *daysOfWeekNames[]    = { @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday" };
static  NSUInteger  numberOfDaysOfWeek   = (sizeof(daysOfWeekNames) / sizeof(NSString *));

@interface APCMedicationTrackerCalendarViewController  ( ) <UITableViewDataSource, UITableViewDelegate,
                                APCMedicationTrackerCalendarWeeklyViewDelegate, UIScrollViewDelegate,
                                APCMedicationTrackerMedicationsDisplayViewDelegate>

@property (nonatomic, weak)  IBOutlet  UIView                     *weekContainer;

@property (nonatomic, weak)  IBOutlet  UIScrollView               *exScrollibur;
@property (nonatomic, assign)          NSUInteger                  exScrolliburNumberOfPages;
@property (nonatomic, assign)          NSUInteger                  exScrolliburCurrentPage;
@property (nonatomic, assign)          BOOL                        exScrolliburScrolledByUser;

@property (nonatomic, weak)  IBOutlet  UITableView                *tabulator;

@property (nonatomic, weak)            APCMedicationTrackerCalendarWeeklyView      *weekCalendar;

@property (nonatomic, weak)  IBOutlet  UIView                     *noMedicationView;

@property (nonatomic, weak)            APCMedicationTrackerMedicationsDisplayView  *medicationsDisplayer;

@property (nonatomic, strong)          NSArray                    *schedules;
@property (nonatomic, strong)          NSArray                    *weeksArray;
//@property (nonatomic, strong)          NSDictionary               *colormap;

@property (nonatomic, assign)          BOOL                        viewsWereCreated;

@end

@implementation APCMedicationTrackerCalendarViewController

#pragma  mark  -  Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.schedules count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCMedicationSummaryTableViewCell  *cell = (APCMedicationSummaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kSummaryTableViewCell];

    APCMedTrackerMedicationSchedule  *schedule = self.schedules[indexPath.row];

    cell.colorswatch.backgroundColor = schedule.color.UIColor;
    cell.medicationName.text = schedule.medicine.name;
    cell.medicationDosage.text = schedule.dosage.name;

    NSDictionary  *frequencyAndDays = schedule.frequenciesAndDays;

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
    APCMedTrackerMedicationSchedule  *schedule = self.schedules[indexPath.row];
    controller.schedule = schedule;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma  mark  -  Daily Calendar View Delegate Methods

- (void)dailyCalendarViewDidSelect:(NSDate *)date
{
}

#pragma  mark  -  Weekly Calendar View Delegate Methods

- (NSUInteger)maximumScrollablePageNumber:(APCMedicationTrackerCalendarWeeklyView *)calendarView
{
    return  self.exScrolliburNumberOfPages;
}

- (NSUInteger)currentScrollablePageNumber:(APCMedicationTrackerCalendarWeeklyView *)calendarView
{
    return  self.exScrolliburCurrentPage;
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

#pragma  mark  -  Lozenge Display Pages Delegate Method

- (void)displayView:(APCMedicationTrackerMedicationsDisplayView *)displayView lozengeButtonWasTapped:(APCLozengeButton *)lozenge
{
    APCMedicationTrackerDetailViewController  *controller = [[APCMedicationTrackerDetailViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
    controller.schedule = lozenge.schedule;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma  mark  -  Add Medications Action Method

- (IBAction)addMedicationsButtonTapped:(id)sender
{
    APCMedicationTrackerSetupViewController  *controller = [[APCMedicationTrackerSetupViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)makePages
{
    self.exScrollibur.pagingEnabled = YES;
    self.exScrollibur.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * 4, CGRectGetHeight(self.exScrollibur.frame));
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
        view.delegate = self;
        view.schedules = self.schedules;
        view.backgroundColor = [UIColor whiteColor];
        [self.exScrollibur addSubview:view];
        [view setNeedsDisplay];
    }
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

- (void)setupHiddenStates
{
    if ([self.schedules count] == 0) {
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

    //
    //    We're keeping this commented out code for now
    //        but intend to delete it if we don't res-instate it
    //

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//     NSLog(@"APCMedicationTrackerCalendarViewController viewDidAppear");
//    self.cancelButtonItem.title = NSLocalizedString(@"Done", @"Done");
//    if (self.viewsWereCreated == NO) {
//        [self makeCalendar];
////        if ([self.schedules count] == 0) {
//////            [self makeDummyModels];
////        }
//        [self makePages];
////        [self setupHiddenStates];
//        self.viewsWereCreated = YES;
//    }
//    [self.tabulator reloadData];
//    [self.view setNeedsDisplay];
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.schedules = [NSArray array];
    
    [APCMedTrackerMedicationSchedule fetchAllFromCoreDataAndUseThisQueue: [NSOperationQueue mainQueue]
                                                        toDoThisWhenDone: ^(NSArray *arrayOfGeneratedObjects,
                                                                            NSTimeInterval operationDuration,
                                                                            NSError *error)
     {
         self.schedules = arrayOfGeneratedObjects;
         [self makeCalendar];
         [self setupHiddenStates];
         [self.tabulator reloadData];
         [self makePages];
     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.schedules = [NSArray array];
    
    [APCMedTrackerDataStorageManager startupReloadingDefaults:YES andThenUseThisQueue:nil toDoThis:NULL];

    self.navigationItem.title = viewControllerTitle;
    
    self.cancelButtonItem.title = NSLocalizedString(@"Done", @"Done");

    UINib  *summaryCellNib = [UINib nibWithNibName:kSummaryTableViewCell bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:summaryCellNib forCellReuseIdentifier:kSummaryTableViewCell];
};

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
