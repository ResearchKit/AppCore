// 
//  NSDate+Helper.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "NSDate+Helper.h"

NSString * const NSDateDefaultDateFormat            = @"MMM dd, yyyy";


/**
 Sage requires our dates to be in "ISO-8601" format,
 like this:

 2015-02-25T16:42:11+00:00

 Got the rules from http://en.wikipedia.org/wiki/ISO_8601
 Date-formatting rules from http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
 */
static NSString * const kDateFormatISO8601 = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";



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

- (NSString *) toStringInISO8601Format
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat: kDateFormatISO8601];

    /*
     Set the formatter's locale.  Otherwise, the result will
     come out in the user's local language, not in English; and
     we wanna be able to generate it in English, since that's
     how Sage is expecting it.  For the reason to set the POSIX
     locale ("en_US_POSIX"), instead of the simpler "en-US",
     see:  http://blog.gregfiumara.com/archives/245
     */
    [formatter setLocale: [[NSLocale alloc] initWithLocaleIdentifier: @"en_US_POSIX"]];

    NSString *result = [formatter stringFromDate: self];
    return result;
}

+ (instancetype) startOfDay: (NSDate*) date
{
    return [date startOfDay];
}

- (instancetype) startOfDay
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate: self];
    return [cal dateFromComponents:components];
}

+ (instancetype) endOfDay: (NSDate*) date
{
    return [date endOfDay];
}

- (instancetype) endOfDay
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate: self];
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

+(instancetype)yesterdayAtMidnight
{
    NSDate *today = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:today];
    [components setDay:[components day] - 1];
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

- (BOOL) isEarlierThanDate: (NSDate*) otherDate
{
	BOOL result = [self compare: otherDate] == NSOrderedAscending;
	return result;
}

- (BOOL) isLaterThanDate: (NSDate*) otherDate
{
	BOOL result = [self compare: otherDate] == NSOrderedDescending;
	return result;
}

- (BOOL) isEarlierOrEqualToDate: (NSDate*) otherDate
{
	BOOL result = [self compare: otherDate] != NSOrderedDescending;
	return result;
}

- (BOOL) isLaterThanOrEqualToDate: (NSDate*) otherDate
{
	BOOL result = [self compare: otherDate] != NSOrderedAscending;
	return result;
}

- (BOOL) isInThePast
{
    BOOL result = [self timeIntervalSinceNow] < 0;
    return result;
}

- (BOOL) isInTheFuture
{
    BOOL result = [self timeIntervalSinceNow] > 0;
    return result;
}

+ (NSTimeInterval) parseISO8601DurationString: (NSString*) duration {
    
    float i = 0, years = 0, months = 0, weeks = 0, days = 0, hours = 0, minutes = 0, seconds = 0;
    BOOL timeStarted = NO;
    
    while(i < duration.length)
    {
        NSString *str = [duration substringWithRange:NSMakeRange(i, duration.length-i)];
        
        i++;
        
        if([str hasPrefix:@"P"]) continue;
        
        if ([str hasPrefix:@"T"]) {
            timeStarted = YES;
            continue;
        }
        
        
        NSScanner *sc = [NSScanner scannerWithString:str];
        float value = 0;
        
        if ([sc scanFloat:&value])
        {
            i += [sc scanLocation]-1;
            
            str = [duration substringWithRange:NSMakeRange(i, duration.length-i)];
            
            i++;
            
            if([str hasPrefix:@"Y"])
                years = value;
            else if([str hasPrefix:@"M"] && !timeStarted)
                months = value;
            else if([str hasPrefix:@"W"])
                weeks = value;
            else if([str hasPrefix:@"D"])
                days = value;
            else if([str hasPrefix:@"H"])
                hours = value;
            else if([str hasPrefix:@"M"] && timeStarted)
                minutes = value;
            else if([str hasPrefix:@"S"])
                seconds = value;
        }
    }
    
//    NSLog(@"%@", [NSString stringWithFormat:@"%0.2f years, %0.2f months, %0.2f weeks, %0.2f days, %0.2f hours, %0.2f mins, %0.2f seconds", years, months, weeks, days, hours, minutes, seconds]);
    NSTimeInterval interval = 0;
    interval = years * 365 + months * 30 + weeks * 7 + days; //Days
    interval = (interval * 24) + hours; //Hours
    interval = (interval * 60) + minutes; //Minutes
    interval = (interval * 60) + seconds; //Seconds
    return interval;
}

@end
