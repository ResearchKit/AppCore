// 
//  APCFoodInsight.m 
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
 
#import "APCFoodInsight.h"
#import "NSOperationQueue+Helper.h"

static NSString *kLoseItBundleIdentifier           = @"com.fitnow.loseit";
static NSString *kLoseItFoodImageNameKey           = @"HKFoodImageName";

NSString * const kFoodInsightFoodNameKey           = @"foodNameKey";
NSString * const kFoodInsightFoodGenericNameKey    = @"foodGenericNameKey";
NSString * const kFoodInsightValueKey              = @"foodValueKey";
NSString * const kFoodInsightCaloriesValueKey      = @"foodCaloriesValueKey";
NSString * const kFoodInsightFrequencyKey          = @"foodFrequencyKey";
NSString * const kFoodInsightUUIDKey               = @"foodUUIDKey";
NSString * const kFoodInsightSugarCaloriesValueKey = @"sugarCaloriesValueKey";

static NSInteger kLastSevenDays = -7; // This is a negative integer because we need to go back in time.
                                      // In order to do so, we need to pass a negative integer to the NSDateComponents object.

static NSString *kAPHFoodInsightDataCollectionIsCompletedNotification = @"APHFoodInsightDataCollectionIsCompletedNotification";

@interface APCFoodInsight()

@property (nonatomic, strong) HKHealthStore *healthStore;

@property (nonatomic, strong) HKSampleType *sampleType;
@property (nonatomic, strong) HKUnit *sampleUnit;

@property (nonatomic, strong) HKQuantityType *caloriesQuantityType;
@property (nonatomic, strong) HKUnit *caloriesUnit;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, strong) HKSource *source;

@property (nonatomic, strong) NSNumber *totalCalories;

@property (nonatomic, strong) __block NSMutableArray *foodList;
@property (nonatomic, strong) __block NSMutableArray *queuedFoodItems;
@property (nonatomic, strong) __block NSMutableArray *caloriesForFoodItems;

@property (nonatomic, strong) NSOperationQueue *insightCaloriesQueue;

@end

@implementation APCFoodInsight

- (instancetype)initFoodInsightForSampleType:(HKSampleType *)sample
                                        unit:(HKUnit *)unit
{
    self = [super init];
    
    if (self) {
        _healthStore = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.healthStore;
        
        _sampleType = sample;
        _sampleUnit = unit;
        
        _caloriesQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
        _caloriesUnit = [HKUnit kilocalorieUnit];
        
        _startDate = [self dateForSpan:kLastSevenDays fromDate:[NSDate date]];
        _endDate   = [NSDate date];
        
        _source = nil;
        
        _foodHistory = nil;
        
        _queuedFoodItems = [NSMutableArray new];
        _foodList = [NSMutableArray new];
        
        _insightCaloriesQueue = [NSOperationQueue sequentialOperationQueueWithName:@"Diet Insight: Getting calories from HeathKit"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(foodInsightDataCollectionIsDone:)
                                                     name:kAPHFoodInsightDataCollectionIsCompletedNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)insight
{
    [self startCollectionInsightData];
}

- (void)startCollectionInsightData
{
    // clean up before processing data.
    self.foodHistory = nil;
    [self.queuedFoodItems removeAllObjects];
    [self.foodList removeAllObjects];
    
    [self configureSource];
}

#pragma mark - Source

- (void)configureSource
{
    HKSourceQuery *sourceQuery = [[HKSourceQuery alloc] initWithSampleType:_sampleType
                                                           samplePredicate:nil
                                                         completionHandler:^(HKSourceQuery * __unused query, NSSet *sources, NSError *error)
    {
        if (error) {
            APCLogError2(error);
        } else {
            for (HKSource *source in sources) {
                if ([source.bundleIdentifier isEqualToString:kLoseItBundleIdentifier]) {
                    self.source = source;
                    break;
                }
            }

            if (self.source) {
                [self queryForSampleType:self.sampleType
                                    unit:self.sampleUnit];
            }
        }
    }];
    [self.healthStore executeQuery:sourceQuery];
}

#pragma mark - HealthKit

- (void)queryForCalories
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K <= %@) and (%K = %@)",
                              HKPredicateKeyPathStartDate, self.startDate,
                              HKPredicateKeyPathEndDate, self.endDate,
                              HKPredicateKeyPathSource, self.source];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType: self.caloriesQuantityType
                                                       quantitySamplePredicate: predicate
                                                                       options: HKStatisticsOptionCumulativeSum
                                                             completionHandler: ^(HKStatisticsQuery * __unused query,
                                                                                  HKStatistics *result,
                                                                                  NSError *error)
    {
        if (error) {
            APCLogError2(error);
        } else {
            self.totalCalories = @([result.sumQuantity doubleValueForUnit:self.caloriesUnit]);
            
            [self queryForSampleType:self.sampleType
                                unit:self.sampleUnit];
        }
    }];
    
    [self.healthStore executeQuery:query];
}

- (void)queryCaloriesForFoodType:(NSString *)foodItemExternalId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K.%K = %@) AND (%K >= %@) AND (%K <= %@) AND (%K = %@)",
                              HKPredicateKeyPathMetadata, HKMetadataKeyExternalUUID, foodItemExternalId,
                              HKPredicateKeyPathStartDate, self.startDate,
                              HKPredicateKeyPathEndDate, self.endDate,
                              HKPredicateKeyPathSource, self.source];
    
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType: self.caloriesQuantityType
                                                       quantitySamplePredicate: predicate
                                                                       options: HKStatisticsOptionCumulativeSum
                                                             completionHandler: ^(HKStatisticsQuery * __unused query,
                                                                                  HKStatistics *result,
                                                                                  NSError *error)
    {
        if (error) {
            APCLogError2(error);
        } else {
            NSNumber *caloriesForFoodItem = @([result.sumQuantity doubleValueForUnit:self.caloriesUnit]);
            
            APCLogDebug(@"Calories %@", caloriesForFoodItem);
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", kFoodInsightUUIDKey, foodItemExternalId];
            NSArray *matchedFoodItem = [self.foodList filteredArrayUsingPredicate:predicate];
            
            if (matchedFoodItem) {
                NSUInteger foodItemIndex = [self.foodList indexOfObject:[matchedFoodItem firstObject]];
                
                if (foodItemIndex == NSNotFound) {
                    APCLogError(@"The object %@ was not found in the food list.", [matchedFoodItem firstObject]);
                } else {
                    NSMutableDictionary *foodItem = [[matchedFoodItem firstObject] mutableCopy];
                    foodItem[kFoodInsightCaloriesValueKey] = caloriesForFoodItem;
                    
                    [self.foodList replaceObjectAtIndex:foodItemIndex withObject:foodItem];
                }
            }
            
            [self.caloriesForFoodItems addObject:@{
                                                   kFoodInsightUUIDKey: foodItemExternalId,
                                                   kFoodInsightCaloriesValueKey: caloriesForFoodItem
                                                   }];
            
        }
        
        [self fetchCaloriesForItemsInFoodListQueue];
    }];

    
    [self.healthStore executeQuery:query];
}

- (void) queryForSampleType: (HKSampleType *) sampleType
                       unit: (HKUnit *) __unused unit
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K <= %@) and (%K = %@)",
                              HKPredicateKeyPathStartDate, self.startDate,
                              HKPredicateKeyPathEndDate, self.endDate,
                              HKPredicateKeyPathSource, self.source];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: sampleType
                                                           predicate: predicate
                                                               limit: HKObjectQueryNoLimit
                                                     sortDescriptors: nil
                                                      resultsHandler: ^(HKSampleQuery * __unused query,
                                                                        NSArray *results,
                                                                        NSError *error)
    {
        if (error) {
            APCLogError2(error);
        } else {
            for (HKQuantitySample *sample in results) {
                NSNumber *sampleValue = @([sample.quantity doubleValueForUnit:self.sampleUnit]);
                
                
                if ([sampleValue doubleValue] > 0) {
                    NSDictionary *food = @{
                                            kFoodInsightFoodNameKey: sample.metadata[HKMetadataKeyFoodType],
                                            kFoodInsightUUIDKey: sample.metadata[HKMetadataKeyExternalUUID],
                                            kFoodInsightFoodGenericNameKey: sample.metadata[kLoseItFoodImageNameKey],
                                            kFoodInsightValueKey: sampleValue
                                          };
                    
                    [self.foodList addObject:food];
                }
            }
            
            [self.queuedFoodItems addObjectsFromArray:self.foodList];
            
            [self fetchCaloriesForItemsInFoodListQueue];
        }
    }];
    
    [self.healthStore executeQuery:query];
}

#pragma mark - Notification

- (void) foodInsightDataCollectionIsDone: (NSNotification *) __unused notification
{
    NSOperationQueue *theRealLifeMainThreadQueue = [NSOperationQueue mainQueue];
    
    [theRealLifeMainThreadQueue addOperationWithBlock:^{
        if ([self.delegate respondsToSelector:@selector(didCompleteFoodInsightForSampleType:insight:)]) {
            [self.delegate didCompleteFoodInsightForSampleType:self.sampleType insight:self.foodHistory];
        }
    }];
}

#pragma mark - Helpers

- (void)fetchCaloriesForItemsInFoodListQueue
{
    APCLogDebug(@"Fetching calories entry point...");
    
    [self.insightCaloriesQueue addOperationWithBlock:^{
       
        BOOL hasFoodItemsInQueue = self.queuedFoodItems.count > 0;
        
        APCLogDebug(@"About to queue food item...");
        
        if (hasFoodItemsInQueue) {
            
            NSDictionary *foodItem = [self.queuedFoodItems firstObject];
            [self.queuedFoodItems removeObjectAtIndex:0];
            
            APCLogDebug(@"We are about to ask HK for the calories for food item %@...", foodItem);
            
            [self queryCaloriesForFoodType:foodItem[kFoodInsightUUIDKey]];
        } else {
            APCLogDebug(@"We're done!");
            self.foodHistory = [self addFrequencyForFoodInDataset:self.foodList];
            
            // Post the notification that all data collection and processing is done.
            [[NSNotificationCenter defaultCenter] postNotificationName:kAPHFoodInsightDataCollectionIsCompletedNotification
                                                                object:nil];
        }
    }];

}

- (NSArray *)addFrequencyForFoodInDataset:(NSArray *)dataset
{
    NSMutableArray *markedDataset = [NSMutableArray new];
    NSArray *genericFoodType = [dataset valueForKey:kFoodInsightFoodGenericNameKey];
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:genericFoodType];
    
    for (id item in countedSet) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", kFoodInsightFoodGenericNameKey, item];
        NSArray *foodGroup = [dataset filteredArrayUsingPredicate:predicate];
        
        NSString *foodItemName = nil;
        double sumFoodValue = 0;
        double sumFoodCalories = 0;
        
        for (NSDictionary *food in foodGroup) {
            if (!foodItemName) {
                foodItemName = food[kFoodInsightFoodNameKey];
            }
            
            sumFoodValue += [food[kFoodInsightValueKey] doubleValue];
            sumFoodCalories += [food[kFoodInsightCaloriesValueKey] doubleValue];
        }
        
        NSNumber *caloriesFromSample = [self percentOfSampleCalories:@(sumFoodValue) totalCalories:@(sumFoodCalories)];
        
        double percentCalories = [caloriesFromSample doubleValue] * 100;
        
        if (percentCalories >= 10 && sumFoodCalories > 80) {
            NSMutableDictionary *foodItem = [NSMutableDictionary new];
            foodItem[kFoodInsightFoodNameKey] = (!foodItemName) ? [NSNull null] : foodItemName;
            foodItem[kFoodInsightValueKey] = @(sumFoodValue);
            foodItem[kFoodInsightFrequencyKey] = @([countedSet countForObject:item]);
            foodItem[kFoodInsightCaloriesValueKey] = caloriesFromSample;
            
            [markedDataset addObject:foodItem];
        }
    }
    
    // Sort dataset by frequency in desending order
    NSSortDescriptor *sortDescriptorFrequency = [[NSSortDescriptor alloc] initWithKey:kFoodInsightFrequencyKey
                                                                            ascending:NO];
    
    NSSortDescriptor *sortDescriptiorPercentage = [[NSSortDescriptor alloc] initWithKey:kFoodInsightCaloriesValueKey
                                                                              ascending:NO];
    [markedDataset sortUsingDescriptors:@[sortDescriptorFrequency, sortDescriptiorPercentage]];
    
    NSArray *foodList = nil;
    
    // Only return top-10 foods by frequency
    if ([markedDataset count] > 10) {
        NSRange range = NSMakeRange(0, 10);
        foodList = [markedDataset objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:range]];
    } else {
        foodList = markedDataset;
    }
    
    return foodList;
}

- (NSNumber *)percentOfSampleCalories:(NSNumber *)gramsConsumed
                        totalCalories:(NSNumber *)totalCalories
{
    NSInteger caloriesPerGramOfSample = 4;
    double caloriesConsumed = [gramsConsumed doubleValue] * caloriesPerGramOfSample;
    double percentOfCalories = caloriesConsumed / [totalCalories doubleValue];
    
    if (percentOfCalories > 1) {
        percentOfCalories = 1;
    }
    
    return @(percentOfCalories);
}

/**
 * @brief   Returns an NSDate that is past/future by the value of daySpan from the provided date.
 *
 * @param   daySpan Number of days relative to current date.
 *                  If negative, date will be number of days in the past;
 *                  otherwise the date will be number of days in the future.
 *
 * @return  Returns the date as NSDate.
 */
- (NSDate *)dateForSpan:(NSInteger)daySpan fromDate:(NSDate *)date
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:daySpan];
    
    if (!date) {
        date = [NSDate date];
    }
    
    NSDate *spanDate = [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                                     toDate:date
                                                                    options:0];
    return spanDate;
}

@end
