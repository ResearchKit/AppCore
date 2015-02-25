//
//  APCMedicationTrackerCalendarWeeklyView.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationTrackerCalendarWeeklyView.h"
#import "APCMedicationTrackerCalendarDailyView.h"
#import "APCMedicationTrackerDayTitleLabel.h"

#import "NSDate+MedicationTracker.h"
#import "UIColor+MedicationTracker.h"
#import "NSDictionary+MedicationTracker.h"

static  NSUInteger  kNumberOfWeekDivisions =   7;

static  CGFloat  kDayTitleViewHeight       =  20.0;
static  CGFloat  kDayTitleFontSize         =  11.0;
static  CGFloat  kDateTitleMarginTop       =   4.0;

static  CGFloat  kDateViewHeight           =  28.0;

static  CGFloat  kDateLabelInfoHeight      =  20.0;

static  NSInteger const  kCalendarWeekStartDayDefault              = 1;
static  NSString* const  kCalendarSelectedDatePrintFormatDefault   = @"EEE, d MMM yyyy";
static  CGFloat   const  kCalendarSelectedDatePrintFontSizeDefault = 13.0;

static  NSString  *kPerformScrollDirectionKey = @"kPerformScrollDirectionKey";
static  NSString  *kSelectedDateKey           = @"SelectedDateKey";
static  NSString  *kSelectedDateIsTodayKey    = @"kSelectedDateIsTodayKey";

@interface APCMedicationTrackerCalendarWeeklyView  ( ) <UIGestureRecognizerDelegate, APCMedicationTrackerCalendarDailyViewDelegate>

@property  (nonatomic,  strong)  UIView    *backdrop;
@property  (nonatomic,  strong)  UIView    *dailySubViewContainer;
@property  (nonatomic,  strong)  UIView    *dayTitleSubViewContainer;
@property  (nonatomic,  strong)  UIView    *dailyInfoSubViewContainer;
@property  (nonatomic,  strong)  UILabel   *dateInfoLabel;
@property  (nonatomic,  strong)  NSDate    *startDate;
@property  (nonatomic,  strong)  NSDate    *endOfWeekDate;

@property  (nonatomic,  strong)  NSNumber  *weekStartConfig;
@property  (nonatomic,  strong)  UIColor   *dayTitleTextColor;
@property  (nonatomic,  strong)  NSString  *selectedDatePrintFormat;
@property  (nonatomic,  strong)  UIColor   *selectedDatePrintColor;
@property  (nonatomic, assign)   CGFloat   selectedDatePrintFontSize;

@end

@implementation APCMedicationTrackerCalendarWeeklyView

#pragma  mark  -  Initialisation

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
    }
    return self;
}

- (void)setupViews
{
    {
        UIView  *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height)];
        self.backdrop = view;
        [self addSubview:self.backdrop];
        [self setupBackdrop];
    }
    {
        UIView  *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, kDateTitleMarginTop, self.bounds.size.width, kDayTitleViewHeight)];
        self.dayTitleSubViewContainer = view;
        self.dayTitleSubViewContainer.backgroundColor = [UIColor clearColor];
        self.dayTitleSubViewContainer.userInteractionEnabled = YES;
        [self.backdrop addSubview:self.dayTitleSubViewContainer];
    }
    {
        UIView  *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, kDateTitleMarginTop + kDayTitleViewHeight, self.bounds.size.width, kDateViewHeight)];
        self.dailySubViewContainer = view;
        self.dailySubViewContainer.backgroundColor = [UIColor clearColor];
        self.dailySubViewContainer.userInteractionEnabled = YES;
        [self.backdrop addSubview:self.dailySubViewContainer];
    }
    {
        UILabel  *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.backdrop.frame), kDateLabelInfoHeight)];
        self.dateInfoLabel = label;
        self.dateInfoLabel.textAlignment = NSTextAlignmentCenter;
        self.dateInfoLabel.userInteractionEnabled = YES;
        self.dateInfoLabel.font = [UIFont systemFontOfSize: kCalendarSelectedDatePrintFontSizeDefault];
        self.dateInfoLabel.textColor = [UIColor blackColor];
        self.dateInfoLabel.backgroundColor = [UIColor clearColor];
    }
    {
        UIView  *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, kDateTitleMarginTop + kDayTitleViewHeight + kDateViewHeight, CGRectGetWidth(self.backdrop.frame), kDateLabelInfoHeight)];
        self.dailyInfoSubViewContainer = view;
        self.dailyInfoSubViewContainer.userInteractionEnabled = YES;
        self.dailyInfoSubViewContainer.backgroundColor = [UIColor clearColor];
        [self.backdrop addSubview:self.dailyInfoSubViewContainer];

        [self.dailyInfoSubViewContainer addSubview:self.dateInfoLabel];
        [self.dailyInfoSubViewContainer bringSubviewToFront:self.dateInfoLabel];
        [self markDateSelected:[NSDate date]];

        UITapGestureRecognizer  *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dailyInfoViewDidClick:)];
        [self.dailyInfoSubViewContainer addGestureRecognizer:singleFingerTap];
    }
    [self initDailyViews];
}

- (void)setupBackdrop
{
    self.backdrop.userInteractionEnabled = YES;
    UISwipeGestureRecognizer  *rightSwipeGesturer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [rightSwipeGesturer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.backdrop addGestureRecognizer:rightSwipeGesturer];
    rightSwipeGesturer.delegate = self;

    UISwipeGestureRecognizer  *leftSwipeGesturer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [leftSwipeGesturer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.backdrop addGestureRecognizer:leftSwipeGesturer];
    leftSwipeGesturer.delegate = self;

    self.backdrop.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
}

- (void)initDailyViews
{
    CGFloat dailyWidth = self.bounds.size.width / kNumberOfWeekDivisions;
    NSDate  *today = [NSDate new];
    NSInteger  weekStartOrdinal = [self.firstDayOfWeek integerValue];
    if (weekStartOrdinal == 0) {
        weekStartOrdinal = kCalendarWeekStartDayDefault;
    }
    NSDate  *startOfWeekDate = [today getWeekStartDate:weekStartOrdinal];
    self.startDate = startOfWeekDate;

    for (UIView  *view in [self.dailySubViewContainer subviews]) {
        [view removeFromSuperview];
    }
    for (UIView  *view in [self.dayTitleSubViewContainer subviews]) {
        [view removeFromSuperview];
    }
    for (NSUInteger  day = 0;  day < kNumberOfWeekDivisions;  day++) {
        NSDate  *date = [startOfWeekDate addDays:day];

        [self dayTitleViewForDate:date withFrame: CGRectMake(dailyWidth * day, 0, dailyWidth, kDayTitleViewHeight)];

        [self dailyViewForDate:date withFrame: CGRectMake(dailyWidth * day, 0, dailyWidth, kDateViewHeight) ];

        self.endOfWeekDate = date;
    }
    [self dailyCalendarViewDidSelect:[NSDate new]];
}

- (UILabel *)dayTitleViewForDate:(NSDate *)date withFrame:(CGRect)frame
{
    APCMedicationTrackerDayTitleLabel  *dayTitleLabel = [[APCMedicationTrackerDayTitleLabel alloc] initWithFrame:frame];
    dayTitleLabel.backgroundColor = [UIColor clearColor];
    dayTitleLabel.textColor = self.dayTitleTextColor;
    dayTitleLabel.textAlignment = NSTextAlignmentCenter;
    dayTitleLabel.font = [UIFont systemFontOfSize:kDayTitleFontSize];

    dayTitleLabel.text = [[date getDayOfWeekShortString] uppercaseString];
    dayTitleLabel.date = date;
    dayTitleLabel.userInteractionEnabled = YES;

    UITapGestureRecognizer  *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dayTitleViewDidClick:)];
    [dayTitleLabel addGestureRecognizer:singleFingerTap];
    [self setNeedsDisplay];

    [self.dayTitleSubViewContainer addSubview:dayTitleLabel];
    return  dayTitleLabel;
}

- (APCMedicationTrackerCalendarDailyView *)dailyViewForDate:(NSDate *)date withFrame:(CGRect)frame
{
    APCMedicationTrackerCalendarDailyView  *view = [[APCMedicationTrackerCalendarDailyView alloc] initWithFrame:frame];
    view.date = date;
    view.backgroundColor = [UIColor clearColor];
    view.delegate = self;
    [self.dailySubViewContainer addSubview:view];
    return  view;
}

- (NSArray *)fetchDailyCalendarDayViews
{
    NSArray  *subviews = [self.dailySubViewContainer subviews];
    return  subviews;
}

- (void)markDateSelected:(NSDate *)date
{
    for (APCMedicationTrackerCalendarDailyView  *view in [self.dailySubViewContainer subviews]) {
        [view markSelected:([view.date isSameDateWith:date])];
    }
    self.selectedDate = date;
    NSDateFormatter  *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:kCalendarSelectedDatePrintFormatDefault];
    NSString  *dateString = [dayFormatter stringFromDate:date];

    self.dateInfoLabel.text = dateString;
}

- (void)dailyInfoViewDidClick:(UIGestureRecognizer *)tap
{
}

- (void)dayTitleViewDidClick:(UIGestureRecognizer *)tap
{
}

- (void)redrawToDate:(NSDate *)date
{
    if ([date isWithinDate:self.startDate toDate:self.endOfWeekDate] == NO) {
        BOOL  swipeRight = ([date compare:self.startDate] == NSOrderedAscending);
        if (swipeRight == YES) {
            [self performSwipeAnimation:WeeklyCalendarScrollDirectionRight blnToday:[date isDateToday] selectedDate:date];
        } else {
            [self performSwipeAnimation:WeeklyCalendarScrollDirectionLeft blnToday:[date isDateToday] selectedDate:date];
        }
    }
    [self dailyCalendarViewDidSelect:date];
}

- (void)redrawCalenderData
{
    [self redrawToDate:self.selectedDate];
}

#pragma  mark  -  Swipe Gesture Recognisers

- (void)swipeLeft:(UISwipeGestureRecognizer *)swipe
{
    NSUInteger  pageNumber = [self.delegate currentScrollablePageNumber:self];
    if (pageNumber != 0) {
        [self performSwipeAnimation:WeeklyCalendarScrollDirectionLeft blnToday:NO selectedDate:nil];
    }
}

- (void)swipeRight:(UISwipeGestureRecognizer *)swipe
{
    NSUInteger  maximumPageNumber = [self.delegate maximumScrollablePageNumber:self];
    NSUInteger  pageNumber = [self.delegate currentScrollablePageNumber:self];
    if (pageNumber < maximumPageNumber) {
        [self performSwipeAnimation:WeeklyCalendarScrollDirectionRight blnToday:NO selectedDate:nil];
    }
}

- (void)performSwipeAnimation:(WeeklyCalendarScrollDirection)scrollDirection blnToday:(BOOL)blnToday selectedDate:(NSDate *)selectedDate
{
    CATransition  *animation = [CATransition animation];
    animation.delegate = self;
    animation.type = kCATransitionPush;
    if (scrollDirection == WeeklyCalendarScrollDirectionRight) {
        animation.subtype = kCATransitionFromRight;
    } else {
        animation.subtype = kCATransitionFromLeft;
    }
    animation.duration = 0.50;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.dailySubViewContainer.layer addAnimation:animation forKey:kCATransition];

    NSMutableDictionary  *data = @{
                                kPerformScrollDirectionKey : [NSNumber numberWithUnsignedInteger:scrollDirection],
                                kSelectedDateIsTodayKey    : [NSNumber numberWithBool:blnToday]
                                }.mutableCopy;
    
    if (scrollDirection == WeeklyCalendarScrollDirectionRight) {
        [self.delegate dailyCalendarViewDidSwipeLeft];
    } else {
        [self.delegate dailyCalendarViewDidSwipeRight];
    }
    if (selectedDate != nil) {
        [data setObject:selectedDate forKey:kSelectedDateKey];
    }
    [self performSelector:@selector(displaySwipeDates:) withObject:data afterDelay:0.05f];
}

- (void)displaySwipeDates:(NSDictionary *)param
{
    NSInteger  step = 0;
    if ([param[kPerformScrollDirectionKey] unsignedIntegerValue] == WeeklyCalendarScrollDirectionRight) {
        step = +1;
    } else {
        step = -1;
    }

    BOOL  blnToday = [param[kSelectedDateIsTodayKey] boolValue];
    NSDate  *selectedDate = [param objectForKeyWithNil:kSelectedDateKey];
    CGFloat  dailyWidth = self.bounds.size.width / kNumberOfWeekDivisions;

    NSDate  *dtStart = nil;
    if (blnToday == YES) {
        dtStart = [[NSDate new] getWeekStartDate:self.weekStartConfig.integerValue];
    } else {
        dtStart = (selectedDate)? [selectedDate getWeekStartDate:self.weekStartConfig.integerValue]:[self.startDate addDays:step * 7];
    }
    self.startDate = dtStart;
    for (UIView  *view in [self.dailySubViewContainer subviews]) {
        [view removeFromSuperview];
    }

    for (NSUInteger  days = 0;  days < kNumberOfWeekDivisions;  days++) {
        NSDate  *aDate = [dtStart addDays:days];

        APCMedicationTrackerCalendarDailyView  *view = [self dailyViewForDate:aDate withFrame: CGRectMake(dailyWidth * days, 0, dailyWidth, kDateViewHeight) ];
        APCMedicationTrackerDayTitleLabel  *titleLabel = [[self.dayTitleSubViewContainer subviews] objectAtIndex:days];
        titleLabel.date = aDate;

        [view markSelected:([view.date isSameDateWith:self.selectedDate])];
        self.endOfWeekDate = aDate;
    }
}

#pragma  mark  -  DeputyDailyCalendarViewDelegate

- (void)dailyCalendarViewDidSelect:(NSDate *)date
{
    [self markDateSelected:date];
    [self.delegate dailyCalendarViewDidSelect:date];
}

@end
