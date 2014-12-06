//
//  NSDateComponents+Helper.h
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateComponents (Helper)

/**
 Returns a new NSDateComponents object set to the
 Gregorian calendar and UTC time zone.
 
 @see +componentsInGregorianUTCWithMonth:year:
 @see +components:inGregorianUTCFromDate:
 */
+ (instancetype) componentsInGregorianUTC;

/**
 Returns a new NSDateComponents object set to the specified
 month and year.  Also sets the calendar to "Gregorian" and
 the time zone to "UTC".
 
 Designed for situations where we need to iterate through
 the days of a month and extract their days of the week.
 (We can certainly generalize as needed.)
 
 Also designed to ensure we can accurately compare and
 enumerate dates which might span a time-zone or
 daylight-savings boundary.
 
 Takes NSNumbers because (again) that's currently what I
 need from it.  (I'm choosing not to overgeneralize or
 overengineer something that's still evolving.)

 @see +componentsInGregorianUTC
 @see +components:inGregorianUTCFromDate:
 */
+ (instancetype) componentsInGregorianUTCWithMonth: (NSNumber *) month
											  year: (NSNumber *) year;

/**
 Returns a new NSDateComponents object with the specified
 components extracted from the specified date.  Also
 sets the calendar to "Gregorian" and the time zone
 to "UTC".

 Designed for situations where we need to iterate through
 the days of a month and extract their days of the week.
 (We can certainly generalize as needed.)

 Also designed to ensure we can accurately compare and
 enumerate dates which might span a time-zone or
 daylight-savings boundary.

 @see +componentsInGregorianUTC
 @see +componentsInGregorianUTCWithMonth:year:
 */
+ (instancetype) components: (NSArray *) arrayOfNSCalendarUnits
	 inGregorianUTCFromDate: (NSDate *) date;

/**
 Returns the cron-style (zero-based) day-of-the-week for
 the specified day in the current month and year.
 Presumes you've already configured this DateComponents
 object with a calendar, year, and month.

 Uses -[NSDate+Helper cronDayOfWeekUsingCalendar:].

 @return An NSInteger containing the digit 0-6, representing
 Sunday through Saturday.

 @see -cronDayOfWeekAsNumberForDay:
 */
- (NSInteger) cronDayOfWeekForDay: (NSInteger) dayInCurrentMonthYearAndCalendar;


/**
 Returns the cron-style (zero-based) day-of-the-week for
 the specified day in the current month and year.
 Presumes you've already configured this DateComponents
 object with a calendar, year, and month.

 Uses on -cronDayOfWeekForDay.

 @return An NSNumber containing the digit 0-6, representing
 Sunday through Saturday.

 @see -cronDayOfWeekForDay:
 */
- (NSNumber *) cronDayOfWeekAsNSNumberForDay: (NSNumber *) dayInCurrentMonthYearAndCalendar;


/**
 Returns the last day of the month for the month, year,
 and calendar currently stored in this DateComponents
 object.
 
 @see -dateComponentsWithMonth:year:calendar:
 */
@property (nonatomic, readonly) NSInteger lastDayOfMonth;

/**
 Returns an NSArray of NSNumbers representing every day
 in the current month, year, and calendar represented
 by this DateComponents object.  Presumes you've already
 configured the object to have a specific month, year,
 and calendar.
 
 For example, if the current month is February of a
 leap year, the returned array contains a set of NSNumbers
 from 1 to 28.
 
 If the current month or year is undefined, gets them
 from the current date.
 
 If the current calendar is undefined, gets it from the system
 calendar.
 */
@property (nonatomic, readonly) NSArray *allDaysInMonth;

@end












