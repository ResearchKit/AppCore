//
//  APCUser+HealthKit.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 9/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCUser+HealthKit.h"

@implementation APCUser (HealthKit)


+ (NSArray *) sexTypesInStringValue {
    return @[ NSLocalizedString(@"Male", @""), NSLocalizedString(@"Female", @""), NSLocalizedString(@"Others", @"") ];
}

+ (HKBiologicalSex) sexTypeFromStringValue:(NSString *)stringValue {
    HKBiologicalSex sexType;
    
    if ([stringValue isEqualToString:NSLocalizedString(@"Male", @"")]) {
        sexType = HKBiologicalSexMale;
    }
    else if ([stringValue isEqualToString:NSLocalizedString(@"Female", @"")]) {
        sexType = HKBiologicalSexFemale;
    }
    else {
        sexType = HKBiologicalSexNotSet;
    }
    
    return sexType;
}

+ (NSString *) stringValueFromSexType:(HKBiologicalSex)sexType {
    NSArray *values = [APCUser sexTypesInStringValue];
    
    NSUInteger index = [APCUser stringIndexFromSexType:sexType];
    
    return values[index];
}

+ (NSUInteger) stringIndexFromSexType:(HKBiologicalSex)sexType {
    NSUInteger index;
    
    if (sexType == HKBiologicalSexMale) {
        index = 0;
    }
    else if (sexType == HKBiologicalSexFemale) {
        index = 1;
    }
    else {
        index = 2;
    }
    
    return index;
}



+ (NSArray *) bloodTypeInStringValues {
    return @[@" ", @"A+", @"A-", @"B+", @"B-", @"AB+", @"AB-", @"O+", @"O-"];
}

+ (HKBloodType) bloodTypeFromStringValue:(NSString *)stringValue {
    HKBloodType type = HKBloodTypeNotSet;
    
    if (stringValue.length > 0) {
        type = [[APCUser bloodTypeInStringValues] indexOfObject:stringValue];
    }
    
    return type;
}



+ (NSArray *) medicalConditions {
    return @[@"Not listed", @"Condition 1" , @"Condition 2"];
}

+ (NSArray *) medications {
    return @[@"Not listed", @"Medication 1" , @"Medication 2"];
}

+ (NSArray *) heights {
    return @[
             @[@"1'", @"2'", @"3'", @"4'", @"5'", @"6'", @"7'", @"8'", @"9'", @"10'", @"11'", @"12'"],
             @[@"0''", @"1''", @"2''", @"3''", @"4''", @"5''", @"6''", @"7''", @"8''", @"9''", @"10''", @"11''", @"12''"]
             ];
}

@end
