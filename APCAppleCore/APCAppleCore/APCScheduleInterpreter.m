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
    
    //TODO this is a shim
    int userWakeTime = 8;
    
    NSMutableArray *taskDates = [[NSMutableArray alloc] init];
    
    NSArray* expressionComponents = [expression componentsSeparatedByString: @":"];
    
    NSString *hourExpression = [expressionComponents objectAtIndex:1];
    
    NSArray *numberOfHours = [self checkHours:hourExpression];
    
    //Determine whether date is based on absolute or relative time
    if ([[expressionComponents objectAtIndex:0] intValue] == 0) {
        
        for (int i = 0; i < [numberOfHours count]; i++) {
            
            int executionHour = [[numberOfHours objectAtIndex:i] intValue];
            NSDate *taskDate = [self createDateFrom:0 atHour:executionHour];
            [taskDates addObject:taskDate];
            
        }
    } else {
        
        for (int i = 0; i < [numberOfHours count]; i++) {
            
            int executionHour = [[numberOfHours objectAtIndex:i] intValue];
            NSDate *taskDate = [self createDateFrom:userWakeTime atHour:executionHour];
            [taskDates addObject:taskDate];        }
    }
    
    return taskDates;
}
    
- (NSArray *)checkHours:(NSString *)expression {
    
    return [expression componentsSeparatedByString:@","];
}

- (NSDate *)createDateFrom:(int)startHour atHour:(int)hourIncrement {
    
    NSLog(@"Starting at %d adding %d", startHour, hourIncrement);
    NSDate *now = [NSDate date];
    
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitDay    |
                                    NSCalendarUnitMonth  |
                                    NSCalendarUnitYear   |
                                    NSCalendarUnitEra    |
                                    NSCalendarUnitSecond |
                                    NSCalendarUnitMinute |
                                    NSCalendarUnitHour   |
                                    NSCalendarUnitWeekday
                                               fromDate:now];
    
    int hour = startHour + hourIncrement;
    
    [components setHour:hour];
    [components setMinute:0];
    NSDate *taskDate = [calendar dateFromComponents:components];
    
    NSTimeInterval distanceBetweenDates = [now timeIntervalSinceDate:taskDate];
    double secondsInAnHour = 3600;
    NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
    NSLog(@"Update at %@ Hours Between Dates %ld and now %@", taskDate, (long)hoursBetweenDates, now);
    
    return taskDate;
}
    
@end
