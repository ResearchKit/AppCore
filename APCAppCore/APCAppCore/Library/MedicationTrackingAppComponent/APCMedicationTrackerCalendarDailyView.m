// 
//  APCMedicationTrackerCalendarDailyView.m 
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

@end
