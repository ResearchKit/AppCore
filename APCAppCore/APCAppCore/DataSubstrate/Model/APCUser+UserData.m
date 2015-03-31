// 
//  APCUser+UserData.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCUser+UserData.h"

@implementation APCUser (UserData)

/***************
 Biologial Sex 
 ****************/
+ (NSArray *) sexTypesInStringValue {
    return @[ NSLocalizedString(@"Male", @""), NSLocalizedString(@"Female", @"")];
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

+ (HKBiologicalSex)sexTypeForIndex:(NSInteger)index
{
    HKBiologicalSex sexType;
    
    if (index == 0) {
        sexType = HKBiologicalSexMale;
    } else if (index == 1) {
        sexType = HKBiologicalSexFemale;
    } else{
        sexType = HKBiologicalSexNotSet;
    }
    
    return sexType;
}

+ (NSString *) stringValueFromSexType:(HKBiologicalSex)sexType {
    NSArray *values = [APCUser sexTypesInStringValue];
    
    NSUInteger index = [APCUser stringIndexFromSexType:sexType];

    return (index == NSNotFound)? nil : values[index];
}

+ (NSUInteger) stringIndexFromSexType:(HKBiologicalSex)sexType {
    NSUInteger index = NSNotFound;
    
    if (sexType == HKBiologicalSexMale) {
        index = 0;
    }
    else if (sexType == HKBiologicalSexFemale) {
        index = 1;
    }
    
    return index;
}

/**********
 Blood Type
 ***********/
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

/***********************************
 Medical Conidtions and Medications
 **********************************/

+ (NSArray *) medicalConditions {
    return @[@"Not listed", @"Condition 1" , @"Condition 2"];
}

+ (NSArray *) medications {
    return @[@"Not listed", @"Medication 1" , @"Medication 2"];
}

/*******
 Height
 *******/
+ (NSArray *) heights {
    return @[
             @[@"0'", @"1'", @"2'", @"3'", @"4'", @"5'", @"6'", @"7'", @"8'"],
             @[@"0''", @"1''", @"2''", @"3''", @"4''", @"5''", @"6''", @"7''", @"8''", @"9''", @"10''", @"11''"]
             ];
}

+ (double)heightInInchesForSelectedIndices:(NSArray *)selectedIndices
{
    NSInteger feet = ((NSNumber *)selectedIndices[0]).integerValue;
    NSInteger inches = ((NSNumber *)selectedIndices[1]).integerValue;
    
    double totalInches = (12 * feet) + inches;
    return totalInches;
}

+ (double)heightInInches:(HKQuantity *)height
{
    HKUnit *heightUnit = [HKUnit inchUnit];
    return [height doubleValueForUnit:heightUnit];
}

+ (double)heightInMeters:(HKQuantity *)height
{
    HKUnit *heightUnit = [HKUnit meterUnit];
    return [height doubleValueForUnit:heightUnit];
}

/***************
 Weight
 ****************/

+ (double)weightInPounds:(HKQuantity *)weight
{
    HKUnit *weightUnit = [HKUnit poundUnit];
    return [weight doubleValueForUnit:weightUnit];
}

+ (double)weightInKilograms:(HKQuantity *)weight
{
    HKUnit *weightUnit = [HKUnit gramUnit];
    return [weight doubleValueForUnit:weightUnit];
}


@end
