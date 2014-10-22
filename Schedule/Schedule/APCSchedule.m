//
//  APCSchedule.m
//  Schedule
//
//  Created by Edward Cessna on 9/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSchedule.h"
#import "APCScheduleParser.h"
#import "APCTimeSelectorEnumerator.h"
#import "APCScheduleEnumerator.h"


@interface APCSchedule ()

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


@implementation APCSchedule

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

- (BOOL)isActiveForPeriod:(APCTimePeriod*)period
{
    return NO;
}

//  Update to use enumerators
- (NSDate*)nextMomentAfter:(NSDate*)moment
{
    NSCalendar*         gregorian        = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit      units            = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents*   momentComponents = [gregorian components:units fromDate:moment];
    
    NSInteger   year   = momentComponents.year;
    NSInteger   month  = momentComponents.month;
    NSInteger   day    = momentComponents.day;
    NSInteger   hour   = momentComponents.hour;
    NSInteger   minute = momentComponents.minute;

    NSArray*        selectors = @[self.monthSelector, self.dayOfMonthSelector, self.hourSelector, self.minuteSelector];
    NSMutableArray* targets   = [@[@(month), @(day), @(hour), @(minute)] mutableCopy];
    NSInteger   	ndx       = 0;
    BOOL            advance   = NO;

    void(^ResetLowerSelectors)(NSInteger) = ^(NSInteger selectorIndex)
    {
        for (NSInteger ndx = selectorIndex; ndx < selectors.count; ++ndx)
        {
            targets[ndx] = [selectors[ndx] firstValidValue];
        }
    };

    while (ndx < selectors.count)
    {
        if ([selectors[ndx] matches:targets[ndx]] == YES && advance == NO)
        {
            NSLog(@"Match at index: %ld for value: %@", ndx, targets[ndx]);
            
            ++ndx;
        }
        else
        {
            NSLog(@"No match at index: %ld for value: %@", ndx, targets[ndx]);
            NSNumber*   next = [(APCTimeSelector*)selectors[ndx] nextMomentAfter:targets[ndx]];
            NSLog(@"Looking for next moment after: %@", targets[ndx]);
            
            advance = NO;
            
            if (next == nil)    //  Is backtracking needed?
            {
                if (ndx == 0)   //  Is backtracking possible?
                {
                    NSLog(@"Can't backtrack");
                    break;      //  Not possible to backtrack
                }
                else
                {
                    NSLog(@"Backtracking from %ld to %ld", ndx, ndx - 1);
                    //  Setup backtracking
//                    targets[ndx] = [selectors[ndx] firstValidValue];
                    ResetLowerSelectors(ndx);
                    advance      = YES;
                    
                    //  Backtrack
                    --ndx;
                }
            }
            else
            {
                NSLog(@"Next Moment at index: %ld, value: %@", ndx, next);
                //  Found a _next moment_ for the current selector; save the value and move to the next selector.
                targets[ndx] = next;
                ++ndx;
            }
        }
    }

    NSDateComponents*   nextMomentComponents = [[NSDateComponents alloc] init];
    NSInteger           dateComponentIndex   = 0;
    
    nextMomentComponents.calendar = gregorian;
    nextMomentComponents.year     = year;
    nextMomentComponents.month    = [targets[dateComponentIndex++] integerValue];
    nextMomentComponents.day      = [targets[dateComponentIndex++] integerValue];
    nextMomentComponents.hour     = [targets[dateComponentIndex++] integerValue];
    nextMomentComponents.minute   = [targets[dateComponentIndex++] integerValue];
    
    NSDate* nextMomentDate = [nextMomentComponents date];
    
    return nextMomentDate;
}

//- (NSDate*)nextMomentAfter:(NSDate *)moment
//{
//    NSCalendar*         gregorian        = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSCalendarUnit      units            = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
//    NSDateComponents*   momentComponents = [gregorian components:units fromDate:moment];
//    
//    NSInteger   year   = momentComponents.year;
//    NSInteger   month  = momentComponents.month;
//    NSInteger   day    = momentComponents.day;
//    NSInteger   hour   = momentComponents.hour;
//    NSInteger   minute = momentComponents.minute;
//    
//    NSArray*        selectors = @[self.monthSelector, self.dayOfMonthSelector, self.hourSelector, self.minuteSelector];
//    NSMutableArray* targets   = [@[@(month), @(day), @(hour), @(minute)] mutableCopy];
//    NSInteger   	ndx       = 0;
//
//    NSEnumerator*   monthEnumerator = [self.monthSelector enumeratorBeginningAt:@(month)];
//
//    for (id nextMoment = [monthEnumerator nextObject]; nextMoment != nil; nextMoment = [monthEnumerator nextObject])
//    {
//        
//    }
//    
//    return nil;
//}

@end
