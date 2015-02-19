//
//  APCAppCore.m
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


@interface APCMedicationTrackerCalendarWeeklyView  ( ) <UIGestureRecognizerDelegate, APCMedicationTrackerCalendarWeeklyViewDelegate>

@property  (nonatomic,  strong)  UIView    *backdrop;
@property  (nonatomic,  strong)  UIView    *dailySubViewContainer;
@property  (nonatomic,  strong)  UIView    *dayTitleSubViewContainer;
@property  (nonatomic,  strong)  UIView    *dailyInfoSubViewContainer;
@property  (nonatomic,  strong)  UILabel   *dateInfoLabel;
@property  (nonatomic,  strong)  NSDate    *startDate;
@property  (nonatomic,  strong)  NSDate    *endDate;

@property  (nonatomic,  strong)  NSNumber  *weekStartConfig;
@property  (nonatomic,  strong)  UIColor   *dayTitleTextColor;
@property  (nonatomic,  strong)  NSString  *selectedDatePrintFormat;
@property  (nonatomic,  strong)  UIColor   *selectedDatePrintColor;
@property  (nonatomic, assign)   CGFloat   selectedDatePrintFontSize;

@end

@implementation APCMedicationTrackerCalendarWeeklyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
    }
    return self;
}

//- (void)setDelegate:(id<APCAppCoreDelegate>)delegate
//{
//    _delegate = delegate;
//}

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

- (UIView *)dailySubViewContainer
{
    if (_dailySubViewContainer == nil) {
        _dailySubViewContainer = [[UIImageView alloc] initWithFrame:CGRectMake(0, kDateTitleMarginTop + kDayTitleViewHeight, self.bounds.size.width, kDateViewHeight)];
        _dailySubViewContainer.backgroundColor = [UIColor clearColor];
        _dailySubViewContainer.userInteractionEnabled = YES;
    }
    return  _dailySubViewContainer;
}

- (void)initDailyViews
{
    CGFloat dailyWidth = self.bounds.size.width / kNumberOfWeekDivisions;
    NSDate  *today = [NSDate new];
    NSInteger  weekStartOrdinal = self.firstDayOfWeek.integerValue;
    if (weekStartOrdinal == 0) {
        weekStartOrdinal = kCalendarWeekStartDayDefault;
    }
    NSDate  *dtWeekStart = [today getWeekStartDate:weekStartOrdinal];
    self.startDate = dtWeekStart;

    for (UIView  *v in [self.dailySubViewContainer subviews]) {
        [v removeFromSuperview];
    }
    for (UIView  *v in [self.dayTitleSubViewContainer subviews]) {
        [v removeFromSuperview];
    }
    for (NSUInteger  i = 0;  i < kNumberOfWeekDivisions;  i++) {
        NSDate  *dt = [dtWeekStart addDays:i];

        [self dayTitleViewForDate: dt inFrame: CGRectMake(dailyWidth*i, 0, dailyWidth, kDayTitleViewHeight)];

        [self dailyViewForDate:dt inFrame: CGRectMake(dailyWidth*i, 0, dailyWidth, kDateViewHeight) ];

        self.endDate = dt;
    }
    [self dailyCalendarViewDidSelect:[NSDate new]];
}

- (UILabel *)dayTitleViewForDate:(NSDate *)date inFrame:(CGRect)frame
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

- (APCMedicationTrackerCalendarDailyView *)dailyViewForDate:(NSDate *)date inFrame:(CGRect)frame
{
    APCMedicationTrackerCalendarDailyView  *view = [[APCMedicationTrackerCalendarDailyView alloc] initWithFrame:frame];
    view.date = date;
    view.backgroundColor = [UIColor clearColor];
    view.delegate = self;
    [self.dailySubViewContainer addSubview:view];
    return  view;
}

- (void)drawRect:(CGRect)rect
{
    [self initDailyViews];
}

- (void)markDateSelected:(NSDate *)date
{
    for (APCMedicationTrackerCalendarDailyView  *v in [self.dailySubViewContainer subviews]) {
        [v markSelected:([v.date isSameDateWith:date])];
    }
    self.selectedDate = date;
    NSDateFormatter  *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:kCalendarSelectedDatePrintFormatDefault];
    NSString  *strDate = [dayFormatter stringFromDate:date];
//    if ([date isDateToday]) {
//        strDate = [NSString stringWithFormat:@"%@", strDate ];
//    }

//    [self adjustDailyInfoLabelAndWeatherIcon : NO];

    self.dateInfoLabel.text = strDate;
}

- (void)dailyInfoViewDidClick:(UIGestureRecognizer *)tap
{
//    [self redrawToDate:[NSDate new] ];
}

- (void)dayTitleViewDidClick:(UIGestureRecognizer *)tap
{
//    [self redrawToDate:((DayTitleLabel *)tap.view).date];
}

- (void)redrawToDate:(NSDate *)date
{
    if ([date isWithinDate:self.startDate toDate:self.endDate] == NO) {
        BOOL  swipeRight = ([date compare:self.startDate] == NSOrderedAscending);
        [self delegateSwipeAnimation:swipeRight blnToday:[date isDateToday] selectedDate:date];
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
        [self delegateSwipeAnimation:NO blnToday:NO selectedDate:nil];
    }
}

- (void)swipeRight:(UISwipeGestureRecognizer *)swipe
{
    [self delegateSwipeAnimation:YES blnToday:NO selectedDate:nil];
}

- (void)delegateSwipeAnimation:(BOOL)blnSwipeRight blnToday:(BOOL)blnToday selectedDate:(NSDate *)selectedDate
{
    CATransition  *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:(blnSwipeRight)?kCATransitionFromLeft:kCATransitionFromRight];
    [animation setDuration:0.50];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.dailySubViewContainer.layer addAnimation:animation forKey:kCATransition];

    NSMutableDictionary  *data = @{
                                @"blnSwipeRight" : [NSNumber numberWithBool:blnSwipeRight],
                                @"blnToday"      : [NSNumber numberWithBool:blnToday]
                                }.mutableCopy;
    NSLog(@"At End of delegateSwipeAnimation");
    if (blnSwipeRight == NO) {
        [self.delegate dailyCalendarViewDidSwipeLeft];
    } else {
        [self.delegate dailyCalendarViewDidSwipeRight];
    }

    if (selectedDate != nil) {
        [data setObject:selectedDate forKey:@"selectedDate"];
    }
    [self performSelector:@selector(renderSwipeDates:) withObject:data afterDelay:0.05f];
}

- (void)renderSwipeDates:(NSDictionary *)param
{
    NSInteger  step = ([[param objectForKey:@"blnSwipeRight"] boolValue])? -1 : 1;
    BOOL  blnToday = [[param objectForKey:@"blnToday"] boolValue];
    NSDate  *selectedDate = [param objectForKeyWithNil:@"selectedDate"];
    CGFloat  dailyWidth = self.bounds.size.width / kNumberOfWeekDivisions;

    NSDate  *dtStart = nil;
    if (blnToday == YES) {
        dtStart = [[NSDate new] getWeekStartDate:self.weekStartConfig.integerValue];
    } else {
        dtStart = (selectedDate)? [selectedDate getWeekStartDate:self.weekStartConfig.integerValue]:[self.startDate addDays:step*7];
    }
    self.startDate = dtStart;
    for (UIView  *v in [self.dailySubViewContainer subviews]) {
        [v removeFromSuperview];
    }

    for (NSUInteger  i = 0;  i < kNumberOfWeekDivisions;  i++) {
        NSDate  *dt = [dtStart addDays:i];

        APCMedicationTrackerCalendarDailyView  *view = [self dailyViewForDate:dt inFrame: CGRectMake(dailyWidth*i, 0, dailyWidth, kDateViewHeight) ];
        APCMedicationTrackerDayTitleLabel  *titleLabel = [[self.dayTitleSubViewContainer subviews] objectAtIndex:i];
        titleLabel.date = dt;

        [view markSelected:([view.date isSameDateWith:self.selectedDate])];
        self.endDate = dt;
    }
}

#pragma DeputyDailyCalendarViewDelegate

- (void)dailyCalendarViewDidSelect:(NSDate *)date
{
    NSLog(@"dailyCalendarViewDidSelect");
    [self markDateSelected:date];
    [self.delegate dailyCalendarViewDidSelect:date];
}

@end
