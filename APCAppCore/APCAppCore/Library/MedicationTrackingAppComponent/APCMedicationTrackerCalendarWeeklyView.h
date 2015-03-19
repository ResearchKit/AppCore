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

typedef  enum  _WeeklyCalendarScrollDirection
{
    WeeklyCalendarScrollDirectionLeft = 0,
    WeeklyCalendarScrollDirectionRight
}  WeeklyCalendarScrollDirection;

@interface APCMedicationTrackerCalendarWeeklyView : UIView

@property  (nonatomic, strong)  NSNumber  *firstDayOfWeek;
@property  (nonatomic, weak)    id  <APCMedicationTrackerCalendarWeeklyViewDelegate>  delegate;
@property  (nonatomic, strong)  NSDate    *selectedDate;
@property  (nonatomic, strong)  NSArray   *dayDates;

- (NSArray *)fetchDailyCalendarDayViews;

- (void)setupViews;

- (void)enableScrolling:(BOOL)enable;

- (void)swipeLeft:(UISwipeGestureRecognizer *)swiper;
- (void)swipeRight:(UISwipeGestureRecognizer *)swiper;

- (void)redrawToDate:(NSDate *)date;

@end
