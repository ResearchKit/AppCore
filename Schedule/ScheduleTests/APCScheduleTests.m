//
//  APCScheduleTests.m
//  Schedule
//
//  Created by Edward Cessna on 10/8/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APCSchedule.h"

@interface APCScheduleTests : XCTestCase

@property (nonatomic, strong) NSDateFormatter*  dateFormatter;
@property (nonatomic, strong) NSCalendar*       calendar;

@end

@implementation APCScheduleTests

- (void)setUp
{
    [super setUp];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];


    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEnumeratingConstantMinutes
{
    /*
     0:      Relative indicator  A, R                        A: absolute, R: relative
     1:      Minutes             0-59        * , -
     2:      Hours               0-23        * , -
     3:      Day of month        1-31        * , -
     4:      Month               1-12        * , -           1: Jan, 2: Feb, ..,, 12: Dec
     5:      Day of week         0-6         * , -           0: Sun, 1: Mon, ..., 6: Sat
     */
    
    NSString*       cronExpression = @"A 5 * * * *";
    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
    NSDate*         nextMoment     = nil;

    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
    for (NSInteger year = 2014; year < 2016; ++year)
    {
        for (NSInteger month = 1; month < 13; ++month)
        {
            for (NSInteger day = 1; day < 32; ++day)
            {
                for (NSInteger hour = 0; hour < 24; ++hour)
                {
                    NSInteger           minute         = 5;
                    NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
                    
                    dateComponents.calendar = self.calendar;
                    dateComponents.year     = year;
                    dateComponents.month    = month;
                    dateComponents.day      = day;
                    dateComponents.hour     = hour;
                    dateComponents.minute   = minute;
                    
                    NSDate* date = [dateComponents date];
                    
                    nextMoment = [enumerator nextObject];
                    
                    XCTAssertEqualObjects(nextMoment, date);
                }
            }
        }
    }
}

- (void)testEnumeratingMinuteList
{
    NSString*       cronExpression = @"A 15,30,45 * * * *";
    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
    NSDate*         nextMoment     = nil;
    
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
    for (NSInteger year = 2014; year < 2016; ++year)
    {
        for (NSInteger month = 1; month < 13; ++month)
        {
            for (NSInteger day = 1; day < 32; ++day)
            {
                for (NSInteger hour = 0; hour < 24; ++hour)
                {
                    for (NSInteger minute = 15; minute <= 45; minute += 15)
                    {
                        NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
                        
                        dateComponents.calendar = self.calendar;
                        dateComponents.year     = year;
                        dateComponents.month    = month;
                        dateComponents.day      = day;
                        dateComponents.hour     = hour;
                        dateComponents.minute   = minute;
                        
                        NSDate* date = [dateComponents date];
                        
                        nextMoment = [enumerator nextObject];
                        
                        XCTAssertEqualObjects(nextMoment, date);
                    }
                }
            }
        }
    }
}

- (void)testEnumeratingMinuteRange
{
    NSString*       cronExpression = @"A 15-30 * * * *";
    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
    NSDate*         nextMoment     = nil;
    
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
    for (NSInteger year = 2014; year < 2016; ++year)
    {
        for (NSInteger month = 1; month < 13; ++month)
        {
            for (NSInteger day = 1; day < 32; ++day)
            {
                for (NSInteger hour = 0; hour < 24; ++hour)
                {
                    for (NSInteger minute = 15; minute <= 30; ++minute)
                    {
                        NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
                        
                        dateComponents.calendar = self.calendar;
                        dateComponents.year     = year;
                        dateComponents.month    = month;
                        dateComponents.day      = day;
                        dateComponents.hour     = hour;
                        dateComponents.minute   = minute;
                        
                        NSDate* date = [dateComponents date];
                        
                        nextMoment = [enumerator nextObject];
                        
                        XCTAssertEqualObjects(nextMoment, date);
                    }
                }
            }
        }
    }
}

- (void)testEnumeratingConstantHour
{
    NSString*       cronExpression = @"A * 10 * * *";
    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
    NSDate*         nextMoment     = nil;
    
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 08:00"]];

    for (NSInteger year = 2014; year < 2016; ++year)
    {
        for (NSInteger month = 1; month < 13; ++month)
        {
            for (NSInteger day = 1; day < 32; ++day)
            {
                NSInteger   hour = 10;
//                for (NSInteger hour = 8; hour < 24; hour += 10)
                {
                    for (NSInteger minute = 0; minute < 60; ++minute)
                    {
                        NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
                        
                        dateComponents.calendar = self.calendar;
                        dateComponents.year     = year;
                        dateComponents.month    = month;
                        dateComponents.day      = day;
                        dateComponents.hour     = hour;
                        dateComponents.minute   = minute;
                        
                        NSDate* date = [dateComponents date];
                        
                        nextMoment = [enumerator nextObject];
                        
                        XCTAssertEqualObjects(nextMoment, date);
                    }
                }
            }
        }
    }
}

- (void)testEnumeratingHourList
{
    NSString*       cronExpression = @"A * 8,12,16 * * *";
    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
    NSDate*         nextMoment     = nil;
    
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 08:00"]];

    for (NSInteger year = 2014; year < 2016; ++year)
    {
        for (NSInteger month = 1; month < 13; ++month)
        {
            for (NSInteger day = 1; day < 32; ++day)
            {
                for (NSInteger hour = 8; hour <= 16; hour += 4)
                {
                    for (NSInteger minute = 0; minute < 60; ++minute)
                    {
                        NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
                        
                        dateComponents.calendar = self.calendar;
                        dateComponents.year     = year;
                        dateComponents.month    = month;
                        dateComponents.day      = day;
                        dateComponents.hour     = hour;
                        dateComponents.minute   = minute;
                        
                        NSDate* date = [dateComponents date];
                        
                        nextMoment = [enumerator nextObject];
                        
                        XCTAssertEqualObjects(nextMoment, date);
                    }
                }
            }
        }
    }
}

- (void)testEnumeratingHourRange
{
    NSString*       cronExpression = @"A * 8-5 * * *";
    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
    NSDate*         nextMoment     = nil;
    
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 08:00"]];
    
    for (NSInteger year = 2014; year < 2016; ++year)
    {
        for (NSInteger month = 1; month < 13; ++month)
        {
            for (NSInteger day = 1; day < 32; ++day)
            {
                for (NSInteger hour = 8; hour <= 5; ++hour)
                {
                    for (NSInteger minute = 0; minute < 60; ++minute)
                    {
                        NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
                        
                        dateComponents.calendar = self.calendar;
                        dateComponents.year     = year;
                        dateComponents.month    = month;
                        dateComponents.day      = day;
                        dateComponents.hour     = hour;
                        dateComponents.minute   = minute;
                        
                        NSDate* date = [dateComponents date];
                        
                        nextMoment = [enumerator nextObject];
                        
                        XCTAssertEqualObjects(nextMoment, date);
                    }
                }
            }
        }
    }
}

- (void)testEnumeratingConstantDayOfMonth
{
    NSString*       cronExpression = @"A * * 15 * *";
    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
    NSDate*         nextMoment     = nil;
    
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

    for (NSInteger year = 2014; year < 2016; ++year)
    {
        for (NSInteger month = 1; month < 13; ++month)
        {
            NSInteger   day = 15;
            for (NSInteger hour = 0; hour < 24; ++hour)
            {
                for (NSInteger minute = 0; minute < 60; ++minute)
                {
                    NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
                    
                    dateComponents.calendar = self.calendar;
                    dateComponents.year     = year;
                    dateComponents.month    = month;
                    dateComponents.day      = day;
                    dateComponents.hour     = hour;
                    dateComponents.minute   = minute;
                    
                    NSDate* date = [dateComponents date];
                    
                    nextMoment = [enumerator nextObject];
                    
                    XCTAssertEqualObjects(nextMoment, date);
                }
            }
        }
    }
}

- (void)testEnumeratingDayOfMonthList
{
    NSString*       cronExpression = @"A * * 15,30 * *";
    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
    NSDate*         nextMoment     = nil;
    
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

    for (NSInteger year = 2014; year < 2016; ++year)
    {
        for (NSInteger month = 1; month < 13; ++month)
        {
            for (NSInteger day = 15; day < 31; day += 15)
            {
                for (NSInteger hour = 0; hour < 24; ++hour)
                {
                    for (NSInteger minute = 0; minute < 60; ++minute)
                    {
                        NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
                        
                        dateComponents.calendar = self.calendar;
                        dateComponents.year     = year;
                        dateComponents.month    = month;
                        dateComponents.day      = day;
                        dateComponents.hour     = hour;
                        dateComponents.minute   = minute;
                        
                        NSDate* date = [dateComponents date];
                        
                        nextMoment = [enumerator nextObject];
                        
                        XCTAssertEqualObjects(nextMoment, date);
                    }
                }
            }
        }
    }
}

- (void)testEnumeratingDayOfMonthRange
{
    NSString*       cronExpression = @"A * * 1-14 * *";
    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
    NSDate*         nextMoment     = nil;
    
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
    for (NSInteger year = 2014; year < 2016; ++year)
    {
        for (NSInteger month = 1; month < 13; ++month)
        {
            for (NSInteger day = 1; day < 15; ++day)
            {
                for (NSInteger hour = 0; hour < 24; ++hour)
                {
                    for (NSInteger minute = 0; minute < 60; ++minute)
                    {
                        NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
                        
                        dateComponents.calendar = self.calendar;
                        dateComponents.year     = year;
                        dateComponents.month    = month;
                        dateComponents.day      = day;
                        dateComponents.hour     = hour;
                        dateComponents.minute   = minute;
                        
                        NSDate* date = [dateComponents date];
                        
                        nextMoment = [enumerator nextObject];
                        
                        XCTAssertEqualObjects(nextMoment, date);
                    }
                }
            }
        }
    }
}

- (void)testEnumeratingConstantMonth
{
    NSString*       cronExpression = @"A * * * 4 *";
    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
    NSDate*         nextMoment     = nil;
    
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
    for (NSInteger year = 2014; year < 2016; ++year)
    {
        NSInteger   month = 4;
        for (NSInteger day = 1; day < 32; ++day)
        {
            for (NSInteger hour = 0; hour < 24; ++hour)
            {
                for (NSInteger minute = 0; minute < 60; ++minute)
                {
                    NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
                    
                    dateComponents.calendar = self.calendar;
                    dateComponents.year     = year;
                    dateComponents.month    = month;
                    dateComponents.day      = day;
                    dateComponents.hour     = hour;
                    dateComponents.minute   = minute;
                    
                    NSDate* date = [dateComponents date];
                    
                    nextMoment = [enumerator nextObject];
                    
                    XCTAssertEqualObjects(nextMoment, date);
                }
            }
        }
    }
}

- (void)testEnumeratingMonthList
{
    NSString*       cronExpression = @"A * * * 2,4,6,8 *";
    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
    NSDate*         nextMoment     = nil;
    
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
    for (NSInteger year = 2014; year < 2016; ++year)
    {
        for (NSInteger month = 2; month < 9; month += 2)
        {
            for (NSInteger day = 1; day < 32; ++day)
            {
                for (NSInteger hour = 0; hour < 24; ++hour)
                {
                    for (NSInteger minute = 0; minute < 60; ++minute)
                    {
                        NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
                        
                        dateComponents.calendar = self.calendar;
                        dateComponents.year     = year;
                        dateComponents.month    = month;
                        dateComponents.day      = day;
                        dateComponents.hour     = hour;
                        dateComponents.minute   = minute;
                        
                        NSDate* date = [dateComponents date];
                        
                        nextMoment = [enumerator nextObject];
                        
                        XCTAssertEqualObjects(nextMoment, date);
                    }
                }
            }
        }
    }
}

- (void)testEnumeratingMonthRange
{
    NSString*       cronExpression = @"A * * * 6-9 *";
    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
    NSDate*         nextMoment     = nil;
    
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
    for (NSInteger year = 2014; year < 2016; ++year)
    {
        for (NSInteger month = 6; month <= 9; ++month)
        {
            for (NSInteger day = 1; day < 32; ++day)
            {
                for (NSInteger hour = 0; hour < 24; ++hour)
                {
                    for (NSInteger minute = 0; minute < 60; ++minute)
                    {
                        NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
                        
                        dateComponents.calendar = self.calendar;
                        dateComponents.year     = year;
                        dateComponents.month    = month;
                        dateComponents.day      = day;
                        dateComponents.hour     = hour;
                        dateComponents.minute   = minute;
                        
                        NSDate* date = [dateComponents date];
                        
                        nextMoment = [enumerator nextObject];
                        
                        XCTAssertEqualObjects(nextMoment, date);
                    }
                }
            }
        }
    }
}

- (void)testEnumeratingConstantDayOfWeek
{
    //  TODO: Add support to Schedule for Day of Week
//    NSString*       cronExpression = @"A * * * * 1";    //  Every Monday
//    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
//    NSDate*         nextMoment     = nil;
//    
//    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-05 00:00"]];
//    
//    nextMoment = [enumerator nextObject];
//    XCTAssertEqualObjects(nextMoment, [self.dateFormatter dateFromString:@"2014-01-06 00:00"]);
}

- (void)testEnumeratingDayOfWeekList
{
    
}

- (void)testEnumeratingDayOfWeekRange
{
    
}

- (void)testEnumeratingMinutesAndHours
{
    NSString*       cronExpression = @"A 5 10 * * *";
    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
    NSDate*         nextMoment     = nil;
    
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
    for (NSInteger year = 2014; year < 2016; ++year)
    {
        for (NSInteger month = 1; month < 13; ++month)
        {
            for (NSInteger day = 1; day < 32; ++day)
            {
                NSInteger           hour           = 10;
                NSInteger           minute         = 5;
                NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
                
                dateComponents.calendar = self.calendar;
                dateComponents.year     = year;
                dateComponents.month    = month;
                dateComponents.day      = day;
                dateComponents.hour     = hour;
                dateComponents.minute   = minute;
                
                NSDate* date = [dateComponents date];
                
                nextMoment = [enumerator nextObject];
                
                XCTAssertEqualObjects(nextMoment, date);
            }
        }
    }
}

- (void)testEnumeratingMinutesHoursAndDay
{
    NSString*       cronExpression = @"A 5 10 20 * *";
    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
    NSDate*         nextMoment     = nil;
    
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
    for (NSInteger year = 2014; year < 2016; ++year)
    {
        for (NSInteger month = 1; month < 13; ++month)
        {
            NSInteger           day            = 20;
            NSInteger           hour           = 10;
            NSInteger           minute         = 5;
            NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
            
            dateComponents.calendar = self.calendar;
            dateComponents.year     = year;
            dateComponents.month    = month;
            dateComponents.day      = day;
            dateComponents.hour     = hour;
            dateComponents.minute   = minute;
            
            NSDate* date = [dateComponents date];
            
            nextMoment = [enumerator nextObject];
            
            XCTAssertEqualObjects(nextMoment, date);
        }
    }
}

- (void)testEnumeratingMinutesHoursDayAndMonth
{
    NSString*       cronExpression = @"A 5 10 20 9 *";
    APCSchedule*    schedule       = [[APCSchedule alloc] initWithExpression:cronExpression timeZero:0];
    NSDate*         nextMoment     = nil;
    
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
    for (NSInteger year = 2014; year < 2016; ++year)
    {
        NSInteger           month          = 9;
        NSInteger           day            = 20;
        NSInteger           hour           = 10;
        NSInteger           minute         = 5;
        NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
        
        dateComponents.calendar = self.calendar;
        dateComponents.year     = year;
        dateComponents.month    = month;
        dateComponents.day      = day;
        dateComponents.hour     = hour;
        dateComponents.minute   = minute;
        
        NSDate* date = [dateComponents date];
        
        nextMoment = [enumerator nextObject];
        
        XCTAssertEqualObjects(nextMoment, date);
    }
}

- (void)testEnumeratingMinutesHourDayMonthsAndDayOfWeek
{
    
}

@end
