// 
//  APCScheduleTests.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APCScheduleExpression.h"

@interface APCScheduleTests : XCTestCase

@property (nonatomic, strong) NSDateFormatter*  dateFormatter;
@property (nonatomic, strong) NSCalendar*       calendar;

@property (nonatomic, strong) NSArray*   everyYear;
@property (nonatomic, strong) NSArray*   everyMonth;
@property (nonatomic, strong) NSArray*   everyDay;
@property (nonatomic, strong) NSArray*   everyHour;
@property (nonatomic, strong) NSArray*   everyMinute;

@end

NSArray*    NumericSequence(NSInteger begin, NSInteger end)
{
    NSMutableArray* data = [NSMutableArray arrayWithCapacity:end - begin + 1];
    
    for (NSInteger ndx = begin; ndx <= end; ++ndx)
    {
        [data addObject:@(ndx)];
    }
    return [data copy];
}

@implementation APCScheduleTests

- (void)setUp
{
    [super setUp];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-8 * 60 * 60]];

    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    self.everyYear   = NumericSequence(2014, 2017);
    self.everyMonth  = NumericSequence(1, 12);
    self.everyDay    = NumericSequence(1, 31);
    self.everyHour   = NumericSequence(0, 23);
    self.everyMinute = NumericSequence(0, 59);
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)enumerateOverYears:(NSArray*)year
                     month:(NSArray*)month
                       day:(NSArray*)day
                      hour:(NSArray*)hour
                    minute:(NSArray*)minute
       comparingEnumerator:(NSEnumerator*)enumerator
{
    NSDate* nextMoment = nil;
    
    year   = year   ?: self.everyYear;
    month  = month  ?: self.everyMonth;
    day    = day    ?: self.everyDay;
    hour   = hour   ?: self.everyHour;
    minute = minute ?: self.everyMinute;
    
    for (NSNumber* aYear in year)
    {
        for (NSNumber* aMonth in month)
        {
            for (NSNumber* aDay in day)
            {
                for (NSNumber* aHour in hour)
                {
                    for (NSNumber* aMinute in minute)
                    {
                        NSDateComponents*   dateComponents = [[NSDateComponents alloc] init];
                        
                        dateComponents.calendar = self.calendar;
                        dateComponents.year     = aYear.integerValue;
                        dateComponents.month    = aMonth.integerValue;
                        dateComponents.day      = aDay.integerValue;
                        dateComponents.hour     = aHour.integerValue;
                        dateComponents.minute   = aMinute.integerValue;
                        
                        NSDate* date = [dateComponents date];
                        
                        nextMoment = [enumerator nextObject];
                        
                        if ([date isEqualToDate:nextMoment] == NO)
                        {
                            NSLog(@"Year: %@, Month: %@, Day: %@, Hour: %@, Minute: %@", aYear, aMonth, aDay, aHour, aMinute);
                        }
                        
                        XCTAssertEqualObjects(nextMoment, date);
                    }
                }
            }
        }
    }
}

- (void)testEnumerationOfConstantMinutes
{
    NSString*       cronExpression = @"A 5 * * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
    [self enumerateOverYears:nil
                       month:nil
                         day:nil
                        hour:nil
                      minute:@[@5]
         comparingEnumerator:enumerator];
}

- (void)testBoundedEnumerationOfConstantMinutes
{
    NSString*       cronExpression    = @"A 5 * * * *";
    APCScheduleExpression*    schedule          = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   boundedEnumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]
                                                               endingAtTime:[self.dateFormatter dateFromString:@"2014-01-01 23:59"]];

    [self enumerateOverYears:@[@2014]
                       month:@[@1]
                         day:@[@1]
                        hour:nil
                      minute:@[@5]
         comparingEnumerator:boundedEnumerator];
    XCTAssertNil([boundedEnumerator nextObject]);
}

- (void)testEnumeratingMinuteList
{
    NSString*       cronExpression = @"A 15,30,45 * * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
    [self enumerateOverYears:nil
                       month:nil
                         day:nil
                        hour:nil
                      minute:@[@15, @30, @45]
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingMinuteRange
{
    NSString*       cronExpression = @"A 15-30 * * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
    [self enumerateOverYears:nil
                       month:nil
                         day:nil
                        hour:nil
                      minute:NumericSequence(15, 30)
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingMinuteStep
{
    NSString*       cronExpression = @"A */15 * * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
    [self enumerateOverYears:nil
                       month:nil
                         day:nil
                        hour:nil
                      minute:@[@0, @15, @30, @45]
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingMinuteRangeAndStep
{
    NSString*       cronExpression = @"A 15-30/5 * * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
    [self enumerateOverYears:nil
                       month:nil
                         day:nil
                        hour:nil
                      minute:@[@15, @20,@25, @30]
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingMinuteListedRange
{
    NSString*       cronExpression = @"A 10-12,20-22 * * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
    [self enumerateOverYears:nil
                       month:nil
                         day:nil
                        hour:nil
                      minute:@[@10, @11, @12, @20, @21, @22]
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingConstantHour
{
    NSString*       cronExpression = @"A * 10 * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 08:00"]];
    
    [self enumerateOverYears:nil
                       month:nil
                         day:nil
                        hour:@[@10]
                      minute:nil
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingHourList
{
    NSString*       cronExpression = @"A * 8,12,16 * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 08:00"]];
    
    [self enumerateOverYears:nil
                       month:nil
                         day:nil
                        hour:@[@8, @12, @16]
                      minute:nil
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingHourRange
{
    NSString*       cronExpression = @"A * 8-17 * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 08:00"]];
    
    [self enumerateOverYears:nil
                       month:nil
                         day:nil
                        hour:NumericSequence(8, 17)
                      minute:nil
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingHourStep
{
    NSString*       cronExpression = @"A * 8/4 * * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 08:00"]];
    
    [self enumerateOverYears:nil
                       month:nil
                         day:nil
                        hour:@[@8, @12, @16, @20]
                      minute:nil
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingConstantDayOfMonth
{
    NSString*       cronExpression = @"A * * 15 * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
    [self enumerateOverYears:nil
                       month:nil
                         day:@[@15]
                        hour:nil
                      minute:nil
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingDayOfMonthList
{
    NSString*       cronExpression = @"A * * 15,30 * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
    [self enumerateOverYears:nil
                       month:nil
                         day:@[@15, @30]
                        hour:nil
                      minute:nil
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingDayOfMonthRange
{
    NSString*       cronExpression = @"A * * 1-14 * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
    [self enumerateOverYears:nil
                       month:nil
                         day:NumericSequence(1, 14)
                        hour:nil
                      minute:nil
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingDayOfMonthStep
{
    NSString*       cronExpression = @"A * * 10/5 * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
    [self enumerateOverYears:nil
                       month:nil
                         day:@[@10, @15, @20, @25, @30]
                        hour:nil
                      minute:nil
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingConstantMonth
{
    NSString*       cronExpression = @"A * * * 4 *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
    [self enumerateOverYears:nil
                       month:@[@4]
                         day:nil
                        hour:nil
                      minute:nil
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingMonthList
{
    NSString*       cronExpression = @"A * * * 2,4,6,8 *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];

    [self enumerateOverYears:nil
                       month:@[@2, @4, @6, @8]
                         day:nil
                        hour:nil
                      minute:nil
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingMonthRange
{
    NSString*       cronExpression = @"A * * * 6-9 *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
    [self enumerateOverYears:nil
                       month:NumericSequence(6, 9)
                         day:nil
                        hour:nil
                      minute:nil
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingMonthStep
{
    NSString*       cronExpression = @"A * * * 4/2 *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:00"]];
    
    [self enumerateOverYears:nil
                       month:@[@4, @6, @8, @10, @12]
                         day:nil
                        hour:nil
                      minute:nil
         comparingEnumerator:enumerator];
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
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
    [self enumerateOverYears:nil
                       month:nil
                         day:nil
                        hour:@[@10]
                      minute:@[@5]
         comparingEnumerator:enumerator];
}

- (void)testEnumeratingMinutesHoursAndDay
{
    NSString*       cronExpression = @"A 5 10 20 * *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
    [self enumerateOverYears:nil month:nil day:@[@20] hour:@[@10] minute:@[@5] comparingEnumerator:enumerator];
}

- (void)testEnumeratingMinutesHoursDayAndMonth
{
    NSString*       cronExpression = @"A 5 10 20 9 *";
    APCScheduleExpression*    schedule       = [[APCScheduleExpression alloc] initWithExpression:cronExpression timeZero:0];
    NSEnumerator*   enumerator     = [schedule enumeratorBeginningAtTime:[self.dateFormatter dateFromString:@"2014-01-01 00:01"]];
    
    [self enumerateOverYears:nil month:@[@9] day:@[@20] hour:@[@10] minute:@[@5] comparingEnumerator:enumerator];
}

- (void)testEnumeratingMinutesHourDayMonthsAndDayOfWeek
{
    
}

@end
