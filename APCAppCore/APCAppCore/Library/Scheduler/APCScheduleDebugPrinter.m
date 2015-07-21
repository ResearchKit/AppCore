//
//  APCScheduleDebugPrinter.m
//  APCAppCore
//
//  Copyright (c) 2015, Apple Inc. All rights reserved. 
//  
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//  
//  1.  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  
//  2.  Redistributions in binary form must reproduce the above copyright notice, 
//  this list of conditions and the following disclaimer in the documentation and/or 
//  other materials provided with the distribution. 
//  
//  3.  Neither the name of the copyright holder(s) nor the names of any contributors 
//  may be used to endorse or promote products derived from this software without 
//  specific prior written permission. No license is granted to the trademarks of 
//  the copyright holders even if such marks are included in this software. 
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
//

#import "APCScheduleDebugPrinter.h"
#import "APCSchedule+AddOn.h"
#import "APCConstants.h"
#import "APCTask+AddOn.h"

/*
 Date-formatting tools we use when debug-printing the schedules.
 */
static NSString * const kAPCDebugDateFormat                 = @"EEE yyyy-MM-dd HH:mm zzz";
static NSString * const kAPCDebugDateFormatWithMilliseconds = @"EEE yyyy-MM-dd HH:mm.ss.SSS zzz";
static NSDateFormatter  *debugDateFormatter                 = nil;
static NSDateFormatter  *debugDateFormatterWithMilliseconds = nil;

@implementation APCScheduleDebugPrinter

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
    debugDateFormatter = [NSDateFormatter new];
    debugDateFormatter.dateFormat = kAPCDebugDateFormat;
    debugDateFormatter.timeZone = [NSTimeZone localTimeZone];

    debugDateFormatterWithMilliseconds = [NSDateFormatter new];
    debugDateFormatterWithMilliseconds.dateFormat = kAPCDebugDateFormatWithMilliseconds;
    debugDateFormatterWithMilliseconds.timeZone = [NSTimeZone localTimeZone];
}

- (void) printSetOfSchedules: (NSSet *) schedules
           intoMutableString: (NSMutableString *) printout
                   withLabel: (NSString *) label
{
    /*
     -printArray always alphabetizes the array, so we can safely
     send it the results of this -allObjects call.
     */
    [self printArrayOfSchedules: schedules.allObjects
                      withLabel: label
              intoMutableString: printout];
}

- (void) printArrayOfSchedules: (NSArray *) schedules
             intoMutableString: (NSMutableString *) printout
                     withLabel: (NSString *) label
{
    [self printArrayOfSchedules: schedules
                      withLabel: label
              intoMutableString: printout];
}

- (void) printArrayOfSchedules: (NSArray *) schedules
                     withLabel: (NSString *) label
             intoMutableString: (NSMutableString *) printout
{
    [printout appendFormat: @"%@ (%d schedule%@):\n", label, (int) schedules.count, schedules.count == 1 ? @"" : @"s"];

    NSUInteger patternWidth = 0;
    NSUInteger delayWidth = 0;
    NSUInteger expirationWidth = 0;
    NSUInteger sourceWidth = 0;
    NSUInteger startDateWidth = 0;
    NSUInteger endDateWidth = 0;
    NSUInteger effectiveStartDateWidth = 0;
    NSUInteger effectiveEndDateWidth = 0;
    NSUInteger titleWidth = 0;
    NSUInteger intervalWidth = 0;
    NSUInteger timeListWidth = 0;
    NSUInteger longestTitleIllPrint = 35;
    NSUInteger taskIdWidth = 0;
    NSUInteger oneTimeStringWidth = 0;

    if (schedules.count == 0)
    {
        [printout appendString: @"-  (none)\n"];
    }

    else
    {
        /*
         We can't get to our managed-object category methods during
         migration.  This class method lets us get around that.
         */
        schedules = [APCSchedule sortSchedules: schedules];

        for (APCSchedule *schedule in schedules)
        {
            NSString *source = [NSStringFromAPCScheduleSourceAsNumber (schedule.scheduleSource) substringFromIndex: @"APCScheduleSource".length];

            /*
             We don't seem to be able to get to Objective-C categories during
             a database migration.  These methods let us work around that.
             */
            NSString *title                   = [self firstTaskTitleForSchedule: schedule];
            NSString *taskId                  = [self firstTaskIdForSchedule: schedule];
            NSString *isOneTimeScheduleString = [self isOneTimeScheduleStringForSchedule: schedule];

            patternWidth            = MAX (patternWidth,            schedule.scheduleString.length);
            delayWidth              = MAX (delayWidth,              schedule.delay.length);
            expirationWidth         = MAX (expirationWidth,         schedule.expires.length);
            sourceWidth             = MAX (sourceWidth,             source.length);
            startDateWidth          = MAX (startDateWidth,          [self stringFromDate: schedule.startsOn].length);
            endDateWidth            = MAX (endDateWidth,            [self stringFromDate: schedule.endsOn].length);
            effectiveStartDateWidth = MAX (effectiveStartDateWidth, [self stringFromDate: schedule.effectiveStartDate].length);
            effectiveEndDateWidth   = MAX (effectiveEndDateWidth,   [self stringFromDate: schedule.effectiveEndDate].length);
            titleWidth              = MAX (titleWidth,              title.length);
            intervalWidth           = MAX (intervalWidth,           schedule.interval.length);
            timeListWidth           = MAX (timeListWidth,           schedule.timesOfDay.length);
            taskIdWidth             = MAX (taskIdWidth,             taskId.length);
            oneTimeStringWidth      = MAX (oneTimeStringWidth,      isOneTimeScheduleString.length);
        }

        titleWidth = MIN (titleWidth, longestTitleIllPrint);

        for (APCSchedule *schedule in schedules)
        {
            NSString *source = [NSStringFromAPCScheduleSourceAsNumber (schedule.scheduleSource) substringFromIndex: @"APCScheduleSource".length];

            /*
             We don't seem to be able to get to Objective-C categories during
             a database migration.  These methods let us work around that.
             */
            NSString *title                   = [self firstTaskTitleForSchedule: schedule];
            NSString *taskId                  = [self firstTaskIdForSchedule: schedule];
            NSString *isOneTimeScheduleString = [self isOneTimeScheduleStringForSchedule: schedule];

            if (title.length > longestTitleIllPrint)
            {
                title = [NSString stringWithFormat: @"%@...", [title substringToIndex: longestTitleIllPrint - 3]];
            }

            [printout appendFormat: @"-  %-*s | real: %-*s to %-*s | effective: %-*s to %-*s | once: %-*s | cron: %-*s | intvl: %-*s @ %-*s | delay: %-*s  expire: %-*s | %-*s | %-*s\n",
             (int) sourceWidth,             [self safePrintableString: source],
             (int) startDateWidth,          [self safePrintableString: [self stringFromDate: schedule.startsOn]],
             (int) endDateWidth,            [self safePrintableString: [self stringFromDate: schedule.endsOn]],
             (int) effectiveStartDateWidth, [self safePrintableString: [self stringFromDate: schedule.effectiveStartDate]],
             (int) effectiveEndDateWidth,   [self safePrintableString: [self stringFromDate: schedule.effectiveEndDate]],
             (int) oneTimeStringWidth,      [self safePrintableString: isOneTimeScheduleString],
             (int) patternWidth,            [self safePrintableString: schedule.scheduleString],
             (int) intervalWidth,           [self safePrintableString: schedule.interval],
             (int) timeListWidth,           [self safePrintableString: schedule.timesOfDay],
             (int) delayWidth,              [self safePrintableString: schedule.delay],
             (int) expirationWidth,         [self safePrintableString: schedule.expires],
             (int) taskIdWidth,             [self safePrintableString: taskId],
             (int) titleWidth,              [self safePrintableString: title]
             ];
        }
    }

    [printout appendString: @"\n"];
}



// ---------------------------------------------------------
#pragma mark - Handling the fact that Categories are missing during CoreData migration
// ---------------------------------------------------------

/*
 For some reason, we can't get to the APCSchedule+AddOn
 category during a database migration.  These methods let
 us work around that fact.  They depend on
 
 -  [schedule respondsToSelector: @selector (firstTaskTitle)]
 
 because that's reliable symptom of the problem:  during
 migration, we can't get to that category method, but
 during normal operation of the app, we can.
 */

- (BOOL) weCanAccessCategoryMethodsForThisSchedule: (APCSchedule *) schedule
{
    BOOL result = [schedule respondsToSelector: @selector (firstTaskTitle)];
    return result;
}

- (NSString *) firstTaskTitleForSchedule: (APCSchedule *) schedule
{
    NSString * result = ([self weCanAccessCategoryMethodsForThisSchedule: schedule] ?
                         [schedule firstTaskTitle] :
                         ((APCTask *) schedule.tasks.anyObject).taskTitle);
    return result;
}

- (NSString *) firstTaskIdForSchedule: (APCSchedule *) schedule
{
    NSString * result = ([self weCanAccessCategoryMethodsForThisSchedule: schedule] ?
                         [schedule firstTaskId] :
                         ((APCTask *) schedule.tasks.anyObject).taskID);
    return result;
}

- (NSString *) isOneTimeScheduleStringForSchedule: (APCSchedule *) schedule
{
    BOOL isOneTimeSchedule = ([self weCanAccessCategoryMethodsForThisSchedule: schedule] ?
                              schedule.isOneTimeSchedule :
                              [schedule.scheduleType isEqualToString: kAPCScheduleTypeValueOneTimeSchedule]);

    NSString *result = isOneTimeSchedule ? @"YES" : @"NO";
    return result;
}



// ---------------------------------------------------------
#pragma mark - Utilities
// ---------------------------------------------------------

- (NSString *) stringFromDate: (NSDate *) date
{
    return [[self class] stringFromDate: date];
}

+ (NSString *) stringFromDate: (NSDate *) date
{
    NSString *result = @"(null)";

    if (date != nil)
    {
        result = [debugDateFormatter stringFromDate: date];
    }

    return result;
}

+ (NSString *) stringWithMillisecondsFromDate: (NSDate *) date
{
    NSString *result = @"(null)";

    if (date != nil)
    {
        result = [debugDateFormatterWithMilliseconds stringFromDate: date];
    }

    return result;
}

- (NSString *) stringsFromArrayOfDates: (NSArray *) arrayOfDates
{
    NSMutableString *result = [NSMutableString new];

    for (id maybeDate in arrayOfDates)
    {
        if (result.length > 0)
        {
            [result appendString: @" | "];
        }

        if ([maybeDate isKindOfClass: [NSDate class]])
        {
            [result appendString: [debugDateFormatter stringFromDate: maybeDate]];
        }
        else
        {
            [result appendString: [NSString stringWithFormat: @"%@", maybeDate]];
        }
    }

    if (result.length == 0)
    {
        [result appendString: @"(none)"];
    }

    return result;
}

- (const char *) safePrintableString: (NSString *) inputString
{
    NSString *result = @"---";

    if (inputString.length)
    {
        result = inputString;
    }
    
    return result.UTF8String;
}

@end
