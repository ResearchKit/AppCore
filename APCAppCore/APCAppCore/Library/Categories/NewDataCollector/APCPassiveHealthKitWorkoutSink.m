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
    
    __weak typeof(self) weakSelf = self;
    [quantitySamples enumerateObjectsUsingBlock: ^(id quantitySample, NSUInteger __unused idx, BOOL * __unused stop) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf processUpdatesFromHealthKitForSampleType:quantitySample];
        
    }];
}

- (void) didRecieveUpdatedValueFromHealthKitCollector:(id)quantitySample {
    
    [self processUpdatesFromHealthKitForSampleType:quantitySample];
}


/**********************************************************************/
#pragma mark - Helper Methods
/**********************************************************************/


- (void) processUpdatesFromHealthKitForSampleType:(id)quantitySample {
    __weak typeof(self) weakSelf = self;
    [self.healthKitCollectorQueue addOperationWithBlock:^{
        __typeof(self) strongSelf = weakSelf;
        HKWorkout*  sample                      = (HKWorkout*)quantitySample;
        
        NSString*   startDateTimeStamp          = [sample.startDate toStringInISO8601Format];
        NSString*   endDateTimeStamp            = [sample.endDate toStringInISO8601Format];
        NSString*   healthKitType               = sample.sampleType.identifier;
        
        NSString*   activityType                = [strongSelf workoutActivityTypeStringRepresentation:sample.workoutActivityType];

        double      energyConsumedValue         = [sample.totalEnergyBurned doubleValueForUnit:[HKUnit kilocalorieUnit]];
        NSString*   energyConsumed              = [NSString stringWithFormat:@"%f", energyConsumedValue];
        NSString*   energyUnit                  = [HKUnit kilocalorieUnit].description;
        
        double      totalDistanceConsumedValue  = [sample.totalDistance doubleValueForUnit:[HKUnit meterUnit]];
        NSString*   totalDistance               = [NSString stringWithFormat:@"%f", totalDistanceConsumedValue];
        NSString*   distanceUnit                = [HKUnit meterUnit].description;

        NSString*   quantitySource              = sample.source.name;
        
        NSString *  metaData                    = [self convertDictionaryToString: [sample.metadata mutableCopy]];
        
        NSString *  stringToWrite               = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
                                                   startDateTimeStamp,
                                                   endDateTimeStamp,
                                                   healthKitType,
                                                   activityType,
                                                   totalDistance,
                                                   distanceUnit,
                                                   energyConsumed,
                                                   energyUnit,
                                                   quantitySource,
                                                   metaData];
        
        //Write to file
        [APCPassiveDataSink createOrAppendString:stringToWrite
                                          toFile:[strongSelf.folder stringByAppendingPathComponent:kCSVFilename]];
        
        [strongSelf checkIfDataNeedsToBeFlushed];
        
    }];
}

- (NSString*)workoutActivityTypeStringRepresentation:(int)num
{
    
    NSDictionary* activityEvents =
  @{
    @(1)    : @"HKWorkoutActivityTypeAmericanFootball",
    @(2)    : @"HKWorkoutActivityTypeArchery",
    @(3)    : @"HKWorkoutActivityTypeAustralianFootball",
    @(4)    : @"HKWorkoutActivityTypeBadminton",
    @(5)    : @"HKWorkoutActivityTypeBaseball",
    @(6)    : @"HKWorkoutActivityTypeBasketball",
    @(7)    : @"HKWorkoutActivityTypeBowling",
    @(8)    : @"HKWorkoutActivityTypeBoxing",
    @(9)    : @"HKWorkoutActivityTypeClimbing",
    @(10)   : @"HKWorkoutActivityTypeCricket",
    @(11)   : @"HKWorkoutActivityTypeCrossTraining", // Any mix of cardio and/or strength and/or flexibility
    @(12)   : @"HKWorkoutActivityTypeCurling",
    @(13)   : @"HKWorkoutActivityTypeCycling",
    @(14)   : @"HKWorkoutActivityTypeDance",
    @(15)   : @"HKWorkoutActivityTypeDanceInspiredTraining", // Pilates, Barre, Feldenkrais, etc.
    @(16)   : @"HKWorkoutActivityTypeElliptical",
    @(17)   : @"HKWorkoutActivityTypeEquestrianSports", // Polo, Horse Racing, Horse Riding, etc.
    @(18)   : @"HKWorkoutActivityTypeFencing",
    @(19)   : @"HKWorkoutActivityTypeFishing",
    @(20)   : @"HKWorkoutActivityTypeFunctionalStrengthTraining", // Primarily free weights and/or body weight and/or accessories
    @(21)   : @"HKWorkoutActivityTypeGolf",
    @(22)   : @"HKWorkoutActivityTypeGymnastics",
    @(23)   : @"HKWorkoutActivityTypeHandball",
    @(24)   : @"HKWorkoutActivityTypeHiking",
    @(25)   : @"HKWorkoutActivityTypeHockey", // Ice Hockey, Field Hockey, etc.
    @(26)   : @"HKWorkoutActivityTypeHunting",
    @(27)   : @"HKWorkoutActivityTypeLacrosse",
    @(28)   : @"HKWorkoutActivityTypeMartialArts",
    @(29)   : @"HKWorkoutActivityTypeMindAndBody", // Tai chi, meditation, etc.
    @(30)   : @"HKWorkoutActivityTypeMixedMetabolicCardioTraining", // Any mix of cardio-focused exercises
    @(31)   : @"HKWorkoutActivityTypePaddleSports", // Canoeing, Kayaking, Outrigger, Stand Up Paddle Board, etc.
    @(32)   : @"HKWorkoutActivityTypePlay", // Dodge Ball, Hopscotch, Tetherball, Jungle Gym, etc.
    @(33)   : @"HKWorkoutActivityTypePreparationAndRecovery", // Foam rolling, stretching, etc.
    @(34)   : @"HKWorkoutActivityTypeRacquetball",
    @(35)   : @"HKWorkoutActivityTypeRowing",
    @(36)   : @"HKWorkoutActivityTypeRugby",
    @(37)   : @"HKWorkoutActivityTypeRunning",
    @(38)   : @"HKWorkoutActivityTypeSailing",
    @(39)   : @"HKWorkoutActivityTypeSkatingSports", // Ice Skating, Speed Skating, Inline Skating, Skateboarding, etc.
    @(40)   : @"HKWorkoutActivityTypeSnowSports", // Skiing, Snowboarding, Cross-Country Skiing, etc.
    @(41)   : @"HKWorkoutActivityTypeSoccer",
    @(42)   : @"HKWorkoutActivityTypeSoftball",
    @(43)   : @"HKWorkoutActivityTypeSquash",
    @(44)   : @"HKWorkoutActivityTypeStairClimbing",
    @(45)   : @"HKWorkoutActivityTypeSurfingSports", // Traditional Surfing, Kite Surfing, Wind Surfing, etc.
    @(46)   : @"HKWorkoutActivityTypeSwimming",
    @(47)   : @"HKWorkoutActivityTypeTableTennis",
    @(48)   : @"HKWorkoutActivityTypeTennis",
    @(49)   : @"HKWorkoutActivityTypeTrackAndField", // Shot Put, Javelin, Pole Vaulting, etc.
    @(50)   : @"HKWorkoutActivityTypeTraditionalStrengthTraining", // Primarily machines and/or free weights
    @(51)   : @"HKWorkoutActivityTypeVolleyball",
    @(52)   : @"HKWorkoutActivityTypeWalking",
    @(53)   : @"HKWorkoutActivityTypeWaterFitness",
    @(54)   : @"HKWorkoutActivityTypeWaterPolo",
    @(55)   : @"HKWorkoutActivityTypeWaterSports", // Water Skiing, Wake Boarding, etc.
    @(56)   : @"HKWorkoutActivityTypeWrestling",
    @(57)   : @"HKWorkoutActivityTypeYoga",
    @(3000) : @"HKWorkoutActivityTypeOther"
    };
    
    return [activityEvents objectForKey:@(num)];
}

- (NSString*) convertDictionaryToString:(NSMutableDictionary*) dict
{
    NSError* error;
    NSDictionary* tempDict = [dict copy]; // get Dictionary from mutable Dictionary
    //giving error as it takes dic, array,etc only. not custom object.
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:tempDict
                                                       options:0 error:&error];
    NSString* nsJson=  [[NSString alloc] initWithData:jsonData
                                             encoding:NSUTF8StringEncoding];
    return nsJson;
}

@end
