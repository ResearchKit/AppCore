// 
//  NSDate+MedicationTracker.m 
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
 
#import "NSDate+MedicationTracker.h"
#import "APCConstants.h"
#import "NSDate+Helper.h"

@implementation NSDate (MedicationTracker)

- (NSDate *)getWeekStartDate: (NSInteger)weekStartIndex
{
    int  weekDay = [[self getWeekDay] intValue];

    NSInteger  gap = (weekStartIndex <= weekDay) ?  weekDay  : ( 7 + weekDay );
    NSInteger  day = weekStartIndex - gap;

    return [self dateByAddingDays:day];
}

- (NSNumber *)getWeekDay
{
    NSCalendar  *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents  *comps = [gregorian components:NSCalendarUnitWeekday fromDate:self];
    return  [NSNumber numberWithInteger:([comps weekday] - 1)];
}

- (NSString *)getDayOfWeekShortString
{
    static  NSDateFormatter  *formatter;

    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        NSLocale  *locale = [[NSLocale alloc] initWithLocaleIdentifier: kAPCDateFormatLocaleEN_US_POSIX];
        [formatter setLocale:locale];
        [formatter setDateFormat:@"E"];
    }
    return  [formatter stringFromDate:self];
}

- (NSString *)getDateOfMonth
{
    static  NSDateFormatter  *formatter;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        NSLocale  *en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier: kAPCDateFormatLocaleEN_US_POSIX];
        [formatter setLocale:en_US_POSIX];
        [formatter setDateFormat:@"d"];
    }
    return  [formatter stringFromDate:self];
}

- (NSDate*)midnightDate
{
    return [[NSCalendar currentCalendar] dateFromComponents:[[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self]];
}

- (BOOL) isSameDateWith: (NSDate *)aDate
{
    return  ([[self midnightDate] isEqualToDate: [aDate midnightDate]])?YES:NO;
}

- (BOOL)isDateToday
{
    return  [[[NSDate date] midnightDate] isEqual:[self midnightDate]];
}

- (BOOL)isWithinDate: (NSDate *)earlierDate toDate:(NSDate *)laterDate
{
    NSTimeInterval timestamp = [[self midnightDate] timeIntervalSince1970];
    NSDate  *fdt = [earlierDate midnightDate];
    NSDate  *tdt = [laterDate midnightDate];

    BOOL isWithinDate = (timestamp >= [fdt timeIntervalSince1970] && timestamp <= [tdt timeIntervalSince1970]);

    return  isWithinDate;
}

- (BOOL)isPastDate
{
    BOOL  answer = NO;

    NSDate  *now = [NSDate date];
    if ([[now earlierDate:self] isEqualToDate:self]) {
        answer = YES;
    } else {
        answer = NO;
    }
    return  answer;
}

@end
