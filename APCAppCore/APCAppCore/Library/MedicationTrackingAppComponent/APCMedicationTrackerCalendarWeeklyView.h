//
//  APCMedicationTrackerCalendarWeeklyView.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  APCMedicationTrackerCalendarWeeklyView;

@protocol APCMedicationTrackerCalendarWeeklyViewDelegate <NSObject>

- (void)dailyCalendarViewDidSelect:(NSDate *)date;

- (NSUInteger)currentScrollablePageNumber:(APCMedicationTrackerCalendarWeeklyView *)calendarView;
- (NSUInteger)maximumScrollablePageNumber:(APCMedicationTrackerCalendarWeeklyView *)calendarView;
- (void)dailyCalendarViewDidSwipeLeft;
- (void)dailyCalendarViewDidSwipeRight;

@end


@interface APCMedicationTrackerCalendarWeeklyView : UIView

@property  (nonatomic, strong)  NSNumber  *firstDayOfWeek;
@property  (nonatomic, weak)    id  <APCMedicationTrackerCalendarWeeklyViewDelegate>  delegate;
@property  (nonatomic, strong)  NSDate    *selectedDate;

- (void)setupViews;

- (void)swipeLeft:(UISwipeGestureRecognizer *)swipe;
- (void)swipeRight:(UISwipeGestureRecognizer *)swipe;


- (void)redrawToDate:(NSDate *)date;

@end
