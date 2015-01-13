//
//  APHScoring.h
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <HealthKit/HealthKit.h>
#import "APCLineGraphView.h"

typedef NS_ENUM(NSUInteger, APHTimelineGroups)
{
    APHTimelineGroupDay = 0,
    APHTimelineGroupWeek,
    APHTimelineGroupMonth,
    APHTimelineGroupYear
};

@interface APCScoring : NSEnumerator <APCLineGraphViewDataSource>

- (instancetype)initWithHealthKitQuantityType:(HKQuantityType *)quantityType
                                         unit:(HKUnit *)unit
                                 numberOfDays:(NSInteger)numberOfDays;

- (instancetype)initWithHealthKitQuantityType:(HKQuantityType *)quantityType
                                         unit:(HKUnit *)unit
                                 numberOfDays:(NSInteger)numberOfDays
                                      groupBy:(APHTimelineGroups)groupBy;

- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSInteger)numberOfDays
                    valueKey:(NSString *)valueKey;

- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSInteger)numberOfDays
                    valueKey:(NSString *)valueKey
                     dataKey:(NSString *)dataKey;

- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSInteger)numberOfDays
                    valueKey:(NSString *)valueKey
                     dataKey:(NSString *)dataKey
                     sortKey:(NSString *)sortKey;

- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSInteger)numberOfDays
                    valueKey:(NSString *)valueKey
                     dataKey:(NSString *)dataKey
                     sortKey:(NSString *)sortKey
                  groupBy:(APHTimelineGroups)groupBy;

- (void)updatePeriodForDays:(NSInteger)numberOfDays
                    groupBy:(APHTimelineGroups)groupBy
      withCompletionHandler:(void (^)(void))completion;

- (NSNumber *)minimumDataPoint;
- (NSNumber *)maximumDataPoint;
- (NSNumber *)averageDataPoint;
- (id)nextObject;

@end