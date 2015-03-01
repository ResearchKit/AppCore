//
//  APHFitnessAllocation.h
//  MyHeart Counts
//
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCAppCore.h"

extern NSString *const kDataset7DayDateKey;
extern NSString *const kDataset7DayValueKey;
extern NSString *const kDatasetSegmentNameKey;
extern NSString *const kDatasetSegmentColorKey;
extern NSString *const kDatasetSegmentKey;
extern NSString *const kDatasetDateHourKey;
extern NSString *const kSegmentSumKey;
extern NSString *const kSevenDayFitnessStartDateKey;
extern NSString *const APHSevenDayAllocationDataIsReadyNotification;
extern NSString *const APHSevenDayAllocationHealthKitDataIsReadyNotification;

@interface APCFitnessAllocation : NSObject

@property (nonatomic) NSTimeInterval activeSeconds;

- (instancetype)initWithAllocationStartDate:(NSDate *)startDate;
- (NSArray *)todaysAllocation;
- (NSArray *)yesterdaysAllocation;
- (NSArray *)weeksAllocation;
- (void) startDataCollection;

@end
