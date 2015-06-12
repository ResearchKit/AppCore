//
//  APCActivitiesViewSection.m
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

#import "APCActivitiesViewSection.h"
#import "NSDate+Helper.h"
#import "APCTaskGroup.h"

static NSDateFormatter *headerViewDateFormatterDebugging        = nil;
static NSDateFormatter *headerViewDateFormatterToday            = nil;

static NSString * const kAPCSectionTitleToday                   = @"Today";
static NSString * const kAPCSectionTitleYesterday               = @"Yesterday";
static NSString * const kAPCSectionTitleTomorrow                = @"Tomorrow";
static NSString * const kAPCSectionTitleKeepGoing               = @"Keep Going!";
static NSString * const kAPCSectionSubtitleKeepGoing            = @"Try one of these extra activities\nto enhance your experience in your study.";
static NSString * const kAPCSectionSubtitleToday                = @"To start an activity, select from the list below.";
static NSString * const kAPCSectionSubtitleYesterday            = @"Below are your incomplete tasks from yesterday. These are for reference only.";
static NSString * const kAPCSectionHeaderDateFormatDebugging    = @"eeee, MMMM d, yyyy";
static NSString * const kAPCSectionHeaderDateFormatToday        = @"eeee, MMMM d";


@interface APCActivitiesViewSection ()

- (instancetype) init NS_DESIGNATED_INITIALIZER;

@property (readonly) NSDate *yesterday;
@property (readonly) NSDate *today;
@property (readonly) NSDate *tomorrow;
@property (readonly) NSDate *myDateRoundedToMidnight;
@end


@implementation APCActivitiesViewSection

+ (void) initialize
{
    if (headerViewDateFormatterDebugging == nil)
    {
        headerViewDateFormatterDebugging = [NSDateFormatter new];
        headerViewDateFormatterDebugging.timeZone = [NSTimeZone localTimeZone];
        headerViewDateFormatterDebugging.dateFormat = kAPCSectionHeaderDateFormatDebugging;

        headerViewDateFormatterToday = [NSDateFormatter new];
        headerViewDateFormatterToday.timeZone = [NSTimeZone localTimeZone];
        headerViewDateFormatterToday.dateFormat = kAPCSectionHeaderDateFormatToday;
    }
}

- (instancetype) init
{
    self = [super init];

    if (self)
    {
        _date = nil;
        _isKeepGoingSection = NO;
        _presumedSystemDate = nil;
        _taskGroups = nil;
    }

    return self;
}

- (instancetype) initWithDate: (NSDate *) date
                        tasks: (NSArray *) arrayOfTaskGroupObjects
       usingDateForSystemDate: (NSDate *) potentiallyFakeSystemDate
{
    self = [self init];

    if (self)
    {
        _date = date;
        _taskGroups = arrayOfTaskGroupObjects;
        _presumedSystemDate = potentiallyFakeSystemDate;
    }

    return self;
}

- (instancetype) initAsKeepGoingSectionWithTasks: (NSArray *) arrayOfTaskGroupObjects
{
    self = [self init];

    if (self)
    {
        _isKeepGoingSection = YES;
        _taskGroups = arrayOfTaskGroupObjects;
    }

    return self;
}

- (NSDate *) today
{
    return self.presumedSystemDate.startOfDay;
}

- (NSDate *) tomorrow
{
    return self.presumedSystemDate.dayAfter.startOfDay;
}

- (NSDate *) yesterday
{
    return self.presumedSystemDate.dayBefore.startOfDay;
}

- (NSDate *) myDateRoundedToMidnight
{
    return self.date.startOfDay;
}

- (BOOL) isTodaySection
{
    BOOL   isToday = [self.myDateRoundedToMidnight isEqualToDate: self.today];
    return isToday;
}

- (BOOL) isYesterdaySection
{
    BOOL   isYesterday = [self.myDateRoundedToMidnight isEqualToDate: self.yesterday];
    return isYesterday;
}

- (BOOL) isEmpty
{
    return self.taskGroups.count == 0;
}

- (NSString *) title
{
    NSString *todayTitle = [NSString stringWithFormat: @"%@, %@", kAPCSectionTitleToday, [headerViewDateFormatterToday stringFromDate: self.myDateRoundedToMidnight]];

    NSString *result = (self.isKeepGoingSection                                      ? kAPCSectionTitleKeepGoing :
                        [self.myDateRoundedToMidnight isEqualToDate: self.today]     ? todayTitle :
                        [self.myDateRoundedToMidnight isEqualToDate: self.yesterday] ? kAPCSectionTitleYesterday :
                        [self.myDateRoundedToMidnight isEqualToDate: self.tomorrow]  ? kAPCSectionTitleTomorrow :
                        [headerViewDateFormatterDebugging stringFromDate: self.myDateRoundedToMidnight]
                        );

    return result;
}

- (NSString *) subtitle
{
    NSString *result = (self.isKeepGoingSection ? kAPCSectionSubtitleKeepGoing :
                        [self.myDateRoundedToMidnight isEqualToDate: self.today] ? kAPCSectionSubtitleToday :
                        [self.myDateRoundedToMidnight isEqualToDate: self.yesterday] ? kAPCSectionSubtitleYesterday :
                        nil
                        );

    return result;
}

- (void) removeFullyCompletedTasks
{
    /*
     I gotta say, this is pretty cool:  using a "predicate"
     to run a method on every object in the array, based
     on which we can remove elements from the array, using
     a syntax that looks like SQL, kinda, and trusting
     Objective-C to do this efficiently.  Purrrrrrty!
     
     The method we're running on every object in the array
     is -isFullyCompleted.  The objects in the array are
     APCTaskGroups.  Objective-C converts the @(YES) in the
     predicate into the Boolean that's actually returned
     by -isFullyCompleted.
     */
    NSPredicate *filterToRemoveCompletedTasks = [NSPredicate predicateWithFormat: @"%K != %@",
                                                 NSStringFromSelector (@selector (isFullyCompleted)),
                                                 @(YES)];

    NSArray *newListOfTaskGroups = [self.taskGroups filteredArrayUsingPredicate:  filterToRemoveCompletedTasks];

    self.taskGroups = newListOfTaskGroups;
}


@end
