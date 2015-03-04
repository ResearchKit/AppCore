//
//  APCMedicationTrackerCalendarDailyView.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationTrackerCalendarDailyView.h"
#import "NSDate+MedicationTracker.h"
#import "UIFont+APCAppearance.h"
#import "UIColor+MedicationTracker.h"

static  CGFloat  kDateLabelWidth     = 28.0;
static  CGFloat  kDateLabelPointSize = 13.0;

@interface APCMedicationTrackerCalendarDailyView  ( )

@property  (nonatomic,  strong)  UILabel  *dateLabel;
@property  (nonatomic,  strong)  UIView   *dateLabelBackdrop;

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
    label.font = [UIFont appRegularFontWithSize:kDateLabelPointSize];
    self.dateLabel = label;
    
    CGFloat  x = (self.bounds.size.width - kDateLabelWidth) / 2.0;
    UIView  *container = [[UIView alloc] initWithFrame:CGRectMake(x, 0, kDateLabelWidth, kDateLabelWidth)];
    container.backgroundColor = [UIColor clearColor];
    container.layer.cornerRadius = kDateLabelWidth / 2.0;
    container.clipsToBounds = YES;
    self.dateLabelBackdrop = container;
    [self addSubview:self.dateLabelBackdrop];
    
    [self.dateLabelBackdrop addSubview:self.dateLabel];
}

- (void)setDate:(NSDate *)aDate
{
    _date = aDate;
    self.dateLabel.text = [_date getDateOfMonth];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    [self setNeedsDisplay];
}

- (void)markSelected:(BOOL)selected
{
    if (([self.date isDateToday]) && (selected == YES)) {
        self.dateLabel.textColor       = [UIColor todaysDateTextColor];
        self.dateLabelBackdrop.backgroundColor = [UIColor todaysDateBackgroundColor];
    } else if (selected == YES) {
        self.dateLabel.textColor       = [UIColor selectedDateTextColor];
        self.dateLabelBackdrop.backgroundColor = [UIColor selectedDateBackgroundColor];
    } else {
        self.dateLabel.textColor       = [UIColor regularDateTextColor];
        self.dateLabelBackdrop.backgroundColor = [UIColor regularDateBackgroundColor];
    }
}

- (void)dailyViewDidClick: (UIGestureRecognizer *) __unused tap
{
    [self.delegate dailyCalendarViewDidSelect:self.date];
}

@end
