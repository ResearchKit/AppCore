//
//  HKHealthStore+APCExtensions.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import HealthKit;

@interface HKHealthStore (APCExtensions)

// Fetches the single most recent quantity of the specified type.
- (void)mostRecentQuantitySampleOfType:(HKQuantityType *)quantityType predicate:(NSPredicate *)predicate completion:(void (^)(HKQuantity *mostRecentQuantity, NSError *error))completion;

@end
