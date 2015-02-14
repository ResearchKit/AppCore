//
//  APCFoodInsight.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCFoodInsight.h"

static NSString *kLoseItBundleIdentifier        = @"com.fitnow.loseit";
static NSString *kLoseItFoodImageNameKey        = @"HKFoodImageName";

static NSString *kFoodInsightFoodNameKey        = @"foodNameKey";
static NSString *kFoodInsightFoodGenericNameKey = @"foodGenericNameKey";
static NSString *kFoodInsightValueKey           = @"foodValueKey";
static NSString *kFoodInsightCaloriesValueKey   = @"foodCaloriesValueKey";
static NSString *kFoodInsightFrequencyKey       = @"foodFrequencyKey";
static NSString *kFoodInsightUUIDKey            = @"foodUUIDKey";

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

@property (nonatomic, strong) NSArray *foodHistory;
@property (nonatomic, strong) NSNumber *totalCalories;

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
        
        _startDate = [self dateForSpan:-7 fromDate:[NSDate date]];
        _endDate   = [NSDate date];
        
        _source = nil;
        
        _foodHistory = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(foodInsightDataCollectionIsDone:)
                                                     name:kAPHFoodInsightDataCollectionIsCompletedNotification
                                                   object:nil];
        
        [self configureSource];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Source

- (void)configureSource
{
    HKSourceQuery *sourceQuery = [[HKSourceQuery alloc] initWithSampleType:_sampleType
                                                           samplePredicate:nil
                                                         completionHandler:^(HKSourceQuery *query, NSSet *sources, NSError *error)
    {
        if (error) {
            APCLogError2(error);
        } else {
            for (HKSource *source in sources) {
                if ([source.bundleIdentifier isEqualToString:kLoseItBundleIdentifier]) {
                    _source = source;
                    break;
                }
            }

            if (_source) {
                [self queryForCalories];
            }
        }
    }];
    [self.healthStore executeQuery:sourceQuery];
}

#pragma mark - HealthKit

- (void)queryForCalories
{
    NSLog(@"Running query for %@", self.caloriesQuantityType.identifier);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K <= %@) and (%K = %@)",
                              HKPredicateKeyPathStartDate, self.startDate,
                              HKPredicateKeyPathEndDate, self.endDate,
                              HKPredicateKeyPathSource, self.source];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:self.caloriesQuantityType
                                                       quantitySamplePredicate:predicate
                                                                       options:HKStatisticsOptionCumulativeSum
                                                             completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error)
    {
        if (error) {
            APCLogError2(error);
        } else {
            self.totalCalories = @([result.sumQuantity doubleValueForUnit:self.caloriesUnit]);
            
            NSLog(@"Total calories for last 7 days: %@", self.totalCalories);
            
            [self queryForSampleType:self.sampleType
                                unit:self.sampleUnit];
        }
    }];
    
    [self.healthStore executeQuery:query];
}

- (void)queryForSampleType:(HKSampleType *)sampleType
                      unit:(HKUnit *)unit
{
    NSLog(@"Running query for %@", sampleType.identifier);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K <= %@) and (%K = %@)",
                              HKPredicateKeyPathStartDate, self.startDate,
                              HKPredicateKeyPathEndDate, self.endDate,
                              HKPredicateKeyPathSource, self.source];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType
                                                           predicate:predicate
                                                               limit:HKObjectQueryNoLimit
                                                     sortDescriptors:nil
                                                      resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error)
    {
        if (error) {
            APCLogError2(error);
        } else {
            NSMutableArray *foodList = [NSMutableArray new];

            for (HKQuantitySample *sample in results) {
                NSLog(@"%@", sample);

                NSNumber *sampleValue = @([sample.quantity doubleValueForUnit:self.sampleUnit]);

                NSDictionary *food = @{
                                        kFoodInsightFoodNameKey: sample.metadata[HKMetadataKeyFoodType],
                                        kFoodInsightUUIDKey: sample.metadata[HKMetadataKeyExternalUUID],
                                        kFoodInsightFoodGenericNameKey: sample.metadata[kLoseItFoodImageNameKey],
                                        kFoodInsightValueKey: sampleValue
                                      };

                [foodList addObject:food];
            }

            self.foodHistory = [self addFrequencyForFoodInDataset:foodList];
        }
        
        // Post the notification that all data collection and processing is done.
        [[NSNotificationCenter defaultCenter] postNotificationName:kAPHFoodInsightDataCollectionIsCompletedNotification
                                                            object:nil];
    }];
    
    [self.healthStore executeQuery:query];
}

#pragma mark - Notification

- (void)foodInsightDataCollectionIsDone:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(didCompleteFoodInsight:)]) {
            [self.delegate didCompleteFoodInsight:self.foodHistory];
        }
    });
}

#pragma mark - Helpers

- (NSArray *)addFrequencyForFoodInDataset:(NSArray *)dataset
{
    NSMutableArray *markedDataset = [NSMutableArray new];
    NSArray *genericFoodType = [dataset valueForKey:kFoodInsightFoodGenericNameKey];
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:genericFoodType];
    
    for (id item in countedSet) {
        NSLog(@"Item: %@  (count of %lu)", item, [countedSet countForObject:item]);
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", kFoodInsightFoodGenericNameKey, item];
        NSArray *foodGroup = [dataset filteredArrayUsingPredicate:predicate];
        
        double sumFoodValue = 0;
        
        for (NSDictionary *food in foodGroup) {
            sumFoodValue += [food[kFoodInsightValueKey] doubleValue];
        }
        
        NSMutableDictionary *foodItem = [NSMutableDictionary new];
        foodItem[kFoodInsightFoodGenericNameKey] = item;
        foodItem[kFoodInsightValueKey] = @(sumFoodValue);
        foodItem[kFoodInsightFrequencyKey] = @([countedSet countForObject:item]);
        foodItem[kFoodInsightCaloriesValueKey] = [self percentOfSampleCalories:@(sumFoodValue)];
        
        [markedDataset addObject:foodItem];
    }
    
    // Sort dataset by frequency in desending order
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kFoodInsightFrequencyKey
                                                                   ascending:NO];
    [markedDataset sortUsingDescriptors:@[sortDescriptor]];
    
    NSArray *foodList = nil;
    
    // Only return the top-10 foods
    if ([markedDataset count] > 10) {
        NSRange range = NSMakeRange(0, 10);
        foodList = [markedDataset objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:range]];
    } else {
        foodList = markedDataset;
    }
    
    return foodList;
}

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
