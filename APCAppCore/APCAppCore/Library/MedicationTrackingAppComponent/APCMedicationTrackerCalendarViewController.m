// 
//  APCMedicationTrackerCalendarViewController.m 
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
#import "APCCustomBackButton.h"
#import "NSDate+MedicationTracker.h"

#import "NSBundle+Helper.h"
#import "NSDictionary+APCAdditions.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "NSDate+Helper.h"
#import "APCLog.h"

typedef  enum  _PlacementOfNewPages
{
    PlacementOfNewPagesAtFront = 0,
    PlacementOfNewPagesAtEnd
}  PlacementOfNewPages;

static  NSString  *viewControllerTitle     = @"Medication Tracker";

static  NSString  *kSummaryTableViewCell   = @"APCMedicationSummaryTableViewCell";

static  CGFloat    kAPCMedicationRowHeight = 64.0;

@interface APCMedicationTrackerCalendarViewController  ( ) <UITableViewDataSource, UITableViewDelegate,
                                APCMedicationTrackerCalendarWeeklyViewDelegate, UIScrollViewDelegate,
                                APCMedicationTrackerMedicationsDisplayViewDelegate>

@property (nonatomic, weak)  IBOutlet  UIView                     *weekContainer;

@property (nonatomic, weak)  IBOutlet  UIScrollView               *exScrollibur;
@property (nonatomic, assign)          NSUInteger                  exScrolliburNumberOfPages;
@property (nonatomic, assign)          NSUInteger                  exScrolliburNumberOfFramesPerPage;
@property (nonatomic, assign)          NSUInteger                  exScrolliburCurrentPage;
@property (nonatomic, assign)          BOOL                        exScrolliburScrolledByUser;

@property (nonatomic, weak)  IBOutlet  UITableView                *tabulator;

@property (nonatomic, weak)  IBOutlet  UIView                     *tapItemsView;
@property (nonatomic, weak)  IBOutlet  UILabel                    *tapItemsLabel;
@property (nonatomic, weak)  IBOutlet  UIView                     *yourPrescriptionsView;
@property (nonatomic, weak)  IBOutlet  UIButton                   *editButton;
@property (nonatomic, assign)          BOOL                        tableViewEditingModeIsExplicit;

@property (nonatomic, weak)            APCMedicationTrackerCalendarWeeklyView  *weeklyCalendar;

@property (nonatomic, strong)          NSArray                    *prescriptions;
@property (nonatomic, strong)          APCMedTrackerPrescription  *prescriptionToExpire;
@property (nonatomic, assign)          BOOL                        calendricalPagesNeedRefresh;
@property (nonatomic, strong)          NSArray                    *calendricalPages;

@property (nonatomic, assign)          BOOL                        viewsWereCreated;

@end

@implementation APCMedicationTrackerCalendarViewController

- (void)dealloc {
    _exScrollibur.delegate = nil;
    _tabulator.delegate = nil;
    _tabulator.dataSource = nil;
}

#pragma  mark  -  Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *) __unused tableView
{
    NSInteger  numberOfSections = 0;
    
    numberOfSections = 1;
    return  numberOfSections;
}

- (NSInteger)tableView:(UITableView *) __unused tableView numberOfRowsInSection:(NSInteger) __unused section
{
        return  [self.prescriptions count];
}

- (NSString *)extractFirstPartOfMedicationName:(NSString *)aName
{
    NSString  *answer = nil;
    NSRange  range = [aName rangeOfString:@" ("];
    if (range.location == NSNotFound) {
        answer = aName;
    } else {
        answer = [aName substringToIndex:range.location];
    }
    return  answer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCMedicationSummaryTableViewCell  *cell = (APCMedicationSummaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kSummaryTableViewCell];

    APCMedTrackerPrescription  *prescription = self.prescriptions[indexPath.row];

    cell.colorswatch.backgroundColor = prescription.color.UIColor;
    NSString  *shortened = [self extractFirstPartOfMedicationName:prescription.medication.name];
    cell.medicationName.text = shortened;
    cell.medicationDosage.text = prescription.dosage.name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSString  *daysAndNumbers = [prescription.frequencyAndDays formatNumbersAndDays];
    cell.medicationUseDays.text = daysAndNumbers;

    return  cell;
}

#pragma  mark  -  Table View Regular Delegate Methods

- (CGFloat)tableView:(UITableView *) __unused tableView heightForRowAtIndexPath:(NSIndexPath *) __unused indexPath
{
    return  kAPCMedicationRowHeight;
}

#pragma  mark  -  Table View Editing Delegate Methods

- (BOOL)tableView:(UITableView *) __unused tableView canEditRowAtIndexPath:(NSIndexPath *) __unused indexPath
{
    return  YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *) __unused tableView editingStyleForRowAtIndexPath:(NSIndexPath *) __unused indexPath
{
    return  UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *) __unused tableView willBeginEditingRowAtIndexPath:(NSIndexPath *) __unused indexPath
{
    if (self.tableViewEditingModeIsExplicit == NO) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.editButton.enabled = NO;
        [self.editButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    }
}

- (void)tableView:(UITableView *) __unused tableView didEndEditingRowAtIndexPath:(NSIndexPath *) __unused indexPath
{
    if (self.tableViewEditingModeIsExplicit == NO) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.editButton.enabled = YES;
        [self.editButton setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
        [self.tabulator setEditing:NO animated:YES];
    }
}

- (void)tableView:(UITableView *) __unused tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController  *alerter = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please Confirm Removal", nil)
                                       message:NSLocalizedString(@"This Action Cannot Be Undone", nil)
                                preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction  *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel
                                                               handler:^(UIAlertAction  __unused *action)
        {
            if (self.tableViewEditingModeIsExplicit == NO) {
                [self.tabulator setEditing:NO animated:YES];
            }
        }];
        [alerter addAction:cancelAction];
        UIAlertAction  *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive
                                                               handler:^(UIAlertAction  __unused *action)
        {
            [self deleteRowFromTable:indexPath];
       }];
        [alerter addAction:deleteAction];
        
        [self presentViewController: alerter animated: YES completion: nil];
    }
}

- (void)deleteRowFromTable:(NSIndexPath *)indexPath
{
        self.prescriptionToExpire = self.prescriptions[indexPath.row];

        NSMutableArray  *temp = [self.prescriptions mutableCopy];
        [temp removeObjectAtIndex:indexPath.row];
        self.prescriptions = temp;

        NSArray  *paths = @[ indexPath ];
        [self.tabulator deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];

        [self.prescriptionToExpire expirePrescriptionAndUseThisQueue: (NSOperationQueue *) [NSOperationQueue mainQueue]
                                                    toDoThisWhenDone: ^(NSTimeInterval __unused operationDuration,
                                                                      NSError *error)
         {
             if (error != nil) {
                 APCLogError2 (error);
             } else {
                 [self fetchAllPrescriptions];
                 if ([self.prescriptions count] == 0) {
                     if (self.tableViewEditingModeIsExplicit == YES) {
                         [self editButtonWasTapped:self.editButton];
                     }
                 }
                 [self.view setNeedsDisplay];
                 [self refreshAllPages];
                 [self setupHiddenStates];
             }
         }];
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
        if (self.exScrolliburCurrentPage != (self.exScrolliburNumberOfPages - 1)) {
            self.exScrolliburCurrentPage = self.exScrolliburCurrentPage + 1;
            CGRect  rect = CGRectMake(CGRectGetWidth(self.exScrollibur.frame) * (self.exScrolliburCurrentPage), 0.0, CGRectGetWidth(self.exScrollibur.frame), CGRectGetHeight(self.exScrollibur.frame));
            [self.exScrollibur scrollRectToVisible:rect animated:YES];
        } else {
            APCMedicationTrackerMedicationsDisplayView  *lastView = [self.calendricalPages lastObject];
            NSDate  *startOfWeekDate = [lastView.startOfWeekDate dateByAddingDays:7];
            APCMedicationTrackerMedicationsDisplayView  *view = [self makeWaterfallPageForPageNumber:self.exScrolliburNumberOfPages andNumberOfFrames:self.exScrolliburNumberOfFramesPerPage
                                                                                  andStartOfWeekDate:startOfWeekDate  placement:PlacementOfNewPagesAtEnd];
            self.exScrollibur.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * (self.exScrolliburNumberOfPages + 1), self.exScrollibur.contentSize.height);
            
            self.exScrolliburNumberOfPages = self.exScrolliburNumberOfPages + 1;
            NSMutableArray  *newPages = [self.calendricalPages mutableCopy];
            [newPages addObject: view];
            self.calendricalPages = newPages;
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
        if (self.exScrolliburCurrentPage != 0) {
            self.exScrolliburCurrentPage = self.exScrolliburCurrentPage - 1;
            CGRect  rect = CGRectMake(self.exScrolliburCurrentPage * CGRectGetWidth(self.exScrollibur.frame), 0.0, CGRectGetWidth(self.exScrollibur.frame), CGRectGetHeight(self.exScrollibur.frame));
            [self.exScrollibur scrollRectToVisible:rect animated:YES];
        } else {
            APCMedicationTrackerMedicationsDisplayView  *firstView = [self.calendricalPages firstObject];
            NSDate  *startOfWeekDate = [firstView.startOfWeekDate dateByAddingDays:-7];
            APCMedicationTrackerMedicationsDisplayView  *view = [self makeWaterfallPageForPageNumber:0 andNumberOfFrames:self.exScrolliburNumberOfFramesPerPage
                                                                                  andStartOfWeekDate:startOfWeekDate  placement:PlacementOfNewPagesAtFront];
            self.exScrollibur.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * (self.exScrolliburNumberOfPages + 1), self.exScrollibur.contentSize.height);
            
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
            CGRect  rect = CGRectMake(0.0, 0.0, CGRectGetWidth(self.exScrollibur.frame), CGRectGetHeight(self.exScrollibur.frame));
            [self.exScrollibur scrollRectToVisible:rect animated:YES];
        }
    }
    self.exScrolliburScrolledByUser = NO;
}

#pragma  mark  -  Lozenge Display Pages Delegate Method

- (void)displayView:(APCMedicationTrackerMedicationsDisplayView *) __unused displayView lozengeButtonWasTapped:(APCLozengeButton *)lozenge
{
    if ([lozenge.currentDate isEarlierOrEqualToDate:[NSDate date]]) {
        APCMedicationTrackerDetailViewController  *controller = [[APCMedicationTrackerDetailViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
        controller.lozenge = lozenge;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma  mark  -  Calendar Pages Management

- (void)adjustExScrolliburContentHeightForPrescriptions:(NSUInteger)numberOfPrescriptions
{
    NSUInteger  numberOfFrames = [APCMedicationTrackerMedicationsDisplayView numberOfPagesForPrescriptions:numberOfPrescriptions inFrameHeight:CGRectGetHeight(self.exScrollibur.frame)];
    CGSize   contentSize = self.exScrollibur.bounds.size;
    contentSize.width  = contentSize.width * self.exScrolliburNumberOfPages;
    contentSize.height = contentSize.height * numberOfFrames;
    self.exScrollibur.contentSize = contentSize;
    self.exScrolliburNumberOfFramesPerPage = numberOfFrames;
}

- (void)configureExScrollibur
{
    self.exScrollibur.scrollEnabled = YES;
    self.exScrollibur.pagingEnabled = YES;
    self.exScrollibur.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.exScrollibur.frame));
    if ([self.prescriptions count] != 0) {
        [self adjustExScrolliburContentHeightForPrescriptions:[self.prescriptions count]];
    }
    self.exScrollibur.showsHorizontalScrollIndicator = NO;
    self.exScrollibur.showsVerticalScrollIndicator   = NO;
    self.exScrollibur.directionalLockEnabled         = YES;
    self.exScrollibur.scrollsToTop = NO;
    self.exScrolliburCurrentPage = 0;
    self.exScrollibur.delegate = self;
}

- (void)animateViewVisibility:(APCMedicationTrackerMedicationsDisplayView *)aView
{
    aView.alpha = 0.0;
    [UIView beginAnimations:@"FadeToBlack" context:NULL];
    [UIView setAnimationDuration:1.25];
    aView.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)makeEmptyScrollView
{
    NSArray  *subviews = [self.exScrollibur subviews];
    [subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)makeBlankPage
{
    [self makeEmptyScrollView];
    
    CGRect  frame = CGRectZero;
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = CGRectGetHeight(self.exScrollibur.frame);
    APCMedicationTrackerMedicationsDisplayView  *view = [[APCMedicationTrackerMedicationsDisplayView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    self.exScrolliburNumberOfPages = 0;
    self.exScrolliburCurrentPage   = 0;
    [self.exScrollibur addSubview:view];
    [self.weeklyCalendar enableScrolling:NO];
    
    [self animateViewVisibility:view];
}

- (void)makeFirstPage
{
    [self makeEmptyScrollView];
    
    NSArray  *dayViews = [self.weeklyCalendar fetchDailyCalendarDayViews];
    APCMedicationTrackerCalendarDailyView  *dayView = (APCMedicationTrackerCalendarDailyView *)[dayViews firstObject];
    NSDate  *startOfWeekDate = dayView.date;
    APCMedicationTrackerMedicationsDisplayView  *view = [self makeWaterfallPageForPageNumber:0 andNumberOfFrames:(NSUInteger)self.exScrolliburNumberOfFramesPerPage
                                                                          andStartOfWeekDate:startOfWeekDate placement:PlacementOfNewPagesAtEnd];
    self.exScrolliburNumberOfPages = 1;
    self.exScrolliburCurrentPage   = 0;
    self.calendricalPages = @[ view ];
    [self.weeklyCalendar enableScrolling:YES];
    
    [self animateViewVisibility:view];
}

- (APCMedicationTrackerMedicationsDisplayView *)makeWaterfallPageForPageNumber:(NSUInteger)pageNumber andNumberOfFrames:(NSUInteger)numberOfFramesPerPage
                                                            andStartOfWeekDate:(NSDate *)startOfWeekDate placement:(PlacementOfNewPages)placement
{
    CGRect viewFrame = self.view.frame;
    CGSize  scrollerContentSize = self.exScrollibur.contentSize;
    CGRect  frame = CGRectZero;
    frame.origin.x = CGRectGetWidth(viewFrame) * pageNumber;
    frame.origin.y = 0.0;
    frame.size.width = CGRectGetWidth(viewFrame);
    frame.size.height = scrollerContentSize.height;
    APCMedicationTrackerMedicationsDisplayView  *view = [[APCMedicationTrackerMedicationsDisplayView alloc] initWithFrame:frame];
    view.delegate = self;
    view.numberOfFramesPerPage = numberOfFramesPerPage;
    view.backgroundColor = [UIColor whiteColor];
    if (placement == PlacementOfNewPagesAtEnd) {
        [self.exScrollibur addSubview:view];
    } else {
        [self.exScrollibur insertSubview:view atIndex:0];
    }
    [view makePrescriptionDisplaysWithPrescriptions:self.prescriptions andNumberOfFrames:self.exScrolliburNumberOfFramesPerPage andDate:startOfWeekDate];
    [self animateViewVisibility:view];
    return  view;
}

- (void)refreshAllPages
{
    [self adjustExScrolliburContentHeightForPrescriptions:[self.prescriptions count]];
    for (APCMedicationTrackerMedicationsDisplayView  *page  in  self.calendricalPages) {
        NSDate  *startOfWeekDate = page.startOfWeekDate;
        CGRect  pageFrame = page.frame;
        CGSize  scrollerContentSize = self.exScrollibur.contentSize;
        pageFrame.size.height = scrollerContentSize.height;
        page.frame = pageFrame;
        [page refreshWithPrescriptions:self.prescriptions andNumberOfFrames:self.exScrolliburNumberOfFramesPerPage andDate:startOfWeekDate];
    }
    [self.view setNeedsDisplay];
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
        self.exScrolliburScrolledByUser = NO;
    }
}

#pragma  mark  -  Exit Medication Tracker Action Method

- (void)exitMedicationTracker:(id)__unused sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)]) {
            [self.delegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
        }
    }
}

#pragma  mark  -  Add Medication Action Method

- (void)addMedicationWasTapped:(id)__unused sender
{
    APCMedicationTrackerSetupViewController *controller = [[APCMedicationTrackerSetupViewController alloc] initWithNibName:nil
                                                                                                                    bundle:[NSBundle appleCoreBundle]
                                                                                                        withResourceBundle:self.resourceBundle
                                                                                                          andResourceNames:self.resourceNames];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma  mark  -  Edit/Done Button Action Method

- (IBAction)editButtonWasTapped:(UIButton *) __unused sender
{
    NSString  *title = nil;
    if (self.tabulator.isEditing == NO) {
        [self.tabulator setEditing:YES animated:YES];
        self.tableViewEditingModeIsExplicit = YES;
        title = NSLocalizedString(@"Done", nil);
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        [self.tabulator setEditing:NO animated:YES];
        title = NSLocalizedString(@"Edit", nil);
        self.tableViewEditingModeIsExplicit = NO;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    [self.editButton setTitle:title forState:UIControlStateNormal];
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
        self.tapItemsLabel.text = NSLocalizedString(@"Tap the “+” Sign to Create Prescriptions", nil);
        self.yourPrescriptionsView.hidden = YES;
        self.editButton.hidden = YES;
    } else {
        self.tapItemsLabel.text = NSLocalizedString(@"Tap on Items Above to Log Intake", nil);
        self.yourPrescriptionsView.hidden = NO;
        self.editButton.hidden = NO;
    }
}

- (void)fetchAllPrescriptions
{
    [APCMedTrackerPrescription fetchAllFromCoreDataAndUseThisQueue: [NSOperationQueue mainQueue]
                                                  toDoThisWhenDone: ^(NSArray *arrayOfGeneratedObjects,
                                                                      NSTimeInterval __unused operationDuration,
                                                                      NSError *error)
     {
         if (error != nil) {
             APCLogError2 (error);
         } else {
             NSPredicate  *predicate = [NSPredicate predicateWithFormat: @"%K == YES", NSStringFromSelector (@selector(isActive))];
             NSArray  *activePrescriptions = [arrayOfGeneratedObjects filteredArrayUsingPredicate:predicate];
             
             if (([self.prescriptions count] > 0) && ([activePrescriptions count] > [self.prescriptions count])) {
                 self.calendricalPagesNeedRefresh = YES;
             }
             self.prescriptions = activePrescriptions;
             [self adjustExScrolliburContentHeightForPrescriptions:[self.prescriptions count]];
             
             if (self.viewsWereCreated == NO) {
                 [self makeCalendar];
                 [self configureExScrollibur];
                 self.viewsWereCreated = YES;
             }
             if ([self.prescriptions count] == 0) {
                 [self makeBlankPage];
             } else if (self.exScrolliburNumberOfPages == 0) {
                 [self makeFirstPage];
             }
             [self.tabulator reloadData];
             if (self.calendricalPagesNeedRefresh) {
                 [self refreshAllPages];
                 self.calendricalPagesNeedRefresh = NO;
             }
             [self setupHiddenStates];
         }
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationItem.leftBarButtonItem == nil) {
        UIBarButtonItem  *backster = [APCCustomBackButton customBackBarButtonItemWithTarget:self action:@selector(exitMedicationTracker:) tintColor:[UIColor appPrimaryColor]];
        self.navigationItem.leftBarButtonItem = backster;
    }
    [self fetchAllPrescriptions];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.prescriptions    = [NSArray array];
    self.calendricalPages = [NSArray array];
    
    self.exScrolliburScrolledByUser = NO;
    
    if (self.resourceBundle && self.resourceNames) {
        [APCMedTrackerDataStorageManager startupWithCustomDataInBundle:self.resourceBundle
                                                     withResourceNames:self.resourceNames
                                                   andThenUseThisQueue:nil
                                                              toDoThis:NULL];
    } else {
        [APCMedTrackerDataStorageManager startupReloadingDefaults:YES andThenUseThisQueue:nil toDoThis:NULL];
    }

    self.navigationItem.title = viewControllerTitle;
    
    UIBarButtonItem  *addster = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMedicationWasTapped:)];
    self.navigationItem.rightBarButtonItem = addster;
    
    self.editButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [self.editButton setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
    
    UINib  *summaryCellNib = [UINib nibWithNibName:kSummaryTableViewCell bundle:[NSBundle appleCoreBundle]];
    [self.tabulator registerNib:summaryCellNib forCellReuseIdentifier:kSummaryTableViewCell];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
