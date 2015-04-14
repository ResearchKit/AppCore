// 
//  APCMedicationTrackerCalendarWeeklyView.m 
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
 
#import "APCMedicationTrackerCalendarWeeklyView.h"
#import "APCMedicationTrackerCalendarDailyView.h"
#import "APCMedicationTrackerDayTitleLabel.h"

#import "NSDate+MedicationTracker.h"
#import "NSDate+Helper.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+MedicationTracker.h"
#import "NSDictionary+MedicationTracker.h"
#import "APCConstants.h"

static  NSUInteger  kNumberOfWeekDivisions =   7;

static  CGFloat  kDayTitleViewHeight       =  20.0;
static  CGFloat  kDateTitleMarginTop       =   4.0;

static  CGFloat  kDateViewHeight           =  28.0;

static  CGFloat  kDateLabelInfoHeight      =  20.0;

static  CGFloat  kNavigationArrowsWidth    =  34.0 * 0.5625;
static  CGFloat  kNavigationArrowsHeight   =  28.0 * 0.5625;
static  CGFloat  kNavigationArrowsHorOffset = 16.0;
static  CGFloat  kNavigationArrowsVerOffset =  4.0;

static  NSString  *kNavigationLeftArrowName  = @"icon_arrowleft";
static  NSString  *kNavigationRightArrowName = @"icon_arrowright";

static  NSInteger const  kCalendarWeekStartDay          =  1;
static  CGFloat   const  kCalendarSelectedDatePointSize = 13.0;

static  CGFloat   const  kDayTitlePointSize             = 12.0;
static  CGFloat   const  kDayTitleGrayScale             = 0.5569;

static  NSString  *kPerformScrollDirectionKey = @"kPerformScrollDirectionKey";
static  NSString  *kSelectedDateKey           = @"SelectedDateKey";
static  NSString  *kSelectedDateIsTodayKey    = @"kSelectedDateIsTodayKey";

static  NSString  *kThinSpaceEnDashJoiner     = @"\u2009\u2013\u2009";

@interface APCMedicationTrackerCalendarWeeklyView  ( ) <UIGestureRecognizerDelegate, APCMedicationTrackerCalendarDailyViewDelegate>

@property  (nonatomic,  strong)  UIView                    *backdrop;
@property  (nonatomic,  strong)  UIView                    *dailyBackdrop;
@property  (nonatomic,  strong)  UIView                    *dayTitleBackdrop;
@property  (nonatomic,  strong)  UIView                    *dailyInfoBackdrop;
@property  (nonatomic,  strong)  UILabel                   *dateInfoLabel;

@property  (nonatomic,  weak)    UIButton                  *leftScrollButton;
@property  (nonatomic,  weak)    UISwipeGestureRecognizer  *leftSwiper;
@property  (nonatomic,  weak)    UIButton                  *rightScrollButton;
@property  (nonatomic,  weak)    UISwipeGestureRecognizer  *rightSwiper;

@property  (nonatomic,  strong)  NSDate                    *startDate;
@property  (nonatomic,  strong)  NSDate                    *endOfWeekDate;

@property  (nonatomic,  strong)  NSNumber                  *weekStartConfig;
@property  (nonatomic,  strong)  UIColor                   *dayTitleTextColor;

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
        self.dayTitleBackdrop = view;
        self.dayTitleBackdrop.backgroundColor = [UIColor clearColor];
        self.dayTitleBackdrop.userInteractionEnabled = YES;
        [self.backdrop addSubview:self.dayTitleBackdrop];
    }
    {
        UIView  *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, kDateTitleMarginTop + kDayTitleViewHeight, self.bounds.size.width, kDateViewHeight)];
        self.dailyBackdrop = view;
        self.dailyBackdrop.backgroundColor = [UIColor clearColor];
        self.dailyBackdrop.userInteractionEnabled = YES;
        [self.backdrop addSubview:self.dailyBackdrop];
    }
    {
        UILabel  *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.backdrop.frame), kDateLabelInfoHeight)];
        self.dateInfoLabel = label;
        self.dateInfoLabel.textAlignment = NSTextAlignmentCenter;
        self.dateInfoLabel.userInteractionEnabled = YES;
        self.dateInfoLabel.font = [UIFont systemFontOfSize: kCalendarSelectedDatePointSize];
        self.dateInfoLabel.textColor = [UIColor blackColor];
        self.dateInfoLabel.backgroundColor = [UIColor clearColor];
    }
    {
        UIView  *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, kDateTitleMarginTop + kDayTitleViewHeight + kDateViewHeight, CGRectGetWidth(self.backdrop.frame), kDateLabelInfoHeight)];
        self.dailyInfoBackdrop = view;
        self.dailyInfoBackdrop.userInteractionEnabled = YES;
        self.dailyInfoBackdrop.backgroundColor = [UIColor clearColor];
        [self.backdrop addSubview:self.dailyInfoBackdrop];
        [self.dailyInfoBackdrop addSubview:self.dateInfoLabel];
        
        CGRect  frame = CGRectMake(kNavigationArrowsHorOffset, kNavigationArrowsVerOffset, kNavigationArrowsWidth, kNavigationArrowsHeight);
        
        UIButton  *leftScrollerButton = [UIButton  buttonWithType:UIButtonTypeCustom];
        leftScrollerButton.frame = frame;
        [leftScrollerButton setBackgroundImage:[UIImage imageNamed:kNavigationLeftArrowName] forState:UIControlStateNormal];
        [leftScrollerButton addTarget:self action:@selector(leftScrollerButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.dailyInfoBackdrop addSubview:leftScrollerButton];
        self.leftScrollButton = leftScrollerButton;
        
        frame = CGRectMake(CGRectGetWidth(self.backdrop.frame) - kNavigationArrowsWidth - kNavigationArrowsHorOffset, kNavigationArrowsVerOffset, kNavigationArrowsWidth, kNavigationArrowsHeight);
        
        UIButton  *rightScrollerButton = [UIButton  buttonWithType:UIButtonTypeCustom];
        rightScrollerButton.frame = frame;
        [rightScrollerButton setBackgroundImage:[UIImage imageNamed:kNavigationRightArrowName] forState:UIControlStateNormal];
        [rightScrollerButton addTarget:self action:@selector(rightScrollerButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.dailyInfoBackdrop addSubview:rightScrollerButton];
        self.rightScrollButton = rightScrollerButton;
    }
    [self initialiseDailyViews];
}

- (void)setupBackdrop
{
    self.backdrop.userInteractionEnabled = YES;
    UISwipeGestureRecognizer  *rightSwipeGesturer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [rightSwipeGesturer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.backdrop addGestureRecognizer:rightSwipeGesturer];
    rightSwipeGesturer.delegate = self;
    self.rightSwiper = rightSwipeGesturer;

    UISwipeGestureRecognizer  *leftSwipeGesturer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [leftSwipeGesturer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.backdrop addGestureRecognizer:leftSwipeGesturer];
    leftSwipeGesturer.delegate = self;
    self.leftSwiper = leftSwipeGesturer;

    self.backdrop.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
}

- (void)initialiseDailyViews
{
    CGFloat dailyWidth = self.bounds.size.width / kNumberOfWeekDivisions;
    NSDate  *today = [NSDate new];
    NSInteger  weekStartOrdinal = [self.firstDayOfWeek integerValue];
    if (weekStartOrdinal == 0) {
        weekStartOrdinal = kCalendarWeekStartDay;
    }
    NSDate  *startOfWeekDate = [today getWeekStartDate:weekStartOrdinal];
    self.startDate = startOfWeekDate;

    for (UIView  *view in [self.dailyBackdrop subviews]) {
        [view removeFromSuperview];
    }
    for (UIView  *view in [self.dayTitleBackdrop subviews]) {
        [view removeFromSuperview];
    }
    for (NSUInteger  day = 0;  day < kNumberOfWeekDivisions;  day++) {
        NSDate  *date = [startOfWeekDate dateByAddingDays:day];

        [self dayTitleViewForDate:date withFrame: CGRectMake(dailyWidth * day, 0, dailyWidth, kDayTitleViewHeight)];

        [self dailyViewForDate:date withFrame: CGRectMake(dailyWidth * day, 0, dailyWidth, kDateViewHeight) ];

        self.endOfWeekDate = date;
    }
    [self dailyCalendarViewDidSelect:[NSDate new]];
}

#pragma  mark  -  Uitility Methods

- (UILabel *)dayTitleViewForDate:(NSDate *)date withFrame:(CGRect)frame
{
    APCMedicationTrackerDayTitleLabel  *dayTitleLabel = [[APCMedicationTrackerDayTitleLabel alloc] initWithFrame:frame];
    dayTitleLabel.backgroundColor = [UIColor clearColor];
    dayTitleLabel.textColor = self.dayTitleTextColor;
    dayTitleLabel.textAlignment = NSTextAlignmentCenter;
    dayTitleLabel.font = [UIFont appRegularFontWithSize:kDayTitlePointSize];
    dayTitleLabel.textColor = [UIColor colorWithRed:kDayTitleGrayScale green:kDayTitleGrayScale blue:kDayTitleGrayScale alpha:1.0];

    dayTitleLabel.text = [[[date getDayOfWeekShortString] uppercaseString] substringToIndex:1];
    dayTitleLabel.date = date;
    dayTitleLabel.userInteractionEnabled = YES;

    [self.dayTitleBackdrop addSubview:dayTitleLabel];
    return  dayTitleLabel;
}

- (APCMedicationTrackerCalendarDailyView *)dailyViewForDate:(NSDate *)date withFrame:(CGRect)frame
{
    APCMedicationTrackerCalendarDailyView  *view = [[APCMedicationTrackerCalendarDailyView alloc] initWithFrame:frame];
    view.date = date;
    view.backgroundColor = [UIColor clearColor];
    view.delegate = self;
    [self.dailyBackdrop addSubview:view];
    return  view;
}

- (NSArray *)fetchDailyCalendarDayViews
{
    NSArray  *subviews = [self.dailyBackdrop subviews];
    return  subviews;
}

- (void)markDateSelected:(NSDate *)date
{
    for (APCMedicationTrackerCalendarDailyView  *view in [self.dailyBackdrop subviews]) {
        [view markSelected:([view.date isSameDateWith:date])];
    }
    NSDateFormatter  *beginFormatter = [[NSDateFormatter alloc] init];
    [beginFormatter setDateFormat:@"MMM d"];
    NSString  *beginFormatted = [beginFormatter stringFromDate:self.startDate];
    
    NSDateFormatter  *endFormatter = [[NSDateFormatter alloc] init];
    [endFormatter setDateFormat:@"MMM d, yyyy"];
    NSString  *endFormatted = [endFormatter stringFromDate:self.endOfWeekDate];
    
    NSString  *finalDate = [NSString stringWithFormat:@"%@%@%@", beginFormatted, kThinSpaceEnDashJoiner, endFormatted];
    self.dateInfoLabel.text = finalDate;
}

- (void)redrawToDate:(NSDate *)date
{
    if ([date isWithinDate:self.startDate toDate:self.endOfWeekDate] == NO) {
        BOOL  swipeRight = ([date compare:self.startDate] == NSOrderedAscending);
        if (swipeRight == YES) {
            [self performSwipeAnimation:WeeklyCalendarScrollDirectionRight dateIsToday:[date isDateToday] selectedDate:date];
        } else {
            [self performSwipeAnimation:WeeklyCalendarScrollDirectionLeft dateIsToday:[date isDateToday] selectedDate:date];
        }
    }
    [self dailyCalendarViewDidSelect:date];
}

- (void)redrawCalendarData
{
    [self redrawToDate:self.selectedDate];
}

#pragma  mark  -  Swipe Gesture Recognisers

- (void)enableScrolling:(BOOL)enable
{
    if (enable == YES) {
        self.leftScrollButton.enabled  = YES;
        self.leftSwiper.enabled        = YES;
        self.rightScrollButton.enabled = YES;
        self.rightSwiper.enabled       = YES;
    } else {
        self.leftScrollButton.enabled  = NO;
        self.leftSwiper.enabled        = NO;
        self.rightScrollButton.enabled = NO;
        self.rightSwiper.enabled       = NO;
    }
}

- (void)swipeLeft:(UISwipeGestureRecognizer *) __unused swiper
{
    
    [self performSwipeAnimation:WeeklyCalendarScrollDirectionRight dateIsToday:NO selectedDate:nil];
}

- (void)swipeRight:(UISwipeGestureRecognizer *) __unused swiper
{
    [self performSwipeAnimation:WeeklyCalendarScrollDirectionLeft dateIsToday:NO selectedDate:nil];
}

#pragma  mark  -  Arrow Button Action Methods

- (void)leftScrollerButtonWasTapped:(UIButton *) __unused sender
{
    [self performSwipeAnimation:WeeklyCalendarScrollDirectionLeft dateIsToday:NO selectedDate:nil];
}

- (void)rightScrollerButtonWasTapped:(UIButton *) __unused sender
{
    [self performSwipeAnimation:WeeklyCalendarScrollDirectionRight dateIsToday:NO selectedDate:nil];
}

- (void)performSwipeAnimation:(WeeklyCalendarScrollDirection)scrollDirection dateIsToday:(BOOL)dateIsToday selectedDate:(NSDate *)selectedDate
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
    [self.dailyBackdrop.layer addAnimation:animation forKey:kCATransition];

    NSMutableDictionary  *data = @{
                                kPerformScrollDirectionKey : [NSNumber numberWithUnsignedInteger:scrollDirection],
                                kSelectedDateIsTodayKey    : [NSNumber numberWithBool:dateIsToday]
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

    BOOL  dateIsToday = [param[kSelectedDateIsTodayKey] boolValue];
    NSDate  *selectedDate = [param objectForKeyWithNil:kSelectedDateKey];
    CGFloat  dailyWidth = self.bounds.size.width / kNumberOfWeekDivisions;

    NSDate  *dtStart = nil;
    if (dateIsToday == YES) {
        dtStart = [[NSDate new] getWeekStartDate:self.weekStartConfig.integerValue];
    } else {
        dtStart = (selectedDate) ? [selectedDate getWeekStartDate:self.weekStartConfig.integerValue]:[self.startDate dateByAddingDays:step * 7];
    }
    self.startDate = dtStart;
    for (UIView  *view in [self.dailyBackdrop subviews]) {
        [view removeFromSuperview];
    }

    for (NSUInteger  days = 0;  days < kNumberOfWeekDivisions;  days++) {
        NSDate  *aDate = [dtStart dateByAddingDays:days];

        APCMedicationTrackerCalendarDailyView  *view = [self dailyViewForDate:aDate withFrame: CGRectMake(dailyWidth * days, 0, dailyWidth, kDateViewHeight) ];
        APCMedicationTrackerDayTitleLabel  *titleLabel = [[self.dayTitleBackdrop subviews] objectAtIndex:days];
        titleLabel.date = aDate;

        [view markSelected:([view.date isSameDateWith:self.selectedDate])];
        self.endOfWeekDate = aDate;
    }
    [self markDateSelected:[NSDate date]];
}

#pragma  mark  -  DeputyDailyCalendarViewDelegate

- (void)dailyCalendarViewDidSelect:(NSDate *)date
{
    [self markDateSelected:date];
    [self.delegate dailyCalendarViewDidSelect:date];
}

@end
