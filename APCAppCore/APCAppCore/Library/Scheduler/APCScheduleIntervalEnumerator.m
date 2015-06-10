//
//  APCScheduleIntervalEnumerator.m
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

#import "APCScheduleIntervalEnumerator.h"
#import "APCConstants.h"
#import "APCSchedule+AddOn.h"
#import "NSDate+Helper.h"


@interface APCScheduleIntervalEnumerator ()
- (instancetype) init NS_DESIGNATED_INITIALIZER;
@property (readonly) BOOL hasTimesOfDay;
@property (readonly) BOOL hasEndDate;
@property (readonly) BOOL hasPassedEndDate;
@property (nonatomic, strong) APCSchedule *schedule;
@property (nonatomic, assign) BOOL hasBeenCalledOnce;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSString *iso8601TimeInterval;
@property (nonatomic, strong) NSString *timesOfDayOriginalString;
@property (nonatomic, strong) NSArray *timesOfDayInSeconds;
@property (nonatomic, assign) NSInteger previousTimeOfDayIndex;
@property (nonatomic, strong) NSDate *previousEnumeratedDate;
@end

@implementation APCScheduleIntervalEnumerator

- (instancetype) init
{
    self = [super init];

    if (self)
    {
        _schedule                   = nil;
        _startDate                  = nil;
        _endDate                    = nil;
        _iso8601TimeInterval        = nil;
        _timesOfDayOriginalString   = nil;
        _timesOfDayInSeconds        = nil;
        _hasBeenCalledOnce          = NO;
        _previousEnumeratedDate     = nil;
        _previousTimeOfDayIndex     = 0;
    }

    return self;
}

- (instancetype) initWithSchedule: (APCSchedule *) schedule
                        startDate: (NSDate *) startDate
                          endDate: (NSDate *) endDate
{
    self = [self init];

    if (self)
    {
        _schedule                   = schedule;
        _iso8601TimeInterval        = schedule.interval;
        _startDate                  = startDate;
        _endDate                    = endDate;
        _timesOfDayOriginalString   = schedule.timesOfDay;
        _timesOfDayInSeconds        = [self deserializedArrayOfDurationsSinceMidnightFromISO8601TimesOfDayString: _timesOfDayOriginalString];
    }

    return self;
}

- (BOOL) hasTimesOfDay
{
    return self.timesOfDayInSeconds.count > 0;
}

- (BOOL) hasEndDate
{
    return self.endDate != nil;
}

- (BOOL) hasPassedEndDate
{
    BOOL result = (self.previousEnumeratedDate != nil &&
                   self.endDate != nil &&
                   [self.previousEnumeratedDate isLaterThanDate: self.endDate] );

    return result;
}

- (NSDate *) nextObject
{
    NSDate *result = [self nextScheduledDate];

    return result;
}

- (NSDate *) nextScheduledDate
{
    NSDate *computedDate = nil;
    NSUInteger computedIndexOfTimeOfDay = 0;
    NSNumber *selectedTimeAsNumber = nil;
    NSTimeInterval selectedTime = 0;

    if (self.hasPassedEndDate)
    {
        computedDate = nil;
    }

    else if (self.hasBeenCalledOnce == NO)
    {
        computedDate = self.startDate.startOfDay;
        self.previousEnumeratedDate = computedDate;

        if (self.hasTimesOfDay == NO)
        {
            // Done with this computation.
        }
        else
        {
            computedIndexOfTimeOfDay = 0;
            self.previousTimeOfDayIndex = computedIndexOfTimeOfDay;

            selectedTimeAsNumber = self.timesOfDayInSeconds [computedIndexOfTimeOfDay];
            selectedTime = selectedTimeAsNumber.integerValue;
            computedDate = [computedDate dateByAddingTimeInterval: selectedTime];
        }

        self.hasBeenCalledOnce = YES;
    }

    else
    {
        if (self.hasTimesOfDay == NO)
        {
            computedDate = [self.previousEnumeratedDate dateByAddingISO8601Duration: self.iso8601TimeInterval];
            self.previousEnumeratedDate = computedDate;
        }
        else
        {
            computedIndexOfTimeOfDay = self.previousTimeOfDayIndex;

            if (computedIndexOfTimeOfDay < self.timesOfDayInSeconds.count - 1)
            {
                computedIndexOfTimeOfDay ++;
                self.previousTimeOfDayIndex = computedIndexOfTimeOfDay;

                selectedTimeAsNumber = self.timesOfDayInSeconds [computedIndexOfTimeOfDay];
                selectedTime = selectedTimeAsNumber.integerValue;

                computedDate = self.previousEnumeratedDate;
                computedDate = [computedDate dateByAddingTimeInterval: selectedTime];
            }
            else
            {
                computedDate = [self.previousEnumeratedDate dateByAddingISO8601Duration: self.iso8601TimeInterval];
                self.previousEnumeratedDate = computedDate;

                computedIndexOfTimeOfDay = 0;
                self.previousTimeOfDayIndex = computedIndexOfTimeOfDay;

                selectedTimeAsNumber = self.timesOfDayInSeconds [computedIndexOfTimeOfDay];
                selectedTime = selectedTimeAsNumber.integerValue;

                computedDate = [computedDate dateByAddingTimeInterval: selectedTime];
            }
        }
    }

    // See if the calculations we just did pushed us past the end date.
    if (self.hasPassedEndDate)
    {
        computedDate = nil;
    }

    return computedDate;
}

/**
 This method is very similar to a method in APCScheduler.m.
 */
- (NSArray *) deserializedArrayOfDurationsSinceMidnightFromISO8601TimesOfDayString: (NSString *) serializedTimesOfDayString
{
    NSMutableArray *result = nil;

    if (serializedTimesOfDayString.length > 0)
    {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.locale = [NSLocale localeWithLocaleIdentifier: kAPCDateFormatLocaleEN_US_POSIX];

        NSArray *legalFormats = @[@"H",
                                  @"HH",
                                  @"HH:mm",
                                  @"HH:mm:SS",
                                  @"HH:mm:SS.sss"
                                  ];

        result = [NSMutableArray new];

        NSArray *iso8601TimeStrings = [serializedTimesOfDayString componentsSeparatedByString: @"|"];

        for (NSString *iso8601TimeString in iso8601TimeStrings)
        {
            NSDate *date = nil;

            for (NSString *format in legalFormats)
            {
                formatter.dateFormat = format;
                date = [formatter dateFromString: iso8601TimeString];

                if (date != nil)
                {
                    break;
                }
            }

            if (date != nil)
            {
                NSDate *midnightOnThatDate = date.startOfDay;
                NSTimeInterval secondsSinceMidnight = [date timeIntervalSinceDate: midnightOnThatDate];
                [result addObject: @(secondsSinceMidnight)];
            }
        }
    }

    if (result.count == 0)
    {
        result = nil;
    }

    else
    {
        // The result array is a bunch of NSNumbers.
        // Sort them from midnight-before to midnight-after
        // using -[NSNumber compare:].
        [result sortUsingSelector: @selector (compare:)];
    }
    
    return result;
}

@end
