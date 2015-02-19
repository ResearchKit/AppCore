//
//  APCMedicationTrackerCalendarDailyView.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
#import "APCMedicationTrackerCalendarDailyView.h"
#import "NSDate+MedicationTracker.h"
#import "UIColor+MedicationTracker.h"

@interface APCMedicationTrackerCalendarDailyView  ( )

@property  (nonatomic,  strong)  UILabel  *dateLabel;
@property  (nonatomic,  strong)  UIView   *dateLabelContainer;

@end


#define DATE_LABEL_SIZE 28.0
#define DATE_LABEL_FONT_SIZE 13.0

@implementation APCMedicationTrackerCalendarDailyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self addSubview:self.dateLabelContainer];

        UITapGestureRecognizer  *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dailyViewDidClick:)];
        [self addGestureRecognizer:singleFingerTap];
    }
    return  self;
}

- (UIView *)dateLabelContainer
{
    if (_dateLabelContainer == nil) {
        CGFloat  x = (self.bounds.size.width - DATE_LABEL_SIZE) / 2.0;
        _dateLabelContainer = [[UIView alloc] initWithFrame:CGRectMake(x, 0, DATE_LABEL_SIZE, DATE_LABEL_SIZE)];
        _dateLabelContainer.backgroundColor = [UIColor clearColor];
        _dateLabelContainer.layer.cornerRadius = DATE_LABEL_SIZE / 2.0;
        _dateLabelContainer.clipsToBounds = YES;
        [_dateLabelContainer addSubview:self.dateLabel];
    }
    return  _dateLabelContainer;
}

- (UILabel *)dateLabel
{
    if (_dateLabel == nil) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DATE_LABEL_SIZE, DATE_LABEL_SIZE)];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.font = [UIFont systemFontOfSize:DATE_LABEL_FONT_SIZE];
    }
    return  _dateLabel;
}

- (void)setDate:(NSDate *)date
{
    _date = date;

    [self setNeedsDisplay];
}

- (void)setBlnSelected: (BOOL)blnSelected
{
    _blnSelected = blnSelected;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    self.dateLabel.text = [self.date getDateOfMonth];
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

//- (UIColor *)colorByDate
//{
//    return [self.date isPastDate]?[UIColor colorWithHex:0x7BD1FF]:[UIColor whiteColor];
//}

- (void)dailyViewDidClick: (UIGestureRecognizer *)tap
{
    NSLog(@"dailyViewDidClick");
    [self.delegate dailyCalendarViewDidSelect: self.date];
}

@end
