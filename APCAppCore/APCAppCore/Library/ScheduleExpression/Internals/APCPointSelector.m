// 
//  APCPointSelector.m 
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
 
#import "APCPointSelector.h"
#import "APCTimeSelectorEnumerator.h"

@interface APCPointSelector ()

@property (nonatomic, strong) NSNumber* defaultBegin;
@property (nonatomic, strong) NSNumber* defaultEnd;
@property (nonatomic, assign) BOOL isWildcard_private;

@end

@implementation APCPointSelector

- (instancetype) init
{
	self = [super init];

	if (self)
	{
		_unitType = kUnknown;
		_begin = nil;
		_end = nil;
		_step = nil;
		_position = nil;
		_defaultBegin = nil;
		_defaultEnd = nil;
		_isWildcard_private = NO;
	}

	return self;
}

/**
 Used for days-of-the-week when specifying, say, the 3rd
 Friday in a month.
 */
- (instancetype) initWithValue: (NSNumber *) value
					  position: (NSNumber *) position
{
	self = [self init];

	if (self)
	{
		_begin = value;
		_end = nil;
		_position = position;

		/*
		 Note:  Previously, we had a sanity check here:  if
		 begin was < defaultBegin, or end was > defaultEnd,
		 assume something went wrong.  Now, though, the
		 defaults won't get set until we set this object's
		 type, and because of how the parser logic works,
		 this happens later.  So we'll do that sanity check
		 when we set the type.
		 */
	}

	return self;
}

- (instancetype) initWithRangeStart: (NSNumber *) begin
						   rangeEnd: (NSNumber *) end
							   step: (NSNumber *) step
{
    self = [self init];

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

		/*
		 Note:  Previously, we had a sanity check here:  if 
		 begin was < defaultBegin, or end was > defaultEnd,
		 assume something went wrong.  Now, though, the
		 defaults won't get set until we set this object's
		 type, and because of how the parser logic works,
		 this happens later.  So we'll do that sanity check
		 when we set the type.
		 */
	}

    return self;
}

- (void) setUnitType: (UnitType) unitType
{
	_unitType = unitType;

	self.defaultBegin = nil;
	self.defaultEnd = nil;

	switch (unitType)
	{
		case kMinutes:
			self.defaultBegin = @0;
			self.defaultEnd   = @59;
			break;

		case kHours:
			self.defaultBegin = @0;
			self.defaultEnd   = @23;
			break;

		case kDayOfMonth:
			self.defaultBegin = @1;
			self.defaultEnd   = @31;
			break;

		case kMonth:
			//  1: Jan, 2: Feb, ..., 12: Dec
			self.defaultBegin = @1;
			self.defaultEnd   = @12;
			break;

		case kDayOfWeek:
			//  0: Sun, 1: Mon, ..., 6: Sat
			self.defaultBegin = @0;
			self.defaultEnd   = @6;
			break;

		case kYear:
		{
			NSDate* now = [NSDate date];
			NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
			NSDateComponents* components = [calendar components:NSCalendarUnitYear fromDate:now];

			self.defaultBegin = @(components.year);
			self.defaultEnd   = @9999;
		}

		default:
			// Time ranges we don't care about.  Using "nil"
			// for defaultBegin and defaultEnd should be fine.
			break;
	}

	// And now apply those default ranges to our actual ranges.
	// If the actual ranges are already set, make sure they're
	// reasonable.
	if (self.begin == nil)
	{
		self.begin = self.defaultBegin;
	}
	else if (self.begin.integerValue < self.defaultBegin.integerValue)
	{
		NSAssert (NO, @"PointSelector: beginValue of %@ is less than default value of %@.", self.begin, self.defaultBegin);
	}

	if (self.end == nil)
	{
        // Based on the unit tests, if this is not a wildcard or has a step defined, end should be nil.
        if (self.isWildcard || self.step)
        {
            self.end = self.defaultEnd;
        }
	}
	else if (self.end.integerValue > self.end.integerValue)
	{
		NSAssert (NO, @"PointSelector: endValue of %@ is greater than default value of %@.", self.end, self.defaultEnd);
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
		{
			nextPoint = nil;
		}
		else
		{
			nextPoint = @(nextPointInt);
		}
	}

    return nextPoint;
}

- (BOOL) isWildcard
{
	return self.isWildcard_private;
}

- (NSString *) description
{
	return [NSString stringWithFormat: @"PointSelector { begin: %@, end: %@, step: %@, position: %@, isWildcard: %@ }",
			self.begin,
			self.end,
			self.step,
			self.position,
			self.isWildcard ? @"YES" : @"NO"
			];
}

@end
