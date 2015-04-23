//
//  APCDemographicUploader.m
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

#import "APCDemographicUploader.h"

#import "APCAppCore.h"
#import "APCAllSetTableViewCell.h"
#import "APCDataArchiverAndUploader.h"

static  NSString  *kTaskIdentifierKey              = @"NonIdentifiableDemographicsTask";

static  NSString  *kPatientInformationKey          = @"item";
static  NSString  *kNonIdentifiableDemographicsKey = @"NonIdentifiableDemographics";

static  NSString  *kPatientBirthDateKey            = @"patientBirthDate";
static  NSString  *kPatientBiologicalSexKey        = @"patientBiologicalSex";
static  NSString  *kPatientHeightInchesKey         = @"patientHeightInches";
static  NSString  *kPatientWeightPoundsKey         = @"patientWeightPounds";
static  NSString  *kPatientWakeUpTimeKey           = @"patientWakeUpTime";
static  NSString  *kPatientGoSleepTimeKey          = @"patientGoSleepTime";

@implementation APCDemographicUploader

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
    }
    return  self;
}

- (void)uploadNonIdentifiableDemographicData
{
    APCUser  *user = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
    
    NSMutableDictionary  *demographics = [NSMutableDictionary dictionary];
    
    [demographics setObject:kNonIdentifiableDemographicsKey forKey:kPatientInformationKey];
    
    NSDate  *sleepTime = user.sleepTime;
    if (sleepTime == nil) {
        [demographics setObject:[NSNull null] forKey:kPatientGoSleepTimeKey];
    } else {
        [demographics setObject:sleepTime forKey:kPatientGoSleepTimeKey];
    }
    
    NSDate  *wakeUpTime = user.wakeUpTime;
    if (wakeUpTime == nil) {
        [demographics setObject:[NSNull null] forKey:kPatientWakeUpTimeKey];
    } else {
        [demographics setObject:wakeUpTime forKey:kPatientWakeUpTimeKey];
    }
    
    NSDate  *birthDate = user.birthDate;
    if (birthDate == nil) {
        [demographics setObject:[NSNull null] forKey:kPatientBirthDateKey];
    } else {
        [demographics setObject:birthDate forKey:kPatientBirthDateKey];
    }
    
    HKBiologicalSex  biologicalSex = user.biologicalSex;
    NSString  *biologicalSexString = [APCUser stringValueFromSexType:biologicalSex];
    if (biologicalSexString == nil) {
        [demographics setObject:[NSNull null] forKey:kPatientBiologicalSexKey];
    } else {
        [demographics setObject:biologicalSexString forKey:kPatientBiologicalSexKey];
    }
    
    HKQuantity  *height = user.height;
    double  heightInInches = [APCUser heightInInches:height];
    int  klass = fpclassify(heightInInches);
    if ((klass == FP_INFINITE) || (klass == FP_NAN) || (klass == FP_ZERO)) {
        [demographics setObject:@(0) forKey:kPatientHeightInchesKey];
    } else {
        [demographics setObject:@(heightInInches) forKey:kPatientHeightInchesKey];
    }
    
    HKQuantity  *weight = user.weight;
    double  weightInPounds = [APCUser weightInPounds:weight];
    int  klarse = fpclassify(weightInPounds);
    if ((klarse == FP_INFINITE) || (klass == FP_NAN) || (klass == FP_ZERO)) {
        [demographics setObject:@(0) forKey:kPatientWeightPoundsKey];
    } else {
        [demographics setObject:@(weightInPounds) forKey:kPatientWeightPoundsKey];
    }
    
    [APCDataArchiverAndUploader uploadDictionary:demographics
                                withTaskIdentifier:kTaskIdentifierKey
                                andTaskRunUuid:nil];

}

@end
