// 
//  APCUser+UserData.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCUser.h"

@interface APCUser (UserData)

/* Biologcal Sex */
+ (NSArray *) sexTypesInStringValue;

+ (HKBiologicalSex)sexTypeForIndex:(NSInteger)index;

+ (HKBiologicalSex) sexTypeFromStringValue:(NSString *)stringValue;

+ (NSString *) stringValueFromSexType:(HKBiologicalSex)sexType;

+ (NSUInteger) stringIndexFromSexType:(HKBiologicalSex)sexType;


/*Blood Type */
+ (NSArray *) bloodTypeInStringValues;

+ (HKBloodType) bloodTypeFromStringValue:(NSString *)stringValue;


+ (NSArray *) medicalConditions;

+ (NSArray *) medications;

/* Height */
+ (NSArray *) heights;

+ (double)heightInInchesForSelectedIndices:(NSArray *)selectedIndices;

+ (double)heightInInches:(HKQuantity *)height;

+ (double)heightInMeters:(HKQuantity *)height;


+ (double)weightInPounds:(HKQuantity *)weight;

+ (double)weightInKilograms:(HKQuantity *)weight;

@end
