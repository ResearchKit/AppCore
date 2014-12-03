// 
//  NSDate+Helper.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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

- (NSDate *)dateByAddingDays:(NSInteger)inDays
{
    static NSCalendar *cal;
    static dispatch_once_t once;
    dispatch_once(&once, ^
                  {
                      cal = [NSCalendar currentCalendar];
                  });
    
    NSDateComponents *components = [cal components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:self];
    [components setDay:[components day] + inDays];
    return [cal dateFromComponents:components];
}

-(NSString *) friendlyDescription
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *date = [formatter dateFromString:[formatter stringFromDate:self]];
    
    NSDate *today = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
    NSDate *yesterday = [today dateByAddingDays:-1];
    NSDate *oneWeekAgo = [today dateByAddingDays:-7];
    NSDate *tomorrow = [today dateByAddingDays:1];
    
    NSString * retValue;
    if([date isEqual:today])
    {
        retValue = NSLocalizedString(@"Today", nil);
    }
    else if([date isEqual:yesterday])
    {
        retValue = NSLocalizedString(@"Yesterday", nil);
    }
    else if(([date laterDate:oneWeekAgo] == date) && ([date laterDate:tomorrow] == tomorrow))
    {
        NSDateFormatter *thisWeekFormat = [NSDateFormatter new];
        [thisWeekFormat setDateFormat:@"EEEE"];
        retValue = [thisWeekFormat stringFromDate:date];
    }
    else
    {
        NSDateFormatter *everythingElseFormatter = [NSDateFormatter new];
        [everythingElseFormatter setDateFormat:NSDateDefaultDateFormat];
        retValue = [everythingElseFormatter stringFromDate:date];
    }
    
    return retValue;
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


+(instancetype)weekAgoAtMidnight
{
    NSDate *today = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:today];
    [components setDay:[components day] - 7];
    return [cal dateFromComponents:components];
}


@end
