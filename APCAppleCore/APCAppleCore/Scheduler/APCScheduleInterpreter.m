//
//  APCScheduleInterpreter.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 9/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCScheduleInterpreter.h"

@implementation APCScheduleInterpreter

- (NSMutableArray *)taskDates:(NSString *)expression {
    
    NSMutableArray *taskDates = [[NSMutableArray alloc] init];
    
    NSArray* expressionComponents = [expression componentsSeparatedByString: @":"];
    
    NSString *hourExpression = [expressionComponents objectAtIndex:1];
    
    NSArray *numberOfHours = [self checkHours:hourExpression];
    
    //Determine whether date is based on absolute or relative time
    if ([[expressionComponents objectAtIndex:0] intValue] == 0) {
        
        for (int i = 0; i < [numberOfHours count]; i++) {
            
            NSDate * zeroHour = [self localizedAbsoluteHour];
            int executionHour = [[numberOfHours objectAtIndex:i] intValue];
            NSDate *taskDate = [self createDateFrom:zeroHour atHour:executionHour];
            [taskDates addObject:taskDate];
            
        }
    } else {
        
        for (int i = 0; i < [numberOfHours count]; i++) {
            
            NSDate * zeroHour = [self relativeHour];
            int executionHour = [[numberOfHours objectAtIndex:i] intValue];
            NSDate *taskDate = [self createDateFrom:zeroHour atHour:executionHour];
            [taskDates addObject:taskDate];        }
    }
    
    return taskDates;
}
    
- (NSArray *)checkHours:(NSString *)expression {
    
    return [expression componentsSeparatedByString:@","];
}

- (NSDate *)localizedAbsoluteHour {
    
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone: [NSTimeZone systemTimeZone]];
    
    // Specify the date components manually (year, month, day, hour, minutes, etc.)
    NSDate *now = [NSDate date];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitDay    |
                                    NSCalendarUnitMonth  |
                                    NSCalendarUnitYear   |
                                    NSCalendarUnitEra    |
                                    NSCalendarUnitSecond |
                                    NSCalendarUnitMinute |
                                    NSCalendarUnitHour   |
                                    NSCalendarUnitWeekday
                                               fromDate:now];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    // transform the date compoments into a date, based on current calendar settings
    NSDate *date = [calendar dateFromComponents:components];

    return date;
}

//This is based on the user's waking time;
- (NSDate *)relativeHour {
    
    //TODO this is a shim
    int userWakeTime = 8;
    
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone: [NSTimeZone systemTimeZone]];
    
    // Specify the date components manually (year, month, day, hour, minutes, etc.)
    NSDate *now = [NSDate date];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitDay    |
                                    NSCalendarUnitMonth  |
                                    NSCalendarUnitYear   |
                                    NSCalendarUnitEra    |
                                    NSCalendarUnitSecond |
                                    NSCalendarUnitMinute |
                                    NSCalendarUnitHour   |
                                    NSCalendarUnitWeekday
                                               fromDate:now];
    
    [components setHour:userWakeTime];
    [components setMinute:0];
    [components setSecond:0];
    
    // transform the date compoments into a date, based on current calendar settings
    NSDate *date = [calendar dateFromComponents:components];

    return date;
}

- (NSDate *)createDateFrom:(NSDate *)zeroHour atHour:(int)hourIncrement {
    
    NSTimeInterval hourInterval = hourIncrement * 60 * 60;
    
    NSDate *dueOnDate = [zeroHour dateByAddingTimeInterval:hourInterval];
    
    return dueOnDate;
}

@end
