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
#import "APCAddPrescriptionTableViewCell.h"
#import "APCLozengeButton.h"

#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerMedication+Helper.h"
#import "APCMedTrackerPrescription+Helper.h"
#import "APCMedTrackerPossibleDosage+Helper.h"
#import "APCMedTrackerPrescriptionColor+Helper.h"

#import "APCMedicationTrackerCalendarDailyView.h"
#import "NSDate+MedicationTracker.h"

#import "NSBundle+Helper.h"
#import "NSDictionary+APCAdditions.h"
#import "UIFont+APCAppearance.h"
#import "NSDate+Helper.h"
#import "APCLog.h"

static  NSString  *viewControllerTitle   = @"Medication Tracker";

static  NSString  *kSummaryTableViewCell         = @"APCMedicationSummaryTableViewCell";
static  NSString  *kAddPrescriptionTableViewCell = @"APCAddPrescriptionTableViewCell";

@interface APCMedicationTrackerCalendarViewController  ( ) <UITableViewDataSource, UITableViewDelegate,
                                APCMedicationTrackerCalendarWeeklyViewDelegate, UIScrollViewDelegate,
                                APCMedicationTrackerMedicationsDisplayViewDelegate>

@property (nonatomic, weak)  IBOutlet  UIView                     *weekContainer;

@property (nonatomic, weak)  IBOutlet  UIScrollView               *exScrollibur;
@property (nonatomic, assign)          NSUInteger                  exScrolliburNumberOfPages;
@property (nonatomic, assign)          NSUInteger                  exScrolliburCurrentPage;
@property (nonatomic, assign)          BOOL                        exScrolliburScrolledByUser;

@property (nonatomic, weak)  IBOutlet  UITableView                *tabulator;
@property (nonatomic, weak)  IBOutlet  UIView                     *tapItemsView;
@property (nonatomic, weak)  IBOutlet  UIView                     *yourPrescriptionsView;

@property (nonatomic, weak)            APCMedicationTrackerCalendarWeeklyView  *weeklyCalendar;

@property (nonatomic, strong)          NSArray                    *prescriptions;
@property (nonatomic, assign)          BOOL                        calendricalPagesNeedRefresh;
@property (nonatomic, strong)          NSArray                    *calendricalPages;

@property (nonatomic, assign)          BOOL                        viewsWereCreated;

@end

@implementation APCMedicationTrackerCalendarViewController

#pragma  mark  -  Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *) __unused tableView
{
    NSInteger  numberOfSections = 0;
    
    numberOfSections = 1;
    return  numberOfSections;
}

- (NSInteger)tableView:(UITableView *) __unused tableView numberOfRowsInSection:(NSInteger) __unused section
{
        //
        //    one extra row for the Add Medications Cell
        //
        return  [self.prescriptions count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell  *cell = nil;
    
    if ((NSUInteger)indexPath.row == [self.prescriptions count]) {
        APCAddPrescriptionTableViewCell  *aCell = (APCAddPrescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAddPrescriptionTableViewCell];
        cell = aCell;
    } else {
        APCMedicationSummaryTableViewCell  *aCell = (APCMedicationSummaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kSummaryTableViewCell];

        APCMedTrackerPrescription  *prescription = self.prescriptions[indexPath.row];

        aCell.colorswatch.backgroundColor = prescription.color.UIColor;
        aCell.medicationName.text = prescription.medication.name;
        aCell.medicationDosage.text = prescription.dosage.name;
        aCell.selectionStyle = UITableViewCellSelectionStyleNone;

        NSString  *daysAndNumbers = [prescription.frequencyAndDays formatNumbersAndDays];
        aCell.medicationUseDays.text = daysAndNumbers;
        cell = aCell;
    }

    return  cell;
}

#pragma  mark  -  Table View Delegate Methods

- (void)tableView:(UITableView *) __unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((NSUInteger)indexPath.row == [self.prescriptions count]) {
        APCMedicationTrackerSetupViewController  *controller = [[APCMedicationTrackerSetupViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma  mark  -  Daily Calendar View Delegate Methods

- (void)dailyCalendarViewDidSelect:(NSDate *) __unused date
{
}

#pragma  mark  -  Weekly Calendar View Delegate Methods

- (NSUInteger)maximumScrollablePageNumber:(APCMedicationTrackerCalendarWeeklyView *) __unused calendarView
{
    return  self.exScrolliburNumberOfPages;
}

- (NSUInteger)currentScrollablePageNumber:(APCMedicationTrackerCalendarWeeklyView *) __unused calendarView
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

- (void)displayView:(APCMedicationTrackerMedicationsDisplayView *) __unused displayView lozengeButtonWasTapped:(APCLozengeButton *)lozenge
{
    APCMedicationTrackerDetailViewController  *controller = [[APCMedicationTrackerDetailViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
    controller.lozenge = lozenge;
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

- (void)refreshAllPages
{
    for (APCMedicationTrackerMedicationsDisplayView  *page  in  self.calendricalPages) {
        NSDate  *startOfWeekDate = page.startOfWeekDate;
        [page refreshWithPrescriptions:self.prescriptions andDate:startOfWeekDate];
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
    self.tabulator.hidden        = NO;
    self.exScrollibur.hidden     = NO;
    self.weekContainer.hidden    = NO;
    if ([self.prescriptions count] == 0) {
        self.tapItemsView.hidden = YES;
    } else {
        self.tapItemsView.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [APCMedTrackerPrescription fetchAllFromCoreDataAndUseThisQueue: [NSOperationQueue mainQueue]
                                                        toDoThisWhenDone: ^(NSArray *arrayOfGeneratedObjects,
                                                                            NSTimeInterval __unused operationDuration,
                                                                            NSError *error)
     {
         if (error != nil) {
             APCLogError2 (error);
         } else {
             if (([self.prescriptions count] > 0) && ([arrayOfGeneratedObjects count] > [self.prescriptions count])) {
                 self.calendricalPagesNeedRefresh = YES;
             }
             self.prescriptions = arrayOfGeneratedObjects;
             if (self.viewsWereCreated == NO) {
                 [self makeCalendar];
                 [self configureExScrollibur];
                 self.viewsWereCreated = YES;
             }
//             [self setupHiddenStates];
             if ((self.exScrolliburNumberOfPages == 0) && ([self.prescriptions count] > 0)) {
                 [self makeFirstPage];
             }
             [self.tabulator reloadData];
             if (self.calendricalPagesNeedRefresh == YES) {
                 [self refreshAllPages];
                 self.calendricalPagesNeedRefresh = NO;
             }
             [self setupHiddenStates];
         }
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
    
    UINib  *addPrescriptionCellNib = [UINib nibWithNibName:kAddPrescriptionTableViewCell bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:addPrescriptionCellNib forCellReuseIdentifier:kAddPrescriptionTableViewCell];
};

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
