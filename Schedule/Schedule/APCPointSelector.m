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
    self = [self initWithUnit:unitType];
    
    //  Point selector iff begin != nil && (end == nil && step == nil)
    //  Range selector iff begin != nil && (end != nil || step != nil)
    //  Wildcard selector iff begin == nil && end == nil && step == nil
    
    if (begin == nil && end == nil && step == nil)          // Wildcard w/o step?
    {
        _begin = _defaultBegin;
        _end   = _defaultEnd;
        _step  = @1;
    }
    else if (begin == nil && end == nil && step != nil)     //  Wildcard with step?
    {
        _begin = _defaultBegin;
        _end   = _defaultEnd;
        _step  = step;
    }
    else if (begin != nil && end == nil && step == nil)     //  Point selector?
    {
        _begin = begin;
        _end   = nil;
        _step  = nil;
    }
    else if (begin != nil && (end != nil || step != nil))   //  Range selector?
    {
        _begin = begin;
        _end   = end   == nil ? _defaultEnd   : end;
        _step  = step  == nil ? @1            : step;
    }
    else
    {
        NSLog(@"Invalid selector");
        self = nil;
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

- (NSNumber*)initialValue
{
    return self.begin;
}

- (BOOL)matches:(NSNumber*)value
{
    NSParameterAssert(self.begin != nil);
    
    BOOL    isMatch = NO;
    
    //  * An expression with only a _begin_ value represents a single point in time.
    //  * An expression with a _begin_ and an _end_ value represents an interval of time.
    //  * An expression with a _begin_ and a _step_ value represents a discontiguous interval of time,
    //    where the distance between each point is _step_. The end point for this interval is implied
    //    and is the default end for the Unit Type.
    //  * An expression with a _begin_, _end_, and a _step_ value represents a discontiguous interval
    //    of time, where the distance between each point is _step_. The end point for this interval
    //    is explicit: _end_.
    

    if (self.end != nil)
    {
        BOOL    withinRange = self.begin.integerValue <= value.integerValue && value.integerValue <= self.end.integerValue;
        
        if (self.step != nil)
        {
            isMatch = withinRange && value.integerValue % self.step.integerValue == 0;
        }
        else
        {
            isMatch = withinRange;
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
    
    return isMatch;
}

- (NSNumber*)nextMomentAfter:(NSNumber*)point
{
    //  If currentValue + step <  begin then nextValue = begin
    //  if currentValue + step <= end   then nextValue = currentValue + step
    //  if currentValue + step >  end   then nextValue = nil
    
    NSNumber*   nextPoint = nil;
    
    if (self.step != nil)
    {
        nextPoint = @(point.integerValue - (point.integerValue % self.step.integerValue) + self.step.integerValue);
        
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
