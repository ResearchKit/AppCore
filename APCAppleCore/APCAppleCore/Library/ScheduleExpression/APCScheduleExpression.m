//
//  APCSchedule.m
//  Schedule
//
//  Created by Edward Cessna on 9/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCScheduleExpression.h"
#import "APCScheduleParser.h"
#import "APCTimeSelectorEnumerator.h"
#import "APCScheduleEnumerator.h"


@interface APCScheduleExpression ()

@property (nonatomic, strong) APCScheduleParser*    parser;
@property (nonatomic, strong) NSArray*              selectors;

@property (nonatomic, assign) BOOL                  validExpression;
@property (nonatomic, strong) APCTimeSelector*      minuteSelector;
@property (nonatomic, strong) APCTimeSelector*      dayOfMonthSelector;
@property (nonatomic, strong) APCTimeSelector*      hourSelector;
@property (nonatomic, strong) APCTimeSelector*      dayOfWeekSelector;
@property (nonatomic, strong) APCTimeSelector*      monthSelector;
@property (nonatomic, strong) APCTimeSelector*      yearSelector;

@end


@implementation APCScheduleExpression

- (instancetype)initWithExpression:(NSString*)expression timeZero:(NSTimeInterval)timeZero
{
    self = [self init];
    if (self)
    {
        APCScheduleParser* parser = [[APCScheduleParser alloc] initWithExpression:expression];
        
        _validExpression = [parser parse];
        
        if (_validExpression)
        {
            _minuteSelector     = parser.minuteSelector;
            _hourSelector       = parser.hourSelector;
            _dayOfMonthSelector = parser.dayOfMonthSelector;
            _monthSelector      = parser.monthSelector;
            _dayOfWeekSelector  = parser.dayOfWeekSelector;
            _yearSelector       = parser.yearSelector;
        }
    }
    
    return self;
}

- (BOOL)isValid
{
    return self.parser.isValidParse;
}

- (NSEnumerator*)enumeratorBeginningAtTime:(NSDate*)start
{
    return [[APCScheduleEnumerator alloc] initWithBeginningTime:start
                                                 minuteSelector:self.minuteSelector
                                                   hourSelector:self.hourSelector
                                             dayOfMonthSelector:self.dayOfMonthSelector
                                                  monthSelector:self.monthSelector
                                              dayOfWeekSelector:self.dayOfWeekSelector
                                                   yearSelector:self.yearSelector];
}

- (NSEnumerator*)enumeratorBeginningAtTime:(NSDate*)start endingAtTime:(NSDate*)end
{
    return [[APCScheduleEnumerator alloc] initWithBeginningTime:start
                                                     endingTime:end
                                                 minuteSelector:self.minuteSelector
                                                   hourSelector:self.hourSelector
                                             dayOfMonthSelector:self.dayOfMonthSelector
                                                  monthSelector:self.monthSelector
                                              dayOfWeekSelector:self.dayOfWeekSelector
                                                   yearSelector:self.yearSelector];
}

@end
