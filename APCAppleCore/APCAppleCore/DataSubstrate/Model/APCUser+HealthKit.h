//
//  APCUser+HealthKit.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCUser.h"

@interface APCUser (HealthKit)

+ (NSArray *) sexTypesInStringValue;

+ (HKBiologicalSex) sexTypeFromStringValue:(NSString *)stringValue;

+ (NSString *) stringValueFromSexType:(HKBiologicalSex)sexType;

+ (NSUInteger) stringIndexFromSexType:(HKBiologicalSex)sexType;


+ (NSArray *) bloodTypeInStringValues;

+ (HKBloodType) bloodTypeFromStringValue:(NSString *)stringValue;


+ (NSArray *) medicalConditions;

+ (NSArray *) medications;

+ (NSArray *) heights;

@end
