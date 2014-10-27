//
//  APCScheduleEnumerator.m
//  Schedule
//
//  Created by Edward Cessna on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCScheduleEnumerator.h"
#import "APCTimeSelectorEnumerator.h"

static NSInteger    kMinuteIndex = 0;
static NSInteger    kHourIndex   = 1;
static NSInteger    kDayIndex    = 2;
static NSInteger    kMonthIndex  = 3;
static NSInteger    kYearIndex   = 4;


@interface APCScheduleEnumerator ()

@property (nonatomic, strong) NSDate*       beginningMoment;
@property (nonatomic, strong) NSDate*       endingMoment;
@property (nonatomic, strong) NSDate*       nextMoment;


@property (nonatomic, strong) NSCalendar*       calendar;
@property (nonatomic, assign) NSInteger         year;
@property (nonatomic, strong) NSMutableArray*   enumerators;    //  array of APCTimeSelectorEnumerator
@property (nonatomic, strong) NSMutableArray*   componenets;    //  arrray of NSNumbers

@end


@implementation APCScheduleEnumerator

- (instancetype)initWithBeginningTime:(NSDate*)begin
                       minuteSelector:(APCTimeSelector*)minuteSelector
                         hourSelector:(APCTimeSelector*)hourSelector
                   dayOfMonthSelector:(APCTimeSelector*)dayOfMonthSelector
                        monthSelector:(APCTimeSelector*)monthSelector
                    dayOfWeekSelector:(APCTimeSelector*)dayOfWeekSelector
                         yearSelector:(APCTimeSelector*)yearSelector
{
    return [self initWithBeginningTime:begin
                            endingTime:nil
                        minuteSelector:minuteSelector
                          hourSelector:hourSelector
                    dayOfMonthSelector:dayOfMonthSelector
                         monthSelector:monthSelector
                     dayOfWeekSelector:dayOfMonthSelector
                          yearSelector:yearSelector];
}

- (instancetype)initWithBeginningTime:(NSDate*)begin
                           endingTime:(NSDate*)end
                       minuteSelector:(APCTimeSelector*)minuteSelector
                         hourSelector:(APCTimeSelector*)hourSelector
                   dayOfMonthSelector:(APCTimeSelector*)dayOfMonthSelector
                        monthSelector:(APCTimeSelector*)monthSelector
                    dayOfWeekSelector:(APCTimeSelector*)dayOfWeekSelector
                         yearSelector:(APCTimeSelector*)yearSelector
{
    self = [super init];
    if (self)
    {
        NSDateComponents*   beginComponents = nil;
        NSCalendarUnit      calendarUnits   = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
        
        _beginningMoment = begin;
        _endingMoment    = end;
        
        _calendar       = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        beginComponents = [_calendar components:calendarUnits fromDate:begin];
        _year           = beginComponents.year;
        _componenets    = [NSMutableArray arrayWithArray:@[@(beginComponents.minute),
                                                           @(beginComponents.hour),
                                                           @(beginComponents.day),
                                                           @(beginComponents.month),
                                                           @(beginComponents.year)]];
        
        APCTimeSelectorEnumerator*   minuteEnumerator = [minuteSelector     enumeratorBeginningAt:@(beginComponents.minute)];
        APCTimeSelectorEnumerator*   hourEnumerator   = [hourSelector       enumeratorBeginningAt:@(beginComponents.hour)];
        APCTimeSelectorEnumerator*   dayEnumerator    = [dayOfMonthSelector enumeratorBeginningAt:@(beginComponents.day)];
        APCTimeSelectorEnumerator*   monthEnumerator  = [monthSelector      enumeratorBeginningAt:@(beginComponents.month)];
        APCTimeSelectorEnumerator*   yearEnumerator   = [yearSelector       enumeratorBeginningAt:@(beginComponents.year)];
        
        _enumerators = [NSMutableArray arrayWithArray:@[minuteEnumerator, hourEnumerator, dayEnumerator, monthEnumerator, yearEnumerator]];
        

        //  Prime the enumerators to their first valid value. If a given enumerator's first valid value is
        //  greater than the corresponding given `begin` component then all lower granularity components are
        //  reset to the selector's first valid value.
        NSInteger   ndx = _enumerators.count - 1;
        do
        {
            NSNumber*   value = [_enumerators[ndx] nextObject];
            
            if (value == nil)
            {
                //  No valid values for the enumeration sequence
                self = nil;
                break;
            }
            else
            {
                NSComparisonResult  comparison = [value compare:_componenets[ndx]];
                if (comparison == NSOrderedSame)
                {
                    _componenets[ndx] = value;
                    --ndx;
                }
                else if (comparison == NSOrderedDescending)
                {
                    _componenets[ndx] = value;
                    for (--ndx; ndx >= 0; --ndx)
                    {
                        _componenets[ndx] = [_enumerators[ndx] reset];
                    }
                }
                else
                {
                    //  Exception: shouldn't happen.
                    self = nil;
                    break;
                }
            }
        } while (ndx >= 0);
        
        _nextMoment = [self componentsToDate];
    }
    
    return self;
}

- (NSDate*)nextObject
{
    NSDate* savedMoment = self.nextMoment;

    NSNumber*   nextPoint = nil;
    NSInteger   ndx       = 0;
    
    do
    {
        nextPoint = [self.enumerators[ndx] nextObject];
        
        if (nextPoint != nil)
        {
            self.componenets[ndx] = nextPoint;
        }
        else
        {
            //  Rollover the current enumerator and move to the next one.
            //  Enumerators (0 ... ndx - 1) have already been rollover at this point.
            self.componenets[ndx] = [self.enumerators[ndx] nextObjectAfterRollover];
            ++ndx;
        }
    } while (nextPoint == nil && ndx < self.enumerators.count);
    
    self.nextMoment = [self componentsToDate];
    
    //  Have the range been exceeded?
    if ([self.endingMoment compare:self.nextMoment] == NSOrderedAscending)
    {
        self.nextMoment = nil;
    }
    
    return savedMoment;
}

- (NSDate*)componentsToDate
{
    NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
    
    dateComponents.calendar = self.calendar;
    dateComponents.year     = [self.componenets[kYearIndex]   integerValue];
    dateComponents.month    = [self.componenets[kMonthIndex]  integerValue];
    dateComponents.day      = [self.componenets[kDayIndex]    integerValue];
    dateComponents.hour     = [self.componenets[kHourIndex]   integerValue];
    dateComponents.minute   = [self.componenets[kMinuteIndex] integerValue];
    
    return [dateComponents date];
}

@end
