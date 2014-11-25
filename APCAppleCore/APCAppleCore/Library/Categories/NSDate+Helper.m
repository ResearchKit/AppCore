//
//  NSDate+Helper.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/11/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "NSDate+Helper.h"

NSString * const NSDateDefaultDateFormat            = @"MMM dd, yyyy";

@implementation NSDate (Helper)

- (NSString *) toStringWithFormat:(NSString *)format {
    if (!format) {
        format = NSDateDefaultDateFormat;
    }
    
    NSString *formattedString = nil;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = format;
    formattedString = [dateFormatter stringFromDate:self];
    
    return formattedString;
}

+ (instancetype) startOfDay: (NSDate*) date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    return [cal dateFromComponents:components];
}

+ (instancetype) endOfDay: (NSDate*) date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    return [cal dateFromComponents:components];
}

+ (instancetype) startOfTomorrow: (NSDate*) date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    [components setDay:[components day] + 1];
    return [cal dateFromComponents:components];
}

+(instancetype)todayAtMidnight
{
    NSDate *today = [NSDate date];
    return [self startOfDay:today];
}

+(instancetype)tomorrowAtMidnight
{
    NSDate *today = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:today];
    [components setDay:[components day] + 1];
    return [cal dateFromComponents:components];
}


@end
