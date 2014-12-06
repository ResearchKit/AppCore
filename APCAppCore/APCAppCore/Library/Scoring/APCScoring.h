//
//  APHScoring.h
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <HealthKit/HealthKit.h>
#import "APCLineGraphView.h"

@interface APCScoring : NSEnumerator <APCLineGraphViewDataSource>

- (instancetype)initWithHealthKitQuantityType:(HKQuantityType *)quantityType
                                         unit:(HKUnit *)unit
                                 numberOfDays:(NSUInteger)numberOfDays;

- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSUInteger)numberOfDays
                    valueKey:(NSString *)valueKey
                     dataKey:(NSString *)dataKey;

- (NSNumber *)minimumDataPoint;
- (NSNumber *)maximumDataPoint;
- (NSNumber *)averageDataPoint;
- (id)nextObject;

@end
