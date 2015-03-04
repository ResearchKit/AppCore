//
//  APCTimeRange.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCDateRange.h"
#import "APCAppCore.h"

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
    NSParameterAssert(durationString);
    
    NSTimeInterval delta = [NSDate parseISO8601DurationString: durationString];
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