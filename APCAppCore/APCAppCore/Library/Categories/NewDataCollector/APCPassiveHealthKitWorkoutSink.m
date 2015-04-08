//
//  APCPassiveHealthKitWorkoutSink.m
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

#import "APCPassiveHealthKitWorkoutSink.h"
#import "APCAppCore.h"

static NSString *const kCollectorFolder = @"newCollector";
static NSString *const kUploadFolder = @"upload";

static NSString *const kIdentifierKey = @"identifier";
static NSString *const kStartDateKey = @"startDate";
static NSString *const kEndDateKey = @"endDate";

static NSString *const kInfoFilename = @"info.json";
static NSString *const kCSVFilename  = @"data.csv";

@implementation APCPassiveHealthKitWorkoutSink

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


/**********************************************************************/
#pragma mark - Helper Methods
/**********************************************************************/


- (void) processUpdatesFromHealthKitForSampleType:(id)quantitySample {
    [self.healthKitCollectorQueue addOperationWithBlock:^{
        HKWorkout*  sample                      = (HKWorkout*)quantitySample;
        
        NSString*   dateTimeStamp               = [[NSDate date] toStringInISO8601Format];
        NSString*   healthKitType               = sample.sampleType.identifier;

        double      energyConsumedValue         = [sample.totalEnergyBurned doubleValueForUnit:[HKUnit kilocalorieUnit]];
        NSString*   energyConsumed              = [NSString stringWithFormat:@"%f", energyConsumedValue];
        NSString*   energyUnit                  = [HKUnit kilocalorieUnit].description;
        
        double      totalDistanceConsumedValue  = [sample.totalDistance doubleValueForUnit:[HKUnit meterUnit]];
        NSString*   totalDistance               = [NSString stringWithFormat:@"%f", totalDistanceConsumedValue];
        NSString*   distanceUnit                = [HKUnit meterUnit].description;

        NSString*   quantitySource              = sample.source.name;
        
        NSString *  stringToWrite               = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@\n",
                                                   dateTimeStamp,
                                                   healthKitType,
                                                   totalDistance,
                                                   distanceUnit,
                                                   energyConsumed,
                                                   energyUnit,
                                                   quantitySource];
        
        //Write to file
        [APCPassiveDataSink createOrAppendString:stringToWrite
                                          toFile:[self.folder stringByAppendingPathComponent:kCSVFilename]];
        
        [self checkIfDataNeedsToBeFlushed];
        
    }];
}




@end
