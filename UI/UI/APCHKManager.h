//
//  HKManager.h
//  UI
//
//  Created by Karthik Keyan on 9/6/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@import HealthKit;

@class APCProfile;

@interface APCHKManager : NSObject

@property (nonatomic, strong) HKHealthStore *store;

/*
 {
 HKCharacteristicType *type = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
 [types addObject:type];
 }
 
 {
 HKCharacteristicType *type = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType];
 [types addObject:type];
 }
 
 {
 HKCharacteristicType *type = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
 [types addObject:type];
 }
 
 {
 HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
 [types addObject:type];
 }
 
 {
 HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
 [types addObject:type];
 }
 */

- (void) authenticate:(void (^)(BOOL granted, NSError *error))completion;

- (void) fillBiologicalInfo:(APCProfile *)profile;

- (void) latestHeight:(void (^)(HKQuantity *quantity, NSError *error))completion;

- (void) latestWeight:(void (^)(HKQuantity *quantity, NSError *error))completion;

@end
