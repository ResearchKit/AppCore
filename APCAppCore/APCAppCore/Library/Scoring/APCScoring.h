//
//  APHScoring.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <HealthKit/HealthKit.h>
#import "APCLineGraphView.h"
#import "APCDiscreteGraphView.h"

extern NSString *const kDatasetDateKey;
extern NSString *const kDatasetValueKey;

typedef NS_ENUM(NSUInteger, APHTimelineGroups)
{
    APHTimelineGroupDay = 0,
    APHTimelineGroupWeek,
    APHTimelineGroupMonth,
    APHTimelineGroupYear,
    APHTimelineGroupForInsights
};

@interface APCScoring : NSEnumerator <APCLineGraphViewDataSource, APCDiscreteGraphViewDataSource>

@property (nonatomic) CGFloat customMaximumPoint;
@property (nonatomic) CGFloat customMinimumPoint;

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
                  latestOnly:(BOOL)latestOnly;

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
- (NSArray *)allObjects;

@end