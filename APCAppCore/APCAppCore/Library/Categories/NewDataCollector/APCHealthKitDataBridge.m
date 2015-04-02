//
//  APCHealthKitDataBridge.m
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

#import "APCHealthKitDataBridge.h"
#import "APCAppCore.h"

@interface APCHealthKitDataBridge()

@end

@implementation APCHealthKitDataBridge

- (instancetype) init {
    
    self = [super init];
    
    if( self )
    {
        _healthStore                = nil;
    }
    
    return self;
}

- (instancetype) initWithIdentifier:(NSString *)identifier andSampleType: (HKSampleType *) sampleType {
    
    self = [self init];
    
    if( self )
    {
        NSParameterAssert(identifier != nil);
        
        _sampleType                 = sampleType;
        _identifier                 = identifier;
    }
    
    return self;
    
}

- (void)observerQueryForSampleType:(HKSampleType *)sampleType {
    
    __weak __typeof(self) weakSelf = self;
    

    APCLogDebug(@"Setting up observer query for sample type %@", sampleType.identifier);
    
    [self.healthStore enableBackgroundDeliveryForType:sampleType
                                                          frequency:HKUpdateFrequencyImmediate
                                                     withCompletion:^(BOOL success, NSError *error)
     {
         
         __typeof(self) strongSelf = weakSelf;
         __weak __typeof(self) weakSelf = strongSelf;
         
         if (success == NO) {
             APCLogError2(error);
         } else {
             HKObserverQuery *observerQuery = [[HKObserverQuery alloc] initWithSampleType:sampleType
                                                                                predicate:nil
                                                                            updateHandler:^(HKObserverQuery __unused *query,
                                                                                            HKObserverQueryCompletionHandler completionHandler,
                                                                                            NSError *error)
                                               {
                                                   
                                                   if (error) {
                                                       APCLogError2(error);
                                                   } else {
                                                       
                                                       [strongSelf sampleQueryWithType:strongSelf.sampleType];
                                                       
                                                       // If there's a completion block execute it.
                                                       if (completionHandler) {
                                                           completionHandler();
                                                       }
                                                   }
                                               }];
             
             [weakSelf.healthStore executeQuery:observerQuery];
         }
     }];
}

- (void) sampleQueryWithType: (HKSampleType *)sampleType {

    __weak __typeof(self) weakSelf = self;
        
    NSSortDescriptor *sortByLatest = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType
                                                                 predicate:nil
                                                                     limit:1
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
        [[NSNotificationCenter defaultCenter] postNotificationName:APCHealthKitObserverQueryUpdateForSampleTypeNotification
                                                            object:results];
        [self.delegate didRecieveUpdatedValue:results];
    }
    else
    {
        APCLogError2(error);
    }
}


@end
