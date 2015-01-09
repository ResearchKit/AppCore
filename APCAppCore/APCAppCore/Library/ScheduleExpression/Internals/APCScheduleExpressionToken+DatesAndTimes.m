//
//  APCScheduleExpressionToken+DatesAndTimes.m
//  APCAppCore
//
//  Created by Ron Conescu on 1/9/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCScheduleExpressionToken+DatesAndTimes.h"


static NSArray* kMonthNames = nil;
static NSArray* kWeekdayNames = nil;


@implementation APCScheduleExpressionToken (DatesAndTimes)



// ---------------------------------------------------------
#pragma mark - Init our static arrays of names
// ---------------------------------------------------------

+ (void) initialize
{
	// These will be interpreted as having indices 1 through 12.
	kMonthNames = @[@"jan", @"feb", @"mar", @"apr", @"may", @"jun",
					@"jul", @"aug", @"sep", @"oct", @"nov", @"dec"];

	// Order matters: "Sunday" is either 0 or 7 in cron-speak,
	// and we normalize all Sundays to 0.
	kWeekdayNames = @[@"sun", @"mon", @"tue", @"wed", @"thu", @"fri", @"sat"];
}


// ---------------------------------------------------------
#pragma mark - The Boolean properties
// ---------------------------------------------------------

- (BOOL) canInterpretAsSeconds	{ return self.interpretAsSeconds	!= kAPCScheduleExpressionTokenIntegerValueNotSet; }
- (BOOL) canInterpretAsMinutes	{ return self.interpretAsMinutes	!= kAPCScheduleExpressionTokenIntegerValueNotSet; }
- (BOOL) canInterpretAsHours	{ return self.interpretAsHours		!= kAPCScheduleExpressionTokenIntegerValueNotSet; }
- (BOOL) canInterpretAsDay		{ return self.interpretAsDay		!= kAPCScheduleExpressionTokenIntegerValueNotSet; }
- (BOOL) canInterpretAsMonth	{ return self.interpretAsMonth		!= kAPCScheduleExpressionTokenIntegerValueNotSet; }
- (BOOL) canInterpretAsWeekday	{ return self.interpretAsWeekday	!= kAPCScheduleExpressionTokenIntegerValueNotSet; }



// ---------------------------------------------------------
#pragma mark - Extract trivial numbers
// ---------------------------------------------------------

- (NSInteger) interpretAsSeconds	{ return [self valueIfGreaterOrEqualTo: 0 andLessThanOrEqualTo: 59]; }
- (NSInteger) interpretAsMinutes	{ return [self valueIfGreaterOrEqualTo: 0 andLessThanOrEqualTo: 59]; }
- (NSInteger) interpretAsHours		{ return [self valueIfGreaterOrEqualTo: 0 andLessThanOrEqualTo: 23]; }
- (NSInteger) interpretAsDay		{ return [self valueIfGreaterOrEqualTo: 1 andLessThanOrEqualTo: 31]; }



// ---------------------------------------------------------
#pragma mark - Extract numbers that might start as words, or which need more logic
// ---------------------------------------------------------

- (NSInteger) interpretAsMonth
{
	NSInteger result = kAPCScheduleExpressionTokenIntegerValueNotSet;

	if (self.isNumber)
	{
		result = [self valueIfGreaterOrEqualTo: 1 andLessThanOrEqualTo: 12];
	}

	else if (self.isWord && [kMonthNames containsObject: self.stringValue.lowercaseString])
	{
		// Month indices are 1..12.
		result = [kMonthNames indexOfObject: self.stringValue.lowercaseString] + 1;
	}

	return result;
}

- (NSInteger) interpretAsWeekday
{
	NSInteger result = kAPCScheduleExpressionTokenIntegerValueNotSet;

	if (self.isNumber)
	{
		result = [self valueIfGreaterOrEqualTo: 0 andLessThanOrEqualTo: 7];

		/*
		 In cron-speak, "Sunday" can be both 0 and 7.  We normalize to 0.
		 */
		if (result == 7)
		{
			result = 0;
		}
	}

	else if (self.isWord && [kWeekdayNames containsObject: self.stringValue.lowercaseString])
	{
		// Weekday indices are 0..6.
		result = [kWeekdayNames indexOfObject: self.stringValue.lowercaseString];
	}

	return result;
}



// ---------------------------------------------------------
#pragma mark - Utility method for extracting numbers
// ---------------------------------------------------------

- (NSInteger) valueIfGreaterOrEqualTo: (NSInteger) minValue
				 andLessThanOrEqualTo: (NSInteger) maxValue
{
	NSInteger result = kAPCScheduleExpressionTokenIntegerValueNotSet;

	if (self.isNumber)
	{
		result = self.integerValue;

		if (result < minValue || result > maxValue)
		{
			result = kAPCScheduleExpressionTokenIntegerValueNotSet;
		}
	}

	return result;
}

@end
