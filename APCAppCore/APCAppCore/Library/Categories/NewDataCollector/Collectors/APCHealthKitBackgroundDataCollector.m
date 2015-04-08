//
//  APCHealthKitCumulativeQuantityTypeDataBridge.m
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

#import "APCHealthKitBackgroundDataCollector.h"
#import "APCAppCore.h"

static NSString* const kLastUsedTimeKey = @"APCPassiveDataCollectorLastTerminatedTime";

@interface APCHealthKitBackgroundDataCollector()

@property (strong, nonatomic)   HKObserverQuery*    observerQuery;
@property (strong, nonatomic)   HKSampleQuery*      sampleQuery;

@end

@implementation APCHealthKitBackgroundDataCollector

- (instancetype) initWithIdentifier: (NSString *) identifier sampleType: (HKSampleType *) type andLimit: (NSUInteger)queryLimit {

    self = [super init];
    
    if (self) {
        
        _identifier     = identifier;
        _sampleType     = type;
        _queryLimit     = queryLimit;
        _healthStore    = [HKHealthStore new];
    }
    
    return self;
}

- (void)start {
    [self observerQueryForSampleType:self.sampleType];
}

- (void)observerQueryForSampleType:(HKSampleType *)sampleType{
    
    NSDate* lastTrackedEndDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUsedTimeKey];
    
    if(lastTrackedEndDate == nil) {
        lastTrackedEndDate = [NSDate date];
    }
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:lastTrackedEndDate endDate:[NSDate date] options:0];
    
    __weak typeof(self) weakSelf = self;
    
    self.sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery __unused *query, NSArray *results, NSError *error) {

        if (error) {
            APCLogError2(error);
        } else {
            
            __typeof(self) strongSelf = weakSelf;
            __weak typeof(self) weakSelf = strongSelf;
            
            
            // Send the initial results
            if (results)
            {
                [strongSelf.delegate didRecieveArrayOfValuesFromHealthKitCollector:results];
            }
        
            strongSelf.observerQuery = [[HKObserverQuery alloc] initWithSampleType:sampleType
                                                                         predicate:nil
                                                                     updateHandler:^(HKObserverQuery __unused *query,
                                                                                     HKObserverQueryCompletionHandler completionHandler,
                                                                                     NSError *error)
                                        {
                                            
                                            if (error) {
                                                APCLogError2(error);
                                            } else {
                                                __typeof(self) strongSelf = weakSelf;
                                                
                                                [strongSelf sampleQueryWithType:strongSelf.sampleType andLimit:strongSelf.queryLimit];
                                                
                                                // If there's a completion block execute it.
                                                if (completionHandler) {
                                                    completionHandler();
                                                }
                                            }
                                        }];
            
            [strongSelf.healthStore executeQuery:strongSelf.observerQuery];
        }
    }];
    
    [self.healthStore executeQuery:self.sampleQuery];
}

- (void)stop {
    [self.healthStore stopQuery:self.sampleQuery];
    [self.healthStore stopQuery:self.observerQuery];
}


- (void) sampleQueryWithType: (HKSampleType *)sampleType andLimit:(NSUInteger) limit{
    
    __weak __typeof(self) weakSelf = self;
    
    NSSortDescriptor *sortByLatest = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType
                                                                 predicate:nil
                                                                     limit:limit
                                                           sortDescriptors:@[sortByLatest]
                                                            resultsHandler:^(HKSampleQuery __unused *query, NSArray *results, NSError *error)
                                  {
                                      __typeof(self) strongSelf = weakSelf;
                                      
                                      [strongSelf notifyListenersWithResults:results withError:error];
                                      
                                  }];
    
    [self.healthStore executeQuery:sampleQuery];
    
}

- (void) notifyListenersWithResults: (NSArray *) results withError: (NSError *) error  {
    
    if (results)
    {
        id sampleKind = results.firstObject;

        if (sampleKind) {

            if ([sampleKind isKindOfClass:[HKCategorySample class]])
            {
                HKCategorySample *categorySample = (HKCategorySample *)sampleKind;


                APCLogDebug(@"HK Update received for: %@ - %d", categorySample.categoryType.identifier, categorySample.value);

            }
            else if ([sampleKind isKindOfClass:[HKWorkout class]])
            {
                HKWorkout* workoutSample = (HKWorkout*)sampleKind;
                APCLogDebug(@"HK Update received for: %@ - %d", workoutSample.sampleType.identifier, workoutSample.metadata);
            }
            else
            {
                HKQuantitySample *quantitySample = (HKQuantitySample *)sampleKind;
                APCLogDebug(@"HK Update received for: %@ - %@", quantitySample.quantityType.identifier, quantitySample.quantity);

            }

            [[NSNotificationCenter defaultCenter] postNotificationName:APCHealthKitObserverQueryUpdateForSampleTypeNotification
                                                                object:sampleKind];
            
            if ([self.delegate respondsToSelector:@selector(didRecieveUpdatedValueFromHealthKitCollector:)])
            {
                [self.delegate didRecieveUpdatedValueFromHealthKitCollector:sampleKind];
            }
        }
    }
    else
    {
        APCLogError2(error);
    }
}




@end
