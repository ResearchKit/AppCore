//
//  DailyCalendarView.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol APCMedicationTrackerCalendarDailyViewDelegate <NSObject>

- (void)dailyCalendarViewDidSelect:(NSDate *)date;

@end

@interface APCMedicationTrackerCalendarDailyView : UIView

@property  (nonatomic, weak)     id  <APCMedicationTrackerCalendarDailyViewDelegate>  delegate;
@property  (nonatomic, strong)   NSDate                        *date;
@property  (nonatomic, assign, getter = isSelected)  BOOL       selected;

- (void)markSelected:(BOOL)selected;

@end
