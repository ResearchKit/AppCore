//
//  APCTimeRange.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
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
- (instancetype) initWithStartDate:(NSDate *)startDate durationString: (NSString*) durationString;
- (instancetype) initWithStartDate:(NSDate *)startDate durationInterval: (NSTimeInterval) durationInterval;

- (APCDateRangeComparison) compare: (APCDateRange*) range;

+ (instancetype) todayRange;
+ (instancetype) tomorrowRange;
+ (instancetype) yesterdayRange;

@end
