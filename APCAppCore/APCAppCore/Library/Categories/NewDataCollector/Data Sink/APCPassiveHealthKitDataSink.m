//
//  APCFileManagerForCollector.m
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

#import "APCPassiveHealthKitDataSink.h"
#import "APCAppCore.h"

static NSString *const kCollectorFolder = @"newCollector";
static NSString *const kUploadFolder = @"upload";

static NSString *const kIdentifierKey = @"identifier";
static NSString *const kStartDateKey = @"startDate";
static NSString *const kEndDateKey = @"endDate";

static NSString *const kInfoFilename = @"info.json";
static NSString *const kCSVFilename  = @"data.csv";


@implementation APCPassiveHealthKitDataSink

/**********************************************************************/
#pragma mark - APCCollectorProtocol Delegate Methods
/**********************************************************************/
- (void) didRecieveArrayOfValuesFromHealthKitCollector:(NSArray*)quantitySamples {
    
    [quantitySamples enumerateObjectsUsingBlock: ^(id quantitySample, NSUInteger __unused idx, BOOL * __unused stop) {
        
        [self processUpdatesFromHealthKitForSampleType:quantitySample];
        
    }];
}

- (void) didRecieveUpdatedValueFromHealthKitCollector:(id)quantitySample {
    
    [self processUpdatesFromHealthKitForSampleType:quantitySample];
}



- (void)processUpdatesFromHealthKitForSampleType:(id)quantitySample {
    [self.healthKitCollectorQueue addOperationWithBlock:^{
        NSString *dateTimeStamp = [[NSDate date] toStringInISO8601Format];
        NSString *healthKitType = nil;
        NSString *quantityValue = nil;
        NSString *quantitySource = nil;
        
        if ([quantitySample isKindOfClass:[HKCategorySample class]]) {
            HKCategorySample *catSample = (HKCategorySample *)quantitySample;
            healthKitType = catSample.categoryType.identifier;
            quantityValue = [NSString stringWithFormat:@"%ld", (long)catSample.value];
            
            // Get the difference in seconds between the start and end date for the sample
            NSDateComponents *secondsSpentInBedOrAsleep = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond
                                                                                          fromDate:catSample.startDate
                                                                                            toDate:catSample.endDate
                                                                                           options:NSCalendarWrapComponents];
            if (catSample.value == HKCategoryValueSleepAnalysisInBed) {
                quantityValue = [NSString stringWithFormat:@"%ld,seconds in bed", (long)secondsSpentInBedOrAsleep.second];
            } else if (catSample.value == HKCategoryValueSleepAnalysisAsleep) {
                quantityValue = [NSString stringWithFormat:@"%ld,seconds asleep", (long)secondsSpentInBedOrAsleep.second];
            }
        }
        else if ([quantitySample isKindOfClass:[HKWorkout class]])
        {
            HKWorkout *qtySample = (HKWorkout *)quantitySample;
            healthKitType = qtySample.sampleType.identifier;
            quantityValue = [NSString stringWithFormat:@"%lu, %@, %@",(unsigned long)qtySample.workoutActivityType, qtySample.totalDistance, qtySample.totalEnergyBurned];
            quantitySource = qtySample.source.name;
        }
        else
        {
            HKQuantitySample *qtySample = (HKQuantitySample *)quantitySample;
            healthKitType = qtySample.quantityType.identifier;
            quantityValue = [NSString stringWithFormat:@"%@", qtySample.quantity];
            quantityValue = [quantityValue stringByReplacingOccurrencesOfString:@" " withString:@","];
            quantitySource = qtySample.source.name;
            
            if (quantitySource == nil)
            {
                quantitySource = @"";
            }
        }
        
        NSString *stringToWrite = [NSString stringWithFormat:@"%@,%@,%@,%@\n", dateTimeStamp, healthKitType, quantityValue, quantitySource];
        
        [APCPassiveDataSink createOrAppendString:stringToWrite
                                               toFile:[self.folder stringByAppendingPathComponent:kCSVFilename]];

        [self checkIfDataNeedsToBeFlushed];
        
    }];
}




@end
