// 
//  NSDate+Helper.h 
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
 
@import Foundation;

extern NSString * const NSDateDefaultDateFormat;
extern NSString * const DateFormatISO8601DateOnly;

@interface NSDate (Helper)

/**
 * @brief convert date to give format
 * @param format - format for the date to be converted, Use by NSDateFormatter, if format = nil then NSDateDefaultDateFormat will be use by this method
 */
- (NSString *) toStringWithFormat:(NSString *)format;

/**
 Sage requires our dates to be in "ISO-8601" format,
 like this:
 
        2015-02-25T16:42:11+00:00
 
 Got the rules from http://en.wikipedia.org/wiki/ISO_8601
 */
- (NSString *) toStringInISO8601Format;

/**
 Tries to interpret the specified string with any of
 several legal ISO 8601 formats.
 
 To add formats, modify the +initialize method in this
 category.
 
 @return An NSDate, if one could be created from the
 specified string.  Returns nil if the conversion failed.
 To change the list of possible input formats, change the
 +initialize method in this category.
 */
+ (NSDate *) dateWithISO8601String: (NSString *) iso8601string;

- (NSString *) friendlyDescription;
- (NSDate *) dateByAddingDays:(NSInteger)inDays;

+ (NSUInteger)ageFromDateOfBirth:(NSDate *)dateOfBirth;
+ (instancetype) startOfDay: (NSDate*) date;
+ (instancetype) endOfDay: (NSDate*) date;
+ (instancetype) startOfTomorrow: (NSDate*) date;

- (instancetype) startOfDay;
- (instancetype) endOfDay;

- (instancetype) dayBefore;
- (instancetype) dayAfter;

+(instancetype) todayAtMidnight;
+(instancetype) tomorrowAtMidnight;
+(instancetype) yesterdayAtMidnight;
+(instancetype) weekAgoAtMidnight;
+(instancetype) priorSundayAtMidnightFromDate:(NSDate *)date;

- (BOOL) isEarlierThanDate: (NSDate*) otherDate;
- (BOOL) isLaterThanDate: (NSDate*) otherDate;
- (BOOL) isEarlierOrEqualToDate: (NSDate*) otherDate;
- (BOOL) isLaterThanOrEqualToDate: (NSDate*) otherDate;
- (BOOL) isInThePast;
- (BOOL) isInTheFuture;

/**
 Returns YES if self and otherDate are on the same
 human-perceived day -- if they're both between midnight
 and midnight on the same date.
 */
- (BOOL) isSameDayAsDate: (NSDate *) otherDate;


/**
 Adds the specified duration string to the specified
 date.  Duration strings follow the ISO 8601 standard.
 Some examples:

 @code
 P3D        3 days ("P" == "period")
 P1W        1 week
 P2D5H10S   2 days, 5 hours, and 10 seconds
 P36H       36 hours, i.e., a day and a half
 P1.5D      a day and a half, i.e., 36 hours
 @endcode
 
 If you want to include minutes, you'll need a (T)ime
 indicator somewhere to the left of it, to distinguish it
 from months.  Like this:

 @code
 P3DT5M     3 days + 5 minutes
 @endcode
 
 You can use any time interval from (S)econds through
 (Y)ears, except fortnights.  Time will be measured in
 terms of the interval:  1.5D and 36H both give you a
 day and a half, but 1M or 1Y will give you different
 numbers of days, depending on the months and leap years
 as measured from startDate.  If you specify a startDate
 of nil, you'll get 30 days per month and 365 days per
 year.

 @param duration An ISO 8601 duration string, as described
 above.

 @param date A date from which to start counting.  Mostly
 matters for durations involving months:  "P1M" (1 month)
 means different things if you start on January 1 or
 February 1, and if months or years go far enough, we have
 to account for leap years.  So:  if you specify nil, the
 calculation will use 30 days per month (every month) and
 365 days per year.  If you specify a real date, the
 calculations will account for the actual number of days
 per month during the elapsed months, and will account for
 leap years.
 
 @see +timeIntervalBySubtractingISO8601Duration:fromDate
 @see http://en.wikipedia.org/wiki/ISO_8601#Durations
 */
+ (NSTimeInterval) timeIntervalByAddingISO8601Duration: (NSString *) duration
                                                toDate: (NSDate *) date;

/**
 Just like +timeIntervalByAddingISO8601Duration:toDate:,
 but subtracts the specified duration from the specified
 date.
 
 @see +timeIntervalByAddingISO8601Duration:toDate:
 */
+ (NSTimeInterval) timeIntervalBySubtractingISO8601Duration: (NSString *) duration
                                                   fromDate: (NSDate *) date;

/**
 Just like +timeIntervalByAddingISO8601Duration:toDate:,
 operating on self instead of a passed-in date parameter.

 @see +timeIntervalByAddingISO8601Duration:toDate:
 */
- (NSTimeInterval) timeIntervalByAddingISO8601Duration: (NSString *) duration;

/**
 Just like +timeIntervalByAddingISO8601Duration:toDate:,
 but subtracts the specified duration from the specified
 self instead of adding to a passed-in parameter.

 @see +timeIntervalByAddingISO8601Duration:toDate:
 */
- (NSTimeInterval) timeIntervalBySubtractingISO8601Duration: (NSString *) duration;

/**
 Adds the specified duration string to the specified
 date.  Duration strings follow the ISO 8601 standard.
 Some examples:

 @code
 P3D        3 days ("P" == "period")
 P1W        1 week
 P2D5H10S   2 days, 5 hours, and 10 seconds
 P36H       36 hours, i.e., a day and a half
 P1.5D      a day and a half, i.e., 36 hours
 @endcode

 If you want to include minutes, you'll need a (T)ime
 indicator somewhere to the left of it, to distinguish it
 from months.  Like this:

 @code
 P3DT5M     3 days + 5 minutes
 @endcode

 You can use any time interval from (S)econds through
 (Y)ears, except fortnights.  Time will be measured in
 terms of the interval:  1.5D and 36H both give you a
 day and a half, but 1M or 1Y will give you different
 numbers of days, depending on the months and leap years
 as measured from startDate.
 
 This method calls
 +timeIntervalByAddingISO8601Duration:toDate.

 @param durationString An ISO 8601 duration string, as
 described above.

 @see -dateBySubtractingISO8601Duration:
 @see +timeIntervalByAddingISO8601Duration:toDate:
 @see http://en.wikipedia.org/wiki/ISO_8601#Durations
 */
- (NSDate *) dateByAddingISO8601Duration: (NSString *) durationString;

/**
 Just like -dateByAddingISO8601Duration:, but subtracts
 the specified duration from self.  See
 -dateByAddingISO8601Duration: for details.

 @see -dateByAddingISO8601Duration:
 */
- (NSDate *) dateBySubtractingISO8601Duration: (NSString *) durationString;

@end
