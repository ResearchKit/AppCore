// 
//  NSDateComponents+Helper.m 
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
 
#import "NSDateComponents+Helper.h"


static NSCalendar *_gregorianCalendar = nil;
static NSTimeZone *_utcTimeZone = nil;
static NSTimeZone *_localTimeZone = nil;


@implementation NSDateComponents (Helper)

+ (NSCalendar *) gregorianCalendar
{
    /*
     Please leave the debugging statements in this method.
     */
    // NSLog (@"+gregorianCalendar: accessed. isMainThread = %@", @([NSThread isMainThread]));

	if (_gregorianCalendar == nil)
	{
        // NSLog (@"+gregorianCalendar: creating (!). isMainThread = %@", @([NSThread isMainThread]));

		_gregorianCalendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
	}

	return _gregorianCalendar;
}

+ (NSTimeZone *) utcTimeZone
{
	if (_utcTimeZone == nil)
	{
		_utcTimeZone = [NSTimeZone timeZoneWithAbbreviation: @"UTC"];
	}

	return _utcTimeZone;
}

+ (NSTimeZone *) localTimeZone
{
	if (_localTimeZone == nil)
	{
		_localTimeZone = [NSTimeZone localTimeZone];
	}

	return _localTimeZone;
}




+ (instancetype) componentsInGregorianWithTimeZone: (NSTimeZone *) timeZone
{
	NSDateComponents *components = [self new];

	components.timeZone = timeZone;
	components.calendar = [self gregorianCalendar];

	return components;
}

+ (instancetype) componentsInGregorianUTC
{
	return [self componentsInGregorianWithTimeZone: self.utcTimeZone];
}

+ (instancetype) componentsInGregorianLocal
{
	return [self componentsInGregorianWithTimeZone: self.localTimeZone];
}



+ (instancetype) componentsInGregorianWithTimeZone: (NSTimeZone *) timeZone
											 month: (NSNumber *) month
											  year: (NSNumber *) year
{
	NSDateComponents *components = [self new];

	components.timeZone = timeZone;
	components.calendar = [self gregorianCalendar];
	components.year		= year.integerValue;
	components.month	= month.integerValue;

	return components;
}

+ (instancetype) componentsInGregorianUTCWithMonth: (NSNumber *) month
											  year: (NSNumber *) year
{
	return [self componentsInGregorianWithTimeZone: self.utcTimeZone
											 month: month
											  year: year];
}

+ (instancetype) componentsInGregorianLocalWithMonth: (NSNumber *) month
												year: (NSNumber *) year
{
	return [self componentsInGregorianWithTimeZone: self.localTimeZone
											 month: month
											  year: year];
}



+ (instancetype) components: (NSArray *) arrayOfNSCalendarUnits
	inGregorianWithTimeZone: (NSTimeZone *) timeZone
				   fromDate: (NSDate *) date
{
	NSCalendar *calendar = [self gregorianCalendar];

	NSDateComponents *allComponents = [calendar componentsInTimeZone: timeZone fromDate: date];

	NSDateComponents *desiredComponents = [NSDateComponents new];

	desiredComponents.calendar = calendar;
	desiredComponents.timeZone = timeZone;

	for (NSNumber *calendarUnitObj in arrayOfNSCalendarUnits)
	{
		NSCalendarUnit calendarUnit = calendarUnitObj.integerValue;

		/*
		 One:  these can't be extracted (we get a runtime warning).
		 Two:  We're going to set them anyway.  (...or maybe not.  In progress.)
		 */
		if (calendarUnit != NSCalendarUnitCalendar &&
			calendarUnit != NSCalendarUnitTimeZone)
		{
			NSInteger componentValue = [allComponents valueForComponent: calendarUnit];

			[desiredComponents setValue: componentValue
						   forComponent: calendarUnit];
		}
	}

	return desiredComponents;
}

+ (instancetype) components: (NSArray *) arrayOfNSCalendarUnits
	 inGregorianUTCFromDate: (NSDate *) date
{
	return [self components: arrayOfNSCalendarUnits
	inGregorianWithTimeZone: self.utcTimeZone
				   fromDate: date];
}

+ (instancetype) components: (NSArray *) arrayOfNSCalendarUnits inGregorianLocalFromDate: (NSDate *) date
{
	return [self components: arrayOfNSCalendarUnits
	inGregorianWithTimeZone: self.localTimeZone
				   fromDate: date];
}


/**
 Again -- we're modifying this DateComponents object, by design.
 This is a shortcut for allocating an NSDateComponents object
 and then setting all its fields.
 */
- (NSInteger) cronDayOfWeekForDay: (NSInteger) dayInCurrentMonthYearAndCalendar
{
	self.day = dayInCurrentMonthYearAndCalendar;
	
	NSDate *myDate = self.date;
	NSInteger oneBasedDayOfWeek = [self.calendar component: NSCalendarUnitWeekday fromDate: myDate];
	NSInteger zeroBasedDayOfWeek = oneBasedDayOfWeek - 1;

	// Convert 1..7 to 0..6 .
	if (zeroBasedDayOfWeek < 0)
	{
		zeroBasedDayOfWeek += 7;
	}

	// And just to clarify:
	NSInteger cronDayOfWeek = zeroBasedDayOfWeek;

	return cronDayOfWeek;
}

- (NSNumber *) cronDayOfWeekAsNSNumberForDay: (NSNumber *) dayInCurrentMonthYearAndCalendar
{
	NSInteger cronDayOfWeek = [self cronDayOfWeekForDay: dayInCurrentMonthYearAndCalendar.integerValue];

	return @(cronDayOfWeek);
}

- (NSInteger) lastDayOfMonth
{
	NSRange dayRangeInMonth = [self.calendar rangeOfUnit: NSCalendarUnitDay
												  inUnit: NSCalendarUnitMonth
												 forDate: self.date];

	NSInteger lastDayOfMonth = dayRangeInMonth.location + dayRangeInMonth.length - 1;

	return lastDayOfMonth;
}

- (NSArray *) allDaysInMonth
{
	NSMutableArray *computedDays = [NSMutableArray new];

	if (self.calendar == nil)
	{
		self.calendar = [NSCalendar currentCalendar];
	}

	if (self.year == NSDateComponentUndefined)
	{
		self.year = [self.calendar component: NSCalendarUnitYear fromDate: [NSDate date]];
	}

	if (self.month == NSDateComponentUndefined)
	{
		self.month = [self.calendar component: NSCalendarUnitMonth fromDate: [NSDate date]];
	}

	NSInteger lastDayOfMonth = self.lastDayOfMonth;

	for (NSInteger day = 1; day <= lastDayOfMonth; day ++)
	{
		[computedDays addObject: @(day)];
	}
	
	return computedDays;
}

@end
