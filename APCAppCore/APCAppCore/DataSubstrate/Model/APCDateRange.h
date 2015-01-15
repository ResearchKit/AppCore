//
//  APCTimeRange.h
//  APCAppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, APCDateRangeComparison) {
    kAPCDateRangeComparisonSameRange,
    kAPCDateRangeComparisonWithinRange,
    kAPCDateRangeComparisonOutOfRange
};

@interface APCDateRange : NSObject

@property (nonatomic, strong) NSDate * startDate;
@property (nonatomic, strong) NSDate * endDate;

- (instancetype) initWithStartDate: (NSDate*) startDate endDate: (NSDate*) endDate;
- (void) adjustEndDateToEndofDay;
- (APCDateRangeComparison) compare: (APCDateRange*) range;

@end
