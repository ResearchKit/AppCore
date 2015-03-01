//
//  APCMedicationTrackerCalendarDailyView.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
#import "APCMedicationTrackerCalendarDailyView.h"
#import "NSDate+MedicationTracker.h"
#import "UIColor+MedicationTracker.h"

static  CGFloat  kDateLabelWidth     = 28.0;
static  CGFloat  kDateLabelPointSize = 13.0;

@interface APCMedicationTrackerCalendarDailyView  ( )

@property  (nonatomic,  strong)  UILabel  *dateLabel;
@property  (nonatomic,  strong)  UIView   *dateLabelContainer;

@end

@implementation APCMedicationTrackerCalendarDailyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self setupDateLabelContainerAndDateLabel];

        UITapGestureRecognizer  *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dailyViewDidClick:)];
        [self addGestureRecognizer:singleFingerTap];
    }
    return  self;
}

- (void)setupDateLabelContainerAndDateLabel
{
    UILabel  *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kDateLabelWidth, kDateLabelWidth)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:kDateLabelPointSize];
    self.dateLabel = label;
    
    CGFloat  x = (self.bounds.size.width - kDateLabelWidth) / 2.0;
    UIView  *container = [[UIView alloc] initWithFrame:CGRectMake(x, 0, kDateLabelWidth, kDateLabelWidth)];
    container.backgroundColor = [UIColor clearColor];
    container.layer.cornerRadius = kDateLabelWidth / 2.0;
    container.clipsToBounds = YES;
    self.dateLabelContainer = container;
    [self addSubview:self.dateLabelContainer];
    
    [self.dateLabelContainer addSubview:self.dateLabel];
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    self.dateLabel.text = [_date getDateOfMonth];
    [self setNeedsDisplay];
}

- (void)setBlnSelected: (BOOL)blnSelected
{
    _blnSelected = blnSelected;
    [self setNeedsDisplay];
}

- (void)markSelected:(BOOL)blnSelected
{
    if (([self.date isDateToday]) && (blnSelected == YES)) {
        self.dateLabel.textColor       = [UIColor todaysDateTextColor];
        self.dateLabelContainer.backgroundColor = [UIColor todaysDateBackgroundColor];
    } else if (blnSelected == YES) {
        self.dateLabel.textColor       = [UIColor selectedDateTextColor];
        self.dateLabelContainer.backgroundColor = [UIColor selectedDateBackgroundColor];
    } else {
        self.dateLabel.textColor       = [UIColor regularDateTextColor];
        self.dateLabelContainer.backgroundColor = [UIColor regularDateBackgroundColor];
    }
}

- (void)dailyViewDidClick: (UIGestureRecognizer *) __unused tap
{
    [self.delegate dailyCalendarViewDidSelect:self.date];
}

@end
