// 
//  HKHealthStore+APCExtensions.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
@import HealthKit;

@interface HKHealthStore (APCExtensions)

// Fetches the single most recent quantity of the specified type.
- (void)mostRecentQuantitySampleOfType:(HKQuantityType *)quantityType predicate:(NSPredicate *)predicate completion:(void (^)(HKQuantity *mostRecentQuantity, NSError *error))completion;

@end
