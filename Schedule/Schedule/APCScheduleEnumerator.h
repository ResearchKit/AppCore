//
//  APCScheduleEnumerator.h
//  Schedule
//
//  Created by Edward Cessna on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCListSelector.h"

//  Private implementation.

@interface APCScheduleEnumerator : NSEnumerator

- (instancetype)initWithBeginningTime:(NSDate*)begin
                       minuteSelector:(APCTimeSelector*)minuteSelector
                         hourSelector:(APCTimeSelector*)hourSelector
                   dayOfMonthSelector:(APCTimeSelector*)dayOfMonthSelector
                        monthSelector:(APCTimeSelector*)monthSelector
						 yearSelector:(APCTimeSelector*)yearSelector
			   originalCronExpression:(NSString*)cronExpression;

- (instancetype)initWithBeginningTime:(NSDate*)begin
                           endingTime:(NSDate*)end
                       minuteSelector:(APCTimeSelector*)minuteSelector
                         hourSelector:(APCTimeSelector*)hourSelector
                   dayOfMonthSelector:(APCTimeSelector*)dayOfMonthSelector
                        monthSelector:(APCTimeSelector*)monthSelector
						 yearSelector:(APCTimeSelector*)yearSelector
			   originalCronExpression:(NSString*)cronExpression;

- (void) recomputeDaysAfterRollingOverMonthOrYear;

@end
