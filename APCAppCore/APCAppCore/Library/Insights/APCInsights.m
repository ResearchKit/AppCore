//
//  APCInsights.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCInsights.h"
#import "APCAppCore.h"
//#import "APCGlucoseReadings.h"
//#import "APCGlucoseReadings+AddOn.h"
//#import "APCInsightConfiguration.h"
//#import "APCInsightConfiguration+AddOn.h"
#import <HealthKit/HealthKit.h>

NSString const *kInsightKeyGoodDayValue = @"insightKeyGoodDayValue";
NSString const *kInsightKeyGlucoseGoodDayValue = @"insightKeyGlucoseGoodDayValue";
NSString const *kInsightKeyGlucoseBadDayValue = @"insightKeyGlucoseBadDayValue";
NSString const *kInsightKeyBadDayValue  = @"insightKeyBadDayValue";

NSString const *kAPCInsightFactorValueKey = @"insightFactorValueKey";
NSString const *kAPCInsightFactorNameKey = @"insightFactorNameKey";

static NSString *kAPHInsightSampleTypeKey = @"insightSampleTypeKey";
static NSString *kAPHInsightSampleUnitKey = @"insightSampleUnitKey";

static NSString *kInsightDatasetIsGoodDayKey = @"insightDatasetIsGoodDayKey";
static NSString *kInsightDatasetAverageReadingKey = @"insightDatasetAverageReadingKey";

@interface APCInsights()

@property (nonatomic, strong) HKHealthStore *healthStore;

@property (nonatomic) APCInsightFactors insightFactor;
@property (nonatomic, strong) NSString *insightFactorName;
@property (nonatomic, strong) HKUnit *insightFactorUnit;

@property (nonatomic, strong) NSString *insightFactorCaption;

@property (nonatomic, strong) NSNumber *insightPeriodInDays;
@property (nonatomic, strong) NSNumber *numberOfReadings;
@property (nonatomic, strong) NSNumber *baselineHigh;
@property (nonatomic, strong) NSNumber *baselineHighOther;

@end

@implementation APCInsights

- (instancetype)initWithFactor:(APCInsightFactors)factor
              numberOfReadings:(NSNumber *)readings
                 insightPeriod:(NSNumber *)period
                  baselineHigh:(NSNumber *)baselineHigh
                 baselineOther:(NSNumber *)baselineOther
{
    self = [self initWithFactor:factor];
    
    if (self) {
        _numberOfReadings = readings;
        _insightPeriodInDays = period;
        _baselineHigh = baselineHigh;
        _baselineHighOther = baselineOther;
    }
    
    return self;
}

- (instancetype)initWithFactor:(APCInsightFactors)factor
{
    self = [super init];
    
    if (self) {
        _healthStore = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.healthStore;
        _insightFactor = factor;
        _ignoreBaselineOther = NO;
        
        [self configureInsight];
    }
    
    return self;
}

- (void)configureInsight
{
    NSMutableArray *insights = [NSMutableArray new];
    
    switch (self.insightFactor) {
        case APCInsightFactorActivity:
        {
            self.insightFactorName = HKQuantityTypeIdentifierDistanceWalkingRunning;
            [insights addObject:@{
                                  kAPHInsightSampleTypeKey: [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
                                  kAPHInsightSampleUnitKey: [HKUnit meterUnit]
                                  }];
        }
            break;
        case APCInsightFactorCarbohydrateConsumption:
        {
            self.insightFactorName = HKQuantityTypeIdentifierDietaryCarbohydrates;
            [insights addObject:@{
                                  kAPHInsightSampleTypeKey: [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates],
                                  kAPHInsightSampleUnitKey: [HKUnit gramUnit]
                                  }];
        }
            break;
        case APCInsightFactorCarbohydrateCalories:
        case APCInsightFactorSugarCalories:
        case APCInsightFactorCalories:
            self.insightFactorName = HKQuantityTypeIdentifierDietaryEnergyConsumed;
            [insights addObject:@{
                                  kAPHInsightSampleTypeKey: [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed],
                                  kAPHInsightSampleUnitKey: [HKUnit kilocalorieUnit]
                                  }];
            break;
        case APCInsightFactorSteps:
            self.insightFactorName = HKQuantityTypeIdentifierStepCount;
            [insights addObject:@{
                                  kAPHInsightSampleTypeKey: [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                                  kAPHInsightSampleUnitKey: [HKUnit countUnit]
                                  }];
            break;
        case APCInsightFactorSugarConsumption:
            self.insightFactorName = HKQuantityTypeIdentifierDietarySugar;
            [insights addObject:@{
                                  kAPHInsightSampleTypeKey: [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySugar],
                                  kAPHInsightSampleUnitKey: [HKUnit gramUnit]
                                  }];
            break;
        case APCInsightFactorTimeSlept:
            self.insightFactorName = HKCategoryTypeIdentifierSleepAnalysis;
            [insights addObject:@{
                                  kAPHInsightSampleTypeKey: [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis],
                                  kAPHInsightSampleUnitKey: [HKUnit hourUnit]
                                  }];
            break;
        default:
            NSAssert(YES, @"This factor is not yet supported by Insights.");
            break;
    }
    
    //[self.dataStore setupObserverQueriesForInsights:insights];
}

- (void)factorInsight
{
    NSArray *readings = [self retrieveDatasetForGlucoseForPeriod:-5];
    
     
//    if ([self.delegate respondsToSelector:@selector(didCompleteInsightForFactor:withInsight:)]) {
//        [self.delegate didCompleteInsightForFactor:self.insightFactor withInsight:insight];
//    }
}

#pragma mark - Core Data

- (NSArray *)retrieveDatasetForGlucoseForPeriod:(NSInteger)period
{
    NSArray *readings = nil;
//    NSError *error = nil;
//    
//    NSDate *startDate = [self dateForSpan:period fromDate:[NSDate date]];
//    NSDate *endDate   = [NSDate date];
//    
//    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    NSFetchRequest *request = [APCGlucoseReadings request];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(createdAt >= %@) and (createdAt <= %@)", startDate, endDate];
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
//    
//    request.predicate = predicate;
//    request.sortDescriptors = @[sortDescriptor];
//    
//    
//    localContext.parentContext = self.dataStore.persistentContext;
//    
//    NSArray *entries = [localContext executeFetchRequest:request error:&error];
//    
//    if ([entries count] != 0) {        
//        NSArray *groupedReadings = [self groupDataset:entries];
//        
//        NSArray *markedReadings = [self markDataset:groupedReadings];
//        
//        readings = [self postProcessDataset:markedReadings];
//        
//    } else {
//        APCLogError(@"No glucose readings were found.");
//    }
//    
    return readings;
}

#pragma mark - HealthKitCache

- (NSNumber *)retrieveDatasetForInsight:(NSString *)insightKey fromReadingDate:(NSDate *)readingDate
{
    NSNumber *insightSum = @(0);
//
//    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    context.parentContext = self.dataStore.persistentContext;
//    
//    NSDate *startDate = [self dateForSpan:[self.insightPeriodInDays integerValue] fromDate:readingDate];
//    
//    NSArray *entries = [APCHealthKitCache entiresForInsight:insightKey
//                                                  startDate:startDate
//                                                    endDate:readingDate
//                                                  inContext:context];
//    if ([entries count]) {
//        insightSum = [entries valueForKeyPath:@"@sum.value"];
//    } else {
//        NSLog(@"No data found in HealthKit for the requested period.");
//    }
//    
    return insightSum;
}

#pragma mark - Helpers

- (NSArray *)groupDataset:(NSArray *)dataset
{
    NSMutableArray *groupedDataset = [NSMutableArray array];
    NSArray *days = [dataset valueForKeyPath:@"@distinctUnionOfObjects.createdAt"];
    NSArray *beforeAfter = @[@(YES), @(NO)];
    
    for (NSString *day in days) {
        
        for (NSNumber *before in beforeAfter) {
            NSMutableDictionary *entry = [NSMutableDictionary dictionary];
            [entry setObject:day forKey:kDatasetDateKey];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(createdAt = %@) and (isBefore = %@)", day, before];
            NSArray *groupItems = [dataset filteredArrayUsingPredicate:predicate];
            double itemSum = 0;
            double dayAverage = 0;
            
            for (NSDictionary *item in groupItems) {
                NSNumber *value = item[@"value"];
                
                if ([value integerValue] != NSNotFound) {
                    itemSum += [value doubleValue];
                }
            }
            
            if (groupItems.count != 0) {
                dayAverage = itemSum / groupItems.count;
            }
            
            if (dayAverage == 0) {
                dayAverage = NSNotFound;
            }
            
            [entry setObject:@(dayAverage) forKey:kDatasetValueKey];
            [entry setObject:before forKey:@"before"];
            
            [groupedDataset addObject:entry];
        }
    }
    
    // resort the grouped dataset by date
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:kDatasetDateKey
                                                               ascending:YES];
    [groupedDataset sortUsingDescriptors:@[sortByDate]];
    
    return groupedDataset;
}

- (NSArray *)markDataset:(NSArray *)dataset
{
    NSMutableArray *markedDataset = [NSMutableArray new];
    NSArray *days = [dataset valueForKeyPath:@"@distinctUnionOfObjects.datasetDateKey"];
    
    for (NSString *day in days) {
        NSMutableDictionary *dayReading = [NSMutableDictionary new];
        [dayReading setObject:day forKey:kDatasetDateKey];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@)", kDatasetDateKey, day];
        NSArray *groupedReadings = [dataset filteredArrayUsingPredicate:predicate];
        NSMutableArray *dayAverages = [NSMutableArray new];
        
        NSUInteger tally = 0;
        
        for (NSDictionary *reading in groupedReadings) {
            NSNumber *average = reading[kDatasetValueKey];
            
            // check if the average in-range or high
            if ([reading[@"before"] boolValue]) {
                if ([average doubleValue] >= 130) {
                    tally++;
                }
            } else {
                if ([average doubleValue] >= 180) {
                    tally++;
                }
            }
            
            // add to the array
            [dayAverages addObject:average];
        }
        
        BOOL isGoodDay;
        
        if (tally == 0) {
            isGoodDay = YES;
        } else {
            isGoodDay = NO;
        }
        
        [dayReading setObject:dayAverages forKey:kDatasetValueKey];
        [dayReading setObject:@(isGoodDay) forKey:@"isGoodDay"];
        
        [markedDataset addObject:dayReading];
    }
    
    return markedDataset;
}

- (NSArray *)postProcessDataset:(NSArray *)dataset
{
    NSMutableArray *readings = [NSMutableArray new];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    for (NSDictionary *day in dataset) {
        NSMutableDictionary *dayEntry = [day mutableCopy];
        
        NSDate *readingDate = [dateFormatter dateFromString:day[kDatasetDateKey]];
        
        dayEntry[kAPCInsightFactorValueKey] = [self retrieveDatasetForInsight:self.insightFactorName
                                                              fromReadingDate:readingDate];
        dayEntry[kAPCInsightFactorNameKey] = self.insightFactorName;
        
        [readings addObject:dayEntry];
    }
    
    return readings;
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
