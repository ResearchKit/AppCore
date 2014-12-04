//
//  APHScoring.h
//  CardioHealth
//
//  Created by Farhan Ahmed on 10/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <HealthKit/HealthKit.h>
#import "APCLineGraphView.h"

@interface APCScoring : NSEnumerator <APCLineGraphViewDataSource>

- (instancetype)initWithHealthKitQuantityType:(HKQuantityType *)quantityType
                                         unit: (HKUnit *) unit
                                 numberOfDays:(NSUInteger)numberOfDays;

- (instancetype)initWithHealthKitQuantityType:(HKQuantityType *)quantityType
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
