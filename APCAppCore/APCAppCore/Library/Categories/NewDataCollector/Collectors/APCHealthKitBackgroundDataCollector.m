//
//  APCHealthKitBackgroundDataCollector.m
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

@property (strong, nonatomic)   HKHealthStore*              healthStore;
@property (strong, nonatomic)   HKUnit*                     unit;
@property (strong, nonatomic)   HKSampleType*               sampleType;
@property (strong, nonatomic)   HKObserverQuery*            observerQuery;
@property (strong, nonatomic)   HKSampleQuery*              sampleQuery;

@end

@implementation APCHealthKitBackgroundDataCollector

- (instancetype)initWithIdentifier:(NSString*)identifier sampleType:(HKSampleType*)type anchorName:(NSString*)anchorName launchDateAnchor:(APCInitialStartDatePredicateDesignator)launchDateAnchor healthStore:(HKHealthStore *)healthStore
{
    self = [super initWithIdentifier:identifier dateAnchorName:anchorName launchDateAnchor:launchDateAnchor];
    
    if (self)
    {
        _sampleType         = type;
        _healthStore        = healthStore;
    }
    
    return self;
}

- (instancetype)initWithQuantityTypeIdentifier:(NSString*)identifier
                                    sampleType:(HKSampleType*)type
                                    anchorName:(NSString*)anchorName
                              launchDateAnchor:(APCInitialStartDatePredicateDesignator)launchDateAnchor
                                   healthStore:(HKHealthStore*)healthStore
                                          unit:(HKUnit*)unit
{
    self = [super initWithIdentifier:identifier dateAnchorName:anchorName launchDateAnchor:launchDateAnchor];
    
    if (self)
    {
        _sampleType         = type;
        _healthStore        = healthStore;
        _unit               = unit;
    }
    
    return self;
}

- (void)start
{
    if (!self.observerQuery)
    {
        [self observerQueryForSampleType:self.sampleType];
        
        NSSet* readTypes = [[NSSet alloc] initWithArray:@[self.sampleType]];
        
        [self.healthStore requestAuthorizationToShareTypes:nil
                                                 readTypes:readTypes
                                                completion:nil];
    }
}

- (void)observerQueryForSampleType:(HKSampleType*)sampleType
{
    __weak __typeof(self) weakSelf = self;
    
    self.observerQuery = [[HKObserverQuery alloc] initWithSampleType:sampleType
                                                                 predicate:nil
                                                             updateHandler:^(HKObserverQuery *query,
                                                                             HKObserverQueryCompletionHandler completionHandler,
                                                                             NSError *error)
    {
        if (error)
        {
            APCLogError2(error);
        }
        else
        {
            __typeof(self) strongSelf = weakSelf;

            [strongSelf anchorQuery:query
                  completionHandler:completionHandler];
        }
    }];

    [self.healthStore executeQuery:self.observerQuery];
}

- (void)stop
{
    [self.healthStore stopQuery:self.observerQuery];
}


- (void)anchorQuery:(HKObserverQuery*)query completionHandler:(HKObserverQueryCompletionHandler)completionHandler
{
    NSUInteger      anchorToUse                         = 0;
    NSUInteger      backgroundLaunchAnchorDate          = [[NSUserDefaults standardUserDefaults] integerForKey:self.anchorName];
    NSPredicate*    predicate                           = nil;
    
    //  On first launch there is no anchor and so we use a predicate that specifies the launch date.
    if (backgroundLaunchAnchorDate)
    {
        anchorToUse = backgroundLaunchAnchorDate;
    }
    else
    {
        NSDate*     launchDate          = [self launchDate];
        NSDate*     launchDayStartOfday = [launchDate startOfDay];
        
        predicate = [HKAnchoredObjectQuery predicateForSamplesWithStartDate:launchDayStartOfday
                                                                    endDate:[NSDate date]
                                                                    options:HKQueryOptionNone];
    }
    
    __weak __typeof(self)   weakSelf        = self;
    HKAnchoredObjectQuery*  anchorQuery     = [[HKAnchoredObjectQuery alloc] initWithType:query.sampleType
                                                                                predicate:predicate
                                                                                   anchor:anchorToUse
                                                                                    limit:HKQueryOptionNone
                                                                        completionHandler:^(HKAnchoredObjectQuery __unused *query, NSArray *results, NSUInteger newAnchor, NSError *error)
    {
        if (error)
        {
          APCLogError2(error);
        }
        else
        {
          if (results)
          {
              __typeof(self) strongSelf = weakSelf;
              
              if ([results lastObject])
              {
                  //  Set the anchor date for the next time the app is alive and send the current results to the data sink.
                  [[NSUserDefaults standardUserDefaults] setInteger:newAnchor forKey:strongSelf.anchorName];
                  [[NSUserDefaults standardUserDefaults] synchronize];
              }
              
              [strongSelf notifyListenersWithResults:results withError:error];
          }
        }
        
        if (completionHandler)
        {
            completionHandler();
        }
    }];
    
    [self.healthStore executeQuery:anchorQuery];
    
}

- (void)notifyListenersWithResults:(NSArray*)results withError:(NSError*)error
{
    if (results)
    {
        id sampleKind = results.firstObject;
        
        if (sampleKind)
        {
            if ([sampleKind isKindOfClass:[HKCategorySample class]])
            {
                HKCategorySample* categorySample = (HKCategorySample*)sampleKind;
                
                APCLogDebug(@"HK Update received for: %@ - %d", categorySample.categoryType.identifier, categorySample.value);
                
                if ([self.delegate respondsToSelector:@selector(didReceiveUpdatedValuesFromCollector:)])
                {
                    [self.delegate didReceiveUpdatedValuesFromCollector:results];
                }
                
            }
            else if ([sampleKind isKindOfClass:[HKWorkout class]])
            {
                HKWorkout* workoutSample = (HKWorkout*)sampleKind;
                
                APCLogDebug(@"HK Update received for: %@ - %d", workoutSample.sampleType.identifier, workoutSample.metadata);
                
                if ([self.delegate respondsToSelector:@selector(didReceiveUpdatedValuesFromCollector:)])
                {
                    [self.delegate didReceiveUpdatedValuesFromCollector:results];
                }
            }
            else if ([sampleKind isKindOfClass:[HKQuantitySample class]])
            {
                HKQuantitySample* quantitySample = (HKQuantitySample*)sampleKind;
                
                APCLogDebug(@"HK Update received for: %@ - %@", quantitySample.quantityType.identifier, quantitySample.quantity);
                
                if ([self.delegate respondsToSelector:@selector(didReceiveUpdatedHealthkitSamplesFromCollector:withUnit:)])
                {
                    [self.delegate didReceiveUpdatedHealthkitSamplesFromCollector:results withUnit:self.unit];
                }
            }
        }
    }
    else
    {
        APCLogError2(error);
    }
}

@end
