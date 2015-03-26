// 
//  APCScheduleEnumerator.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <Foundation/Foundation.h>
#import "APCListSelector.h"

//  Private implementation.

@interface APCScheduleEnumerator : NSEnumerator

- (instancetype)initWithBeginningTime: (NSDate *) begin
                       minuteSelector: (APCTimeSelector *) minuteSelector
                         hourSelector: (APCTimeSelector *) hourSelector
                   dayOfMonthSelector: (APCTimeSelector *) dayOfMonthSelector
                        monthSelector: (APCTimeSelector *) monthSelector
                         yearSelector: (APCTimeSelector *) yearSelector
               originalCronExpression: (NSString *) originalExpression;

- (instancetype)initWithBeginningTime:(NSDate *) begin
                           endingTime:(NSDate *) end
                       minuteSelector:(APCTimeSelector *) minuteSelector
                         hourSelector:(APCTimeSelector *) hourSelector
                   dayOfMonthSelector:(APCTimeSelector *) dayOfMonthSelector
                        monthSelector:(APCTimeSelector *) monthSelector
                         yearSelector:(APCTimeSelector *) yearSelector
               originalCronExpression: (NSString *) originalExpression;

@end
