//
//  NSDateComponents+Helper.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "NSDateComponents+Helper.h"


static NSCalendar *_gregorianCalendar = nil;
static NSTimeZone *_utcTimeZone = nil;


@implementation NSDateComponents (Helper)

+ (NSCalendar *) gregorianCalendar
{
	if (_gregorianCalendar == nil)
		_gregorianCalendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];

	return _gregorianCalendar;
}

+ (NSTimeZone *) utcTimeZone
{
	if (_utcTimeZone == nil)
		_utcTimeZone = [NSTimeZone timeZoneWithAbbreviation: @"UTC"];

	return _utcTimeZone;
}

+ (instancetype) componentsInGregorianUTC
{
	NSDateComponents *components = [self new];

	components.timeZone = [self utcTimeZone];
	components.calendar = [self gregorianCalendar];

	return components;
}

+ (instancetype) componentsInGregorianUTCWithMonth: (NSNumber *) month
											  year: (NSNumber *) year
{
	NSDateComponents *components = [self new];

	components.timeZone = [self utcTimeZone];
	components.calendar = [self gregorianCalendar];
	components.year		= year.integerValue;
	components.month	= month.integerValue;

	return components;
}

+ (instancetype) components: (NSArray *) arrayOfNSCalendarUnits
	 inGregorianUTCFromDate: (NSDate *) date
{
	NSCalendar *calendar = [self gregorianCalendar];
	NSTimeZone *timeZone = [self utcTimeZone];

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

- (NSInteger) cronDayOfWeekForDay: (NSInteger) dayInCurrentMonthYearAndCalendar
{
	// I'm modifying this DateComponents object, by design.
	// This is a shortcut for allocating an NSDateComponents object
	// and then setting all its fields.
	self.day = dayInCurrentMonthYearAndCalendar;
	
	NSDate *myDate = self.date;
	NSInteger oneBasedDayOfWeek = [self.calendar component: NSCalendarUnitWeekday fromDate: myDate];
	NSInteger zeroBasedDayOfWeek = oneBasedDayOfWeek - 1;

	// Convert 1..7 to 0..6 .
	if (zeroBasedDayOfWeek < 0) zeroBasedDayOfWeek += 7;

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
		self.calendar = [NSCalendar currentCalendar];

	if (self.year == NSDateComponentUndefined)
		self.year = [self.calendar component: NSCalendarUnitYear fromDate: [NSDate date]];

	if (self.month == NSDateComponentUndefined)
		self.month = [self.calendar component: NSCalendarUnitMonth fromDate: [NSDate date]];

	NSInteger lastDayOfMonth = self.lastDayOfMonth;

	for (NSInteger day = 1; day <= lastDayOfMonth; day ++)
	{
		[computedDays addObject: @(day)];
	}
	
	return computedDays;
}

@end
