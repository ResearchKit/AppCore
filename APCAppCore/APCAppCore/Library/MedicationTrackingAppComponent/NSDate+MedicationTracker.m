//
//  NSDate+MedicationTracker.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "NSDate+MedicationTracker.h"

static  NSString  *kDefaultLocale = @"en_US_POSIX";

@implementation NSDate (MedicationTracker)

- (NSDate *)getWeekStartDate: (NSInteger)weekStartIndex
{
    int weekDay = [[self getWeekDay] intValue];

    NSInteger gap = (weekStartIndex <=  weekDay) ?  weekDay  : ( 7 + weekDay );
    NSInteger day = weekStartIndex - gap;

    return [self addDays:day];
}

- (NSNumber *)getWeekDay
{
    NSCalendar  *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents  *comps = [gregorian components:NSCalendarUnitWeekday fromDate:self];
    return  [NSNumber numberWithInteger:([comps weekday] - 1)];
}

- (NSDate *)addDays:(NSInteger)day
{
    NSDateComponents  *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = day;

    NSCalendar  *theCalendar = [NSCalendar currentCalendar];
    return  [theCalendar dateByAddingComponents:dayComponent toDate:self options:0];
}

- (NSString *)getDayOfWeekShortString
{
    static  NSDateFormatter  *shortDayOfWeekFormatter;

    if (shortDayOfWeekFormatter == nil) {
        shortDayOfWeekFormatter = [[NSDateFormatter alloc] init];
        NSLocale  *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [shortDayOfWeekFormatter setLocale:locale];
        [shortDayOfWeekFormatter setDateFormat:@"E"];
    }
    return  [shortDayOfWeekFormatter stringFromDate:self];
}

- (NSString *)getDateOfMonth
{
    static NSDateFormatter  *formatter;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        NSLocale* en_AU_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:kDefaultLocale];
        [formatter setLocale:en_AU_POSIX];
        [formatter setDateFormat:@"d"];
    }
    return  [formatter stringFromDate:self];
}

- (NSDate*)midnightDate
{
    return [[NSCalendar currentCalendar] dateFromComponents:[[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self]];
}

- (BOOL) isSameDateWith: (NSDate *)dt
{
    return  ([[self midnightDate] isEqualToDate: [dt midnightDate]])?YES:NO;
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
