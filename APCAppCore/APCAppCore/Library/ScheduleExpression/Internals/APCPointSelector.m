// 
//  APCPointSelector.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCPointSelector.h"
#import "APCTimeSelectorEnumerator.h"

@interface APCPointSelector ()

@property (nonatomic, strong) NSNumber* defaultBegin;
@property (nonatomic, strong) NSNumber* defaultEnd;
@property (nonatomic, assign) BOOL isWildcard_private;

@end

@implementation APCPointSelector

- (instancetype) initWithUnit: (UnitType) unitType
{
    self = [super init];

    if (self)
    {
		_unitType = unitType; 

		_begin = nil;
		_end = nil;
		_step = nil;
		_position = nil;

		_defaultBegin = nil;
		_defaultEnd = nil;
		_isWildcard_private = NO;

		switch (unitType) 
		{
			case kMinutes:
				_defaultBegin = @0;
				_defaultEnd   = @59;
				break;

			case kHours:
				_defaultBegin = @0;
				_defaultEnd   = @23;
				break;

			case kDayOfMonth:
				_defaultBegin = @1;
				_defaultEnd   = @31;
				break;

			case kMonth:
				//  1: Jan, 2: Feb, ..., 12: Dec
				_defaultBegin = @1;
				_defaultEnd   = @12;
				break;

			case kDayOfWeek:
				//  0: Sun, 1: Mon, ..., 6: Sat
				_defaultBegin = @0;
				_defaultEnd   = @6;
				break;

			case kYear:
			{
				NSDate* now = [NSDate date];
				NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
				NSDateComponents* components = [calendar components:NSCalendarUnitYear fromDate:now];

				_defaultBegin = @(components.year);
				_defaultEnd   = @9999;
			}

			default:
				// Time ranges we don't care about.  Using "nil"
				// for defaultBegin and defaultEnd should be fine.
				break;
		}
	}

    return self;
}

/**
 Used for days-of-the-week when specifying, say, the 3rd
 Friday in a month.
 */
- (instancetype)initWithUnit:(UnitType)unitType
					   value:(NSNumber *)value
					position:(NSNumber *)position
{
	self = [self initWithUnit:unitType];

	if (self)
	{
		_begin = value;
		_end = nil;
		_position = position;

		if (_begin.integerValue < _defaultBegin.integerValue)
		{
			//  TODO: Invalid values
			self = nil;
		}
	}

	return self;
}

- (instancetype)initWithUnit:(UnitType)unitType
                  beginRange:(NSNumber*)begin
                    endRange:(NSNumber*)end
                        step:(NSNumber*)step
{
	//
	// Grab the default range of values for the specified type.
	// Note that daysOfMonth ALWAYS uses 31 days, at the moment.
	//
    self = [self initWithUnit:unitType];

	if (self)
	{
		//
		// This init method will generate:
		//
		// - a point selector,    iff begin != nil && (end == nil && step == nil)
		// - a range selector,    iff begin != nil && (end != nil || step != nil)
		// - a wildcard selector, iff begin == nil &&  end == nil && step == nil
		//
		
		if (begin == nil && end == nil && step == nil)          // Wildcard w/o step?
		{
			_begin 				= _defaultBegin;
			_end   				= _defaultEnd;
			_step  				= @1;
			_isWildcard_private = YES;
		}
		else if (begin == nil && end == nil && step != nil)     //  Wildcard with step?
		{
			_begin 				= _defaultBegin;
			_end   				= _defaultEnd;
			_step  				= step;
			_isWildcard_private = YES;
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
		
		if (self != nil && (_begin.integerValue < _defaultBegin.integerValue || _end.integerValue > _defaultEnd.integerValue))
		{
			//  TODO: Invalid values
			self = nil;
		}
	}

    return self;
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
	//		...except for the test cases which start between steps.
    //  if currentValue + step >  end   then nextValue = nil
    
    NSNumber* nextPoint = nil;


	// Get the raw int values.  I find the logic here
	// to be much more readable this way.
	NSInteger beginInt	= self.begin.integerValue;
	NSInteger endInt	= self.end.integerValue;
	NSInteger pointInt	= point.integerValue;
	NSInteger stepInt	= self.step.integerValue;

	if (pointInt < beginInt)
	{
		nextPoint = self.begin;
	}

	else if (self.step == nil || pointInt >= endInt)
	{
		// nextPoint = nil.  Nothing to do.
		//
		// I'm calling this out explicitly, in an else(),
		// to make it easier to think through the logic.
	}

	else   // (beginInt <= pointInt < endInt), and step is non-nil.  Step up.
	{
		// examples with begin = 4, step = 5, point = 17:
		NSInteger offsetFromBegin = pointInt - beginInt;								// 17 - 4 == 13
		NSInteger numStepsFromBegin = (int) (((float) offsetFromBegin) / stepInt);		// 13 / 5 == 2.6 ==> 2
		NSInteger previousSteppedLocation = beginInt + (stepInt * numStepsFromBegin);	// 4 + (5 * 2) = 14
		NSInteger nextPointInt = previousSteppedLocation + stepInt;

		// If the next point isn't on a step, we just went past it.
		if (nextPointInt > endInt)
			nextPoint = nil;
		else
			nextPoint = @(nextPointInt);
	}

    return nextPoint;
}

- (BOOL) isWildcard
{
	return self.isWildcard_private;
}

@end
