// 
//  APCDateRange.m 
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
 
#import "APCDateRange.h"
#import "NSDate+Helper.h"

@implementation APCDateRange

- (instancetype) initWithStartDate: (NSDate*) startDate endDate: (NSDate*) endDate {
    
    NSParameterAssert(startDate);
    NSParameterAssert(endDate);
    
    self = [super init];
    if (self) {
        self.startDate = startDate;
        self.endDate = endDate;
    }
    return self;
}

- (instancetype) initWithStartDate:(NSDate *)startDate durationString: (NSString*) durationString {
    
    NSParameterAssert(startDate);

    NSTimeInterval delta = 0;

    if (durationString.length > 0)
    {
        delta = [NSDate timeIntervalByAddingISO8601Duration: durationString
                                                     toDate: startDate];
    }
    
    self = [self initWithStartDate:startDate durationInterval:delta];
    return self;
}

- (instancetype) initWithStartDate:(NSDate *)startDate durationInterval: (NSTimeInterval) durationInterval {
    NSParameterAssert(startDate);
    
    self = [self initWithStartDate:startDate endDate:[startDate dateByAddingTimeInterval:durationInterval]];
    return self;
}

- (APCDateRangeComparison) compare: (APCDateRange*) range {
    APCDateRangeComparison retValue;
    
    NSTimeInterval selfStartDate = [self.startDate timeIntervalSinceReferenceDate];
    NSTimeInterval selfEndDate = [self.endDate timeIntervalSinceReferenceDate];
    NSTimeInterval rangeStartDate = [range.startDate timeIntervalSinceReferenceDate];
    NSTimeInterval rangeEndDate = [range.endDate timeIntervalSinceReferenceDate];
    
    if (selfStartDate == rangeStartDate && selfEndDate == rangeEndDate) {
        retValue = kAPCDateRangeComparisonSameRange;
    }
    else if (selfStartDate < rangeStartDate && selfEndDate < rangeEndDate) {
        retValue = kAPCDateRangeComparisonOutOfRange;
    }
    else if (selfStartDate > rangeStartDate && selfEndDate > rangeEndDate) {
        retValue = kAPCDateRangeComparisonOutOfRange;
    }
    else {
        retValue = kAPCDateRangeComparisonWithinRange;
    }
    
    return retValue;
}

- (NSString *)description {
    NSDateFormatter * _dateFormatter = [NSDateFormatter new];
    [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    return [NSString stringWithFormat:@"Start Date: [%@] End Date: [%@]", [_dateFormatter stringFromDate:self.startDate], [_dateFormatter stringFromDate:self.endDate]];
}

/*********************************************************************************/
#pragma mark - Convenience Methods
/*********************************************************************************/

+ (instancetype) todayRange {
    NSDate * startDate = [NSDate todayAtMidnight];
    NSDate * endDate = [NSDate endOfDay:startDate];
    return [[self alloc] initWithStartDate:startDate endDate:endDate];
}

+ (instancetype) tomorrowRange {
    NSDate * startDate = [NSDate tomorrowAtMidnight];
    NSDate * endDate = [NSDate endOfDay:startDate];
    return [[self alloc] initWithStartDate:startDate endDate:endDate];
}

+ (instancetype) yesterdayRange {
    NSDate * startDate = [NSDate yesterdayAtMidnight];
    NSDate * endDate = [NSDate endOfDay:startDate];
    return [[self alloc] initWithStartDate:startDate endDate:endDate];
}

@end
