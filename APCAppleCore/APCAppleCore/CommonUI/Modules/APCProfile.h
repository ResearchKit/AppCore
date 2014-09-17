//
//  Profile.h
//  Profile
//
//  Created by Karthik Keyan on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import Foundation;
@import CoreGraphics;

@import HealthKit;

@interface APCProfile : NSObject

@property (nonatomic, copy) NSString *firstName;

@property (nonatomic, copy) NSString *lastName;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, copy) NSString *email;

@property (nonatomic, copy) NSString *password;

@property (nonatomic, strong) NSDate *dateOfBirth;

@property (nonatomic, copy) NSString *medicalCondition;

@property (nonatomic, copy) NSString *medication;

@property (nonatomic, strong) NSNumber *weight;

@property (nonatomic, strong) NSString *height;

@property (nonatomic, strong) NSDate *sleepTime;

@property (nonatomic, strong) NSDate *wakeUpTime;

@property (nonatomic, readwrite) HKBiologicalSex gender;

@property (nonatomic, readwrite) HKBloodType bloodType;

@end


@interface APCProfile (HealthKit)

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

