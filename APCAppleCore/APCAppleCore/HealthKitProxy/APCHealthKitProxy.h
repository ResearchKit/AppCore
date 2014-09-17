//
//  HKManager.h
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/6/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import Foundation;

@import HealthKit;

@class APCProfile;

@interface APCHealthKitProxy : NSObject

@property (nonatomic, strong) HKHealthStore *store;

- (void) authenticate:(void (^)(BOOL granted, NSError *error))completion;

- (void) fillBiologicalInfo:(APCProfile *)profile;

- (void) latestHeight:(void (^)(HKQuantity *quantity, NSError *error))completion;

- (void) latestWeight:(void (^)(HKQuantity *quantity, NSError *error))completion;

@end
