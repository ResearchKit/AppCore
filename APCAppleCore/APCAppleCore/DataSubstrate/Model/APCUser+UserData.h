//
//  APCUser+UserData.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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
