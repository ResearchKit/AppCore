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
#import "APCLozengeButton.h"

#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerMedication+Helper.h"
#import "APCMedTrackerPrescription+Helper.h"
#import "APCMedTrackerPossibleDosage+Helper.h"
#import "APCMedTrackerPrescriptionColor+Helper.h"

#import "APCMedicationTrackerCalendarDailyView.h"
#import "NSDate+MedicationTracker.h"

#import "NSBundle+Helper.h"
#import "NSDate+Helper.h"

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

@property (nonatomic, weak)            APCMedicationTrackerCalendarWeeklyView  *weeklyCalendar;

@property (nonatomic, weak)  IBOutlet  UIView                     *noMedicationView;

@property (nonatomic, strong)          NSArray                    *prescriptions;
@property (nonatomic, strong)          NSArray                    *calendricalPages;

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
    return  [self.prescriptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCMedicationSummaryTableViewCell  *cell = (APCMedicationSummaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kSummaryTableViewCell];

    APCMedTrackerPrescription  *prescription = self.prescriptions[indexPath.row];

    cell.colorswatch.backgroundColor = prescription.color.UIColor;
    cell.medicationName.text = prescription.medication.name;
    cell.medicationDosage.text = prescription.dosage.name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSDictionary  *frequencyAndDays = prescription.frequencyAndDays;

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
    if (YES == NO) {
        APCMedicationTrackerDetailViewController  *controller = [[APCMedicationTrackerDetailViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
        APCMedTrackerPrescription  *prescription = self.prescriptions[indexPath.row];
        controller.lozenge.prescription = prescription;
        [self.navigationController pushViewController:controller animated:YES];
    }
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
        if (((self.exScrolliburNumberOfPages + 1) > self.exScrolliburNumberOfPages) && (self.exScrolliburCurrentPage == self.exScrolliburNumberOfPages - 1)) {
            APCMedicationTrackerMedicationsDisplayView  *lastView = [self.calendricalPages lastObject];
            NSDate  *startOfWeekDate = [lastView.startOfWeekDate dateByAddingDays:7];
            APCMedicationTrackerMedicationsDisplayView  *view = [self makeWaterfallPageForPageNumber:self.exScrolliburNumberOfPages andStartOfWeekDate:startOfWeekDate  insertAtFront:NO];
            self.exScrollibur.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * (self.exScrolliburNumberOfPages + 1), CGRectGetHeight(self.exScrollibur.frame));
            self.exScrolliburNumberOfPages = self.exScrolliburNumberOfPages + 1;
            NSMutableArray  *newPages = [self.calendricalPages mutableCopy];
            [newPages addObject: view];
            self.calendricalPages = newPages;
        }
        CGRect  rect = CGRectMake(CGRectGetWidth(self.exScrollibur.frame) * (self.exScrolliburCurrentPage + 1), 0.0, CGRectGetWidth(self.exScrollibur.frame), CGRectGetHeight(self.exScrollibur.frame));
        [self.exScrollibur scrollRectToVisible:rect animated:YES];
        self.exScrolliburCurrentPage = self.exScrolliburCurrentPage + 1;
    }
    self.exScrolliburScrolledByUser = NO;
}

- (void)dailyCalendarViewDidSwipeRight
{
    if (self.exScrolliburScrolledByUser == NO) {
        if (self.exScrolliburCurrentPage == 0) {
            APCMedicationTrackerMedicationsDisplayView  *firstView = [self.calendricalPages firstObject];
            NSDate  *startOfWeekDate = [firstView.startOfWeekDate dateByAddingDays:-7];
            APCMedicationTrackerMedicationsDisplayView  *view = [self makeWaterfallPageForPageNumber:0 andStartOfWeekDate:startOfWeekDate  insertAtFront:YES];
            self.exScrollibur.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * (self.exScrolliburNumberOfPages + 1), CGRectGetHeight(self.exScrollibur.frame));
            self.exScrolliburNumberOfPages = self.exScrolliburNumberOfPages + 1;
            self.exScrolliburCurrentPage = 0;
            NSMutableArray  *newPages = [self.calendricalPages mutableCopy];
            [newPages insertObject: view atIndex:0];
            self.calendricalPages = newPages;
            NSArray  *pages = [self.exScrollibur subviews];
            NSUInteger  index = 0;
            for (UIView  *view  in  pages) {
                CGRect  frame = view.frame;
                frame.origin.x = CGRectGetWidth(self.view.frame) * index;
                view.frame = frame;
                index = index + 1;
            }
        }
        CGRect  rect = CGRectMake(CGRectGetWidth(self.exScrollibur.frame) * (self.exScrolliburCurrentPage - 1), 0.0, CGRectGetWidth(self.exScrollibur.frame), CGRectGetHeight(self.exScrollibur.frame));
        [self.exScrollibur scrollRectToVisible:rect animated:YES];
        if (self.exScrolliburCurrentPage > 0) {
            self.exScrolliburCurrentPage = self.exScrolliburCurrentPage - 1;
        }
    }
    self.exScrolliburScrolledByUser = NO;
}

#pragma  mark  -  Lozenge Display Pages Delegate Method

- (void)displayView:(APCMedicationTrackerMedicationsDisplayView *)displayView lozengeButtonWasTapped:(APCLozengeButton *)lozenge
{
    APCMedicationTrackerDetailViewController  *controller = [[APCMedicationTrackerDetailViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
    controller.lozenge = lozenge;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma  mark  -  Add Medications Action Method

- (IBAction)addMedicationsButtonTapped:(id)sender
{
    APCMedicationTrackerSetupViewController  *controller = [[APCMedicationTrackerSetupViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma  mark  -  Calendar Pages Management

- (void)configureExScrollibur
{
    self.exScrollibur.scrollEnabled = NO;
    self.exScrollibur.pagingEnabled = YES;
    self.exScrollibur.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.exScrollibur.frame));
    self.exScrollibur.showsHorizontalScrollIndicator = NO;
    self.exScrollibur.showsVerticalScrollIndicator = NO;
    self.exScrollibur.scrollsToTop = NO;
    self.exScrolliburCurrentPage = 0;
    self.exScrollibur.delegate = self;
}

- (void)makeFirstPage
{
    NSArray  *dayViews = [self.weeklyCalendar fetchDailyCalendarDayViews];
    APCMedicationTrackerCalendarDailyView  *dayView = (APCMedicationTrackerCalendarDailyView *)[dayViews firstObject];
    NSDate  *startOfWeekDate = dayView.date;
    APCMedicationTrackerMedicationsDisplayView  *view = [self makeWaterfallPageForPageNumber:0 andStartOfWeekDate:startOfWeekDate insertAtFront:NO];
    self.exScrolliburNumberOfPages = 1;
    self.exScrolliburCurrentPage = 0;
    self.calendricalPages = @[ view ];
}

- (APCMedicationTrackerMedicationsDisplayView *)makeWaterfallPageForPageNumber:(NSUInteger)pageNumber andStartOfWeekDate:(NSDate *)startOfWeekDate insertAtFront:(BOOL)insert
{
    CGRect viewFrame = self.view.frame;
    CGRect scrollerFrame = self.exScrollibur.frame;
    CGRect  frame = CGRectZero;
    frame.origin.x = CGRectGetWidth(viewFrame) * pageNumber;
    frame.origin.y = 0;
    frame.size.width = CGRectGetWidth(viewFrame);
    frame.size.height = CGRectGetHeight(scrollerFrame);
    APCMedicationTrackerMedicationsDisplayView  *view = [[APCMedicationTrackerMedicationsDisplayView alloc] initWithFrame:frame];
    view.delegate = self;
    view.backgroundColor = [UIColor whiteColor];
    if (insert == NO) {
        [self.exScrollibur addSubview:view];
    } else {
        [self.exScrollibur insertSubview:view atIndex:0];
    }
    [view makePrescriptionDisplaysWithPrescriptions:self.prescriptions andDate:startOfWeekDate];
    return  view;
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
            if (newPage > oldPage) {
                [self.weeklyCalendar swipeLeft:nil];
            } else {
                [self.weeklyCalendar swipeRight:nil];
            }
            self.exScrolliburCurrentPage = newPage;
        }
    }
}

#pragma  mark  -  View Controller Methods

- (void)makeCalendar
{
   APCMedicationTrackerCalendarWeeklyView  *weekly = [[APCMedicationTrackerCalendarWeeklyView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.weekContainer.bounds))];
    self.weeklyCalendar = weekly;
    self.weeklyCalendar.firstDayOfWeek = [NSNumber numberWithInteger:1];

    [self.weekContainer addSubview:self.weeklyCalendar];

    [self.weeklyCalendar setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.weekContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.weekContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.weeklyCalendar attribute:NSLayoutAttributeTop
                                                              multiplier:1 constant:0]];

    [self.weekContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.weekContainer attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.weeklyCalendar attribute:NSLayoutAttributeLeading
                                                              multiplier:1 constant:0]];

    [self.weekContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.weekContainer attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.weeklyCalendar attribute:NSLayoutAttributeTrailing
                                                              multiplier:1 constant:0]];

    [self.weekContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.weekContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.weeklyCalendar attribute:NSLayoutAttributeBottom
                                                              multiplier:1 constant:0]];
    [self.weeklyCalendar setupViews];
    self.weeklyCalendar.delegate = self;
}

- (void)setupHiddenStates
{
    if ([self.prescriptions count] == 0) {
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [APCMedTrackerPrescription fetchAllFromCoreDataAndUseThisQueue: [NSOperationQueue mainQueue]
                                                        toDoThisWhenDone: ^(NSArray *arrayOfGeneratedObjects,
                                                                            NSTimeInterval operationDuration,
                                                                            NSError *error)
     {
         self.prescriptions = arrayOfGeneratedObjects;
         if (self.viewsWereCreated == NO) {
             [self makeCalendar];
             [self setupHiddenStates];
             [self configureExScrollibur];
             [self makeFirstPage];
             self.viewsWereCreated = YES;
         }
         [self.tabulator reloadData];
     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.prescriptions = [NSArray array];
    
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
