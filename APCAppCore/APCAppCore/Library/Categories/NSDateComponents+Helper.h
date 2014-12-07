//
//  NSDateComponents+Helper.h
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateComponents (Helper)

//+ (instancetype) componentsInGregorianWithTimeZone: (NSTimeZone *) timeZone;
//+ (instancetype) componentsInGregorianWithTimeZone: (NSTimeZone *) timeZone month: (NSNumber *) month year: (NSNumber *) year;
//+ (instancetype) components: (NSArray *) arrayOfNSCalendarUnits inGregorianWithTimeZone: (NSTimeZone *) timeZone fromDate: (NSDate *) date;

//+ (instancetype) componentsInGregorianUTC;
//+ (instancetype) componentsInGregorianUTCWithMonth: (NSNumber *) month year: (NSNumber *) year;
//+ (instancetype) components: (NSArray *) arrayOfNSCalendarUnits inGregorianUTCFromDate: (NSDate *) date;

+ (instancetype) componentsInGregorianLocal;
+ (instancetype) componentsInGregorianLocalWithMonth: (NSNumber *) month year: (NSNumber *) year;
+ (instancetype) components: (NSArray *) arrayOfNSCalendarUnits inGregorianLocalFromDate: (NSDate *) date;


- (NSInteger) cronDayOfWeekForDay: (NSInteger) dayInCurrentMonthYearAndCalendar;
- (NSNumber *) cronDayOfWeekAsNSNumberForDay: (NSNumber *) dayInCurrentMonthYearAndCalendar;

@property (nonatomic, readonly) NSInteger lastDayOfMonth;
@property (nonatomic, readonly) NSArray *allDaysInMonth;

@end












