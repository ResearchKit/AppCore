// 
//  NSDateComponents+Helper.h 
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












