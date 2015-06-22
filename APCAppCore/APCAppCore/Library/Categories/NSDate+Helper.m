// 
//  NSDate+Helper.m 
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
 
#import "NSDate+Helper.h"
#import "APCConstants.h"
#import "NSDateComponents+Helper.h"


NSString * const NSDateDefaultDateFormat   = @"MMM dd, yyyy";
NSString * const DateFormatISO8601DateOnly = @"yyyy-MM-dd";

/**
 Sage requires our dates to be in "ISO 8601" format,
 like this:

 2015-02-25T16:42:11+00:00

 Got the rules from http://en.wikipedia.org/wiki/ISO_8601
 Date-formatting rules from http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
 */
static NSString * const kDateFormatISO8601 = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";

/**
 The possible ways we might receive an ISO 8601 date.
 Filled in during +initialize.
 */
static NSArray * kAPCDateFormatISO8601InputOptions = nil;



/**
 Makes some of the method calls below more explicit than
 using a Boolean to indicate "backwards" or "forwards."
 */
typedef enum : NSUInteger {
    APCDateDirectionForwards,
    APCDateDirectionBackwards,
}   APCDateDirection;



@implementation NSDate (Helper)

/**
 Set global, static values the first time anyone calls this class.

 By definition, this method is called once per class, in a thread-safe
 way, the first time the class is sent a message -- basically, the first
 time we refer to the class.  That means we can use this to set up stuff
 that applies to all objects (instances) of this class.

 Documentation:  See +initialize in the NSObject Class Reference.  Currently, that's here:
 https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSObject_Class/index.html#//apple_ref/occ/clm/NSObject/initialize
 */
+ (void) initialize
{
    /*
     The list of formats we'll use when trying to interpret
     an ISO 8601 date string.  Add any others you need.

     For more options, see http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
     */
    kAPCDateFormatISO8601InputOptions = @[@"yyyy-MM-dd",
                                          @"yyyy-MM-dd'T'HH:mm",
                                          @"yyyy-MM-dd'T'HH:mmZZZZZ",
                                          @"yyyy-MM-dd'T'HH:mm:ssZZZZZ",
                                          @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
                                          ];
}



// ---------------------------------------------------------
#pragma mark - Strings and Printouts
// ---------------------------------------------------------

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
    [formatter setLocale: [[NSLocale alloc] initWithLocaleIdentifier: kAPCDateFormatLocaleEN_US_POSIX]];

    NSString *result = [formatter stringFromDate: self];
    return result;
}

+ (NSDate *) dateWithISO8601String: (NSString *) iso8601string
{
    NSDate *result = nil;

    if (iso8601string.length)
    {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setLocale: [[NSLocale alloc] initWithLocaleIdentifier: kAPCDateFormatLocaleEN_US_POSIX]];

        for (NSUInteger formatIndex = 0; formatIndex < kAPCDateFormatISO8601InputOptions.count; formatIndex ++)
        {
            NSString *dateFormat = kAPCDateFormatISO8601InputOptions [formatIndex];
            [formatter setDateFormat: dateFormat];
            result = [formatter dateFromString: iso8601string];

            if (result)
            {
                break;
            }
        }
    }

    return result;
}



// ---------------------------------------------------------
#pragma mark - Uncategorized utility functions and "computed properties"
// ---------------------------------------------------------

+ (NSUInteger)ageFromDateOfBirth:(NSDate *)dateOfBirth
{
    NSUInteger  answer = 0;
    if (dateOfBirth != nil) {
        NSDateComponents  *differences = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                                    fromDate:dateOfBirth
                                                                    toDate:[NSDate date]
                                                                    options:0];
        answer = [differences year];
    }
    return  answer;
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

- (instancetype) dayBefore
{
    return [self dateByAddingDays: -1];
}

- (instancetype) dayAfter
{
    return [self dateByAddingDays: 1];
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

+(instancetype)priorSundayAtMidnightFromDate:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    [components setWeekday:1];//Sunday
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

- (BOOL) isSameDayAsDate: (NSDate *) otherDate
{
    BOOL result = ([self isLaterThanOrEqualToDate: otherDate.startOfDay] &&
                   [self isEarlierOrEqualToDate: otherDate.endOfDay]);

    return result;
}



// ---------------------------------------------------------
#pragma mark - ISO 8601 conversion
// ---------------------------------------------------------

+ (NSTimeInterval) timeIntervalByAddingISO8601Duration: (NSString *) duration
                                                toDate: (NSDate *) startDate
                                        addInDirection: (APCDateDirection) dateDirection
{
    float characterIndex = 0, years = 0, months = 0, weeks = 0, days = 0, hours = 0, minutes = 0, seconds = 0;
    BOOL timeStarted = NO;
    
    while (characterIndex < duration.length)
    {
        NSString *substring = [duration substringWithRange: NSMakeRange (characterIndex, duration.length - characterIndex)];

        characterIndex++;
        
        if ([substring hasPrefix: @"P"])
        {
            // Expected prefix to everything.  Keep going.
        }
        
        else if ([substring hasPrefix: @"T"])
        {
            timeStarted = YES;
        }

        else
        {
            NSScanner *scanner = [NSScanner scannerWithString: substring];
            float value = 0;

            if ([scanner scanFloat: & value])
            {
                characterIndex  += [scanner scanLocation] - 1;
                substring        = [duration substringWithRange: NSMakeRange (characterIndex, duration.length - characterIndex)];
                characterIndex  ++;

                if      ([substring hasPrefix: @"Y"])                  { years   = value; }
                else if ([substring hasPrefix: @"M"] && ! timeStarted) { months  = value; }
                else if ([substring hasPrefix: @"W"])                  { weeks   = value; }
                else if ([substring hasPrefix: @"D"])                  { days    = value; }
                else if ([substring hasPrefix: @"H"])                  { hours   = value; }
                else if ([substring hasPrefix: @"M"] && timeStarted)   { minutes = value; }
                else if ([substring hasPrefix: @"S"])                  { seconds = value; }
            }
        }
    }

    if (dateDirection == APCDateDirectionForwards)
    {
        // Actually, that's the default.
    }
    else
    {
        seconds = - seconds;
        minutes = - minutes;
        hours   = - hours;
        days    = - days;
        weeks   = - weeks;
        months  = - months;
        years   = - years;
    }

    NSTimeInterval elapsedTimeInterval = 0;

    if ((months != 0 || years != 0) && startDate != nil)
    {
        NSDateComponents *components = [NSDateComponents components: @[ @(NSCalendarUnitDay), @(NSCalendarUnitMonth), @(NSCalendarUnitYear) ]
                                           inGregorianLocalFromDate: startDate];

        components.month    += months;
        components.year     += years;
        components.day      += days;
        components.hour     += hours;
        components.minute   += minutes;
        components.second   += seconds;
        NSDate *newDate     = components.date;
        elapsedTimeInterval = [newDate timeIntervalSinceDate: startDate];
    }
    else
    {
        /*
         If we get here, either we don't have a startDate --
         so we don't know where to start counting, which means
         we'll use 30 days for "days per month" and 365 for
         "days per year" -- or the user didn't specify months
         and/or years, which means those will zero out.
         */
        elapsedTimeInterval = years * 365 + months * 30 + weeks * 7 + days;
        elapsedTimeInterval = (elapsedTimeInterval * 24) + hours;
        elapsedTimeInterval = (elapsedTimeInterval * 60) + minutes;
        elapsedTimeInterval = (elapsedTimeInterval * 60) + seconds;
    }

    return elapsedTimeInterval;
}

+ (NSTimeInterval) timeIntervalByAddingISO8601Duration: (NSString *) duration
                                                toDate: (NSDate *) date
{
    NSTimeInterval result = [self timeIntervalByAddingISO8601Duration: duration
                                                               toDate: date
                                                       addInDirection: APCDateDirectionForwards];
    return result;
}

+ (NSTimeInterval) timeIntervalBySubtractingISO8601Duration: (NSString *) duration
                                                   fromDate: (NSDate *) date
{
    NSTimeInterval result = [self timeIntervalByAddingISO8601Duration: duration
                                                               toDate: date
                                                       addInDirection: APCDateDirectionBackwards];
    return result;
}

- (NSTimeInterval) timeIntervalByAddingISO8601Duration: (NSString *) duration
{
    NSTimeInterval time = [[self class] timeIntervalByAddingISO8601Duration: duration toDate: self];

    return time;
}

- (NSTimeInterval) timeIntervalBySubtractingISO8601Duration: (NSString *) duration
{
    NSTimeInterval time = [[self class] timeIntervalBySubtractingISO8601Duration: duration fromDate: self];

    return time;
}

+ (NSDate *) dateByAddingISO8601Duration: (NSString *) duration
                                  toDate: (NSDate *) date
                          addInDirection: (APCDateDirection) dateDirection
{
    NSTimeInterval timeToAdd = [self timeIntervalByAddingISO8601Duration: duration
                                                                  toDate: date
                                                          addInDirection: dateDirection];

    if (date == nil)
    {
        date = [NSDate date];
    }

    NSDate *result = [date dateByAddingTimeInterval: timeToAdd];

    return result;
}

+ (NSDate *) dateByAddingISO8601Duration: (NSString *) duration
                                  toDate: (NSDate *) date
{
    NSDate *result = [self dateByAddingISO8601Duration: duration
                                                toDate: date
                                        addInDirection: APCDateDirectionForwards];
    return result;
}

+ (NSDate *) dateBySubtractingISO8601Duration: (NSString *) duration
                                     fromDate: (NSDate *) date
{
    NSDate *result = [self dateByAddingISO8601Duration: duration
                                                toDate: date
                                        addInDirection: APCDateDirectionBackwards];
    return result;
}

- (NSDate *) dateByAddingISO8601Duration: (NSString *) durationString
{
    NSDate *result = [[self class] dateByAddingISO8601Duration: durationString toDate: self];

    return result;
}

- (NSDate *) dateBySubtractingISO8601Duration: (NSString *) durationString
{
    NSDate *result = [[self class] dateBySubtractingISO8601Duration: durationString fromDate: self];

    return result;
}


@end
