//
//  NSDateComponents+Helper.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateComponents (Helper)

/*
 These methods work.  I commented them out to make sure,
 for the moment, I'm not using them by accident.

 + (instancetype) componentsInGregorianWithTimeZone: (NSTimeZone *) timeZone;
 + (instancetype) componentsInGregorianWithTimeZone: (NSTimeZone *) timeZone month: (NSNumber *) month year: (NSNumber *) year;
 + (instancetype) components: (NSArray *) arrayOfNSCalendarUnits inGregorianWithTimeZone: (NSTimeZone *) timeZone fromDate: (NSDate *) date;

 + (instancetype) componentsInGregorianUTC;
 + (instancetype) componentsInGregorianUTCWithMonth: (NSNumber *) month year: (NSNumber *) year;
 + (instancetype) components: (NSArray *) arrayOfNSCalendarUnits inGregorianUTCFromDate: (NSDate *) date;
 */


/**
 These methods create and return an NSDateComponents object
 in the user's local time zone, in the Gregorian calendar.
 */
+ (instancetype) componentsInGregorianLocal;
+ (instancetype) componentsInGregorianLocalWithMonth: (NSNumber *) month year: (NSNumber *) year;
+ (instancetype) components: (NSArray *) arrayOfNSCalendarUnits inGregorianLocalFromDate: (NSDate *) date;


/**
 These methods MODIFY self, by design.  They're
 designed as a tool for iteratively modifying an
 NSDateComponents object to detect various
 days of the week.
 */
- (NSInteger) cronDayOfWeekForDay: (NSInteger) dayInCurrentMonthYearAndCalendar;
- (NSNumber *) cronDayOfWeekAsNSNumberForDay: (NSNumber *) dayInCurrentMonthYearAndCalendar;


/**
 Returns the integer last day of the month.  For example,
 returns 28 for February in a non-leap year.
 */
@property (nonatomic, readonly) NSInteger lastDayOfMonth;


/**
 Calculates and returns an NSArray containing
 NSNumbers representing each day in the current month.
 For example:  @1, @2, ... @28  for "February."
 
 This is a "property" only so we can get compiler help
 for the dot-syntax.  Example:
 
	NSArray *days = myDateComponents.allDaysInMonth;
 */
@property (nonatomic, readonly) NSArray *allDaysInMonth;

@end












