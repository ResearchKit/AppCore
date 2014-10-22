//
//  APCPointSelector.m
//  Schedule
//
//  Created by Edward Cessna on 9/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCPointSelector.h"
#import "APCTimeSelectorEnumerator.h"

@interface APCPointSelector ()

@property (nonatomic, assign) NSNumber* defaultBegin;
@property (nonatomic, assign) NSNumber* defaultEnd;

@end

@implementation APCPointSelector

- (instancetype)initWithUnit:(UnitType)unitType
{
    self = [super init];
    if (self)
    {
        [self setUnit:unitType];
        _unitType = unitType;
    }
    
    return self;
}

- (instancetype)initWithUnit:(UnitType)unitType
                  beginRange:(NSNumber*)begin
                    endRange:(NSNumber*)end
                        step:(NSNumber*)step
{
    //  TODO: Considering initializing step to 1 if end is provided but not step.
    //      If done, step will only by nil if not provided and end not specified.
    self = [self initWithUnit:unitType];
    
    if (begin == nil && end == nil && step == nil)  //  Wildcard?
    {
        step = @1;
    }

    _begin = begin == nil ? _defaultBegin : begin;
    if ((end == nil && begin == nil) || (end == nil && step != nil))
    {
        _end = _defaultEnd;
    }
    else
    {
        _end = end;
    }
    
    if (step == nil && end != nil)
    {
        _step = @1;
    }
    else
    {
        _step  = step;
    }
    
    if (_begin.integerValue < _defaultBegin.integerValue || _end.integerValue > _defaultEnd.integerValue)
    {
        //  TODO: Invalid values
        self = nil;
    }
    
    return self;
}

- (void)setUnit:(UnitType)type
{
    if (type == kMinutes)
    {
        self.defaultBegin  = @0;
        self.defaultEnd    = @59;
    }
    else if (type == kHours)
    {
        self.defaultBegin = @0;
        self.defaultEnd   = @23;
    }
    else if (type == kDayOfMonth)
    {
        self.defaultBegin = @1;
        self.defaultEnd   = @31;
    }
    else if (type == kMonth)
    {
        //  1: Jan, 2: Feb, ..., 12: Dec
        self.defaultBegin = @1;
        self.defaultEnd   = @12;
    }
    else if (type == kDayOfWeek)
    {
        //  0: Sun, 1: Mon, ..., 6: Sat
        self.defaultBegin = @0;
        self.defaultEnd   = @6;
    }
    else if (type == kYear)
    {
        NSDate*             now        = [NSDate date];
        NSCalendar*         calendar   = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents*   components = [calendar components:NSCalendarUnitYear fromDate:now];
        
        self.defaultBegin = @(components.year);
        self.defaultEnd   = @9999;
    }
}

- (NSNumber*)defaultBeginPeriod
{
    return self.defaultBegin;
}

- (NSNumber*)defaultEndPeriod
{
    return self.defaultEnd;
}

- (APCTimeSelectorEnumerator*)enumeratorBeginningAt:(NSNumber*)value
{
    APCTimeSelectorEnumerator*   enumerator = [[APCTimeSelectorEnumerator alloc] initWithSelector:self beginningAtMoment:value];
    
    return enumerator;
}

- (NSNumber*)firstValidValue
{
    return self.begin;
}

- (BOOL)matches:(NSNumber*)value
{
    BOOL    isMatch = NO;
    
    //  * An expression with only a _begin_ value represents a single point in time.
    //  * An expression with a _begin_ and an _end_ value represents an interval of time.
    //  * An expression with a _begin_ and a _step_ value represents a discontiguous interval of time,
    //    where the distance between each point is _step_. The end point for this interval is implied
    //    and is the default end for the Unit Type.
    //  * An expression with a _begin_, _end_, and a _step_ value represents a discontiguous interval
    //    of time, where the distance between each point is _step_. The end point for this interval
    //    is explicit: _end_.
    

    if (self.begin != nil)
    {
        if (self.end != nil)
        {
            if (self.step != nil)
            {
                isMatch = self.begin.integerValue <= value.integerValue &&
                          value.integerValue <= self.end.integerValue   &&
                          value.integerValue % self.step.integerValue == 0;
            }
            else
            {
                isMatch = self.begin.integerValue <= value.integerValue && value.integerValue <= self.end.integerValue;
            }
        }
        else
        {
            if (self.step != nil)
            {
                isMatch = self.begin.integerValue <= value.integerValue && value.integerValue % self.step.integerValue == 0;
            }
            else
            {
                isMatch = self.begin.integerValue == value.integerValue;
            }
        }
    }
    else
    {
        //  TODO: handle exception
    }
    
    return isMatch;
}

- (NSNumber*)nextMomentAfter:(NSNumber*)point
{
    //  if currentValue + step <= end then nextValue = currentValue + step
    //  if currentValue + step > end then nextValue = beginValue
    NSNumber*   nextPoint = nil;
    
    if (self.step != nil)
    {
        nextPoint = @(point.integerValue -  (point.integerValue % self.step.integerValue) + self.step.integerValue);
        
        if (nextPoint.integerValue < self.begin.integerValue)
        {
            nextPoint = self.begin;
        }
        else if (nextPoint.integerValue > self.end.integerValue) 
        {
            nextPoint = nil;
        }
    }
    else
    {
        if (point.integerValue < self.begin.integerValue)
        {
            nextPoint = self.begin;
        }
    }
    
    return nextPoint;
}

@end
