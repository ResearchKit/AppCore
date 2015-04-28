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

- (NSString *) friendlyDescription;
- (NSDate *) dateByAddingDays:(NSInteger)inDays;

+ (NSUInteger)ageFromDateOfBirth:(NSDate *)dateOfBirth;
+ (instancetype) startOfDay: (NSDate*) date;
+ (instancetype) endOfDay: (NSDate*) date;
+ (instancetype) startOfTomorrow: (NSDate*) date;

- (instancetype) startOfDay;
- (instancetype) endOfDay;

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

+ (NSTimeInterval) parseISO8601DurationString: (NSString*) duration ;

@end
