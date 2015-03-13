//
//  APCInsights.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCInsights.h"
#import "APCAppCore.h"
#import <HealthKit/HealthKit.h>
#import "NSOperationQueue+Helper.h"

NSString * const kInsightKeyGoodDayValue = @"insightKeyGoodDayValue";
NSString * const kInsightKeyGlucoseGoodDayValue = @"insightKeyGlucoseGoodDayValue";
NSString * const kInsightKeyGlucoseBadDayValue = @"insightKeyGlucoseBadDayValue";
NSString * const kInsightKeyBadDayValue  = @"insightKeyBadDayValue";

NSString * const kAPCInsightFactorValueKey = @"insightFactorValueKey";
NSString * const kAPCInsightFactorNameKey = @"insightFactorNameKey";

static NSString *kAPHInsightSampleTypeKey = @"insightSampleTypeKey";
static NSString *kAPHInsightSampleUnitKey = @"insightSampleUnitKey";

static NSString *kInsightDatasetIsGoodDayKey = @"insightDatasetIsGoodDayKey";
static NSString *kInsightDatasetAverageReadingKey = @"insightDatasetAverageReadingKey";

NSString * const kAPCInsightDataCollectionIsCompletedNotification = @"APCInsightDataCollectionIsCompletedNotification";

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

@property (nonatomic, strong) NSMutableArray *insightPointValues;

@property (nonatomic, strong) NSMutableArray *insightPoints;

@property (nonatomic, strong) NSOperationQueue *insightQueue;

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
        
        _captionGood = NSLocalizedString(@"Not enough data", @"Not enough data");
        _captionBad  = NSLocalizedString(@"Not enough data", @"Not enough data");
        _valueGood = @(0);
        _valueBad  = @(0);
        
        _insightPointValues = [NSMutableArray new];
        
        NSString *queueName = [NSString stringWithFormat:@"Insights: Getting %@ from HeathKit", self.insightFactorName];
        
        _insightQueue = [NSOperationQueue sequentialOperationQueueWithName:queueName];
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"Insight:\n  Insight Factor: %@\n  Readings: %@\n  Insight Period: %@\n Baseline A/B: %@/%@\n",
            self.insightFactorName, self.numberOfReadings, self.insightPeriodInDays, self.baselineHigh, self.baselineHighOther];
}

- (void)configureInsight
{
    switch (self.insightFactor) {
        case APCInsightFactorActivity:
        {
            self.insightFactorName = HKQuantityTypeIdentifierDistanceWalkingRunning;
            self.insightFactorUnit = [HKUnit meterUnit];
            self.insightFactorCaption = NSLocalizedString(@"minutes spent active", @"{minutes} minutes spent active");
        }
            break;
        case APCInsightFactorCarbohydrateConsumption:
        {
            self.insightFactorName = HKQuantityTypeIdentifierDietaryCarbohydrates;
            self.insightFactorUnit = [HKUnit gramUnit];
            self.insightFactorCaption = NSLocalizedString(@"carbohydrates consumed", @"{grams} carbohydrate consumed");
        }
            break;
        case APCInsightFactorCarbohydrateCalories:
        case APCInsightFactorSugarCalories:
        case APCInsightFactorCalories:
        {
            self.insightFactorName = HKQuantityTypeIdentifierDietaryEnergyConsumed;
            self.insightFactorUnit = [HKUnit kilocalorieUnit];
            self.insightFactorCaption = NSLocalizedString(@"calories consumed", @"{kilo calories} calories consumed");
        }
            break;
        case APCInsightFactorSteps:
        {
            self.insightFactorName = HKQuantityTypeIdentifierStepCount;
            self.insightFactorUnit = [HKUnit countUnit];
            self.insightFactorCaption = NSLocalizedString(@"Steps", @"{step value} steps taken");
        }
            break;
        case APCInsightFactorSugarConsumption:
        {
            self.insightFactorName = HKQuantityTypeIdentifierDietarySugar;
            self.insightFactorUnit = [HKUnit gramUnit];
            self.insightFactorCaption = NSLocalizedString(@"sugar consumed", @"{grams} sugar consumed");
        }
            break;
        case APCInsightFactorTimeSlept:
        {
            self.insightFactorName = HKCategoryTypeIdentifierSleepAnalysis;
            self.insightFactorUnit = [HKUnit hourUnit];
            self.insightFactorCaption = NSLocalizedString(@"slept", @"slept");
        }
            break;
        default:
            NSAssert(YES, @"This factor is not yet supported by Insights.");
            break;
    }
}

- (void)factorInsight
{
    [self retrieveDatasetForGlucoseForPeriod:-5];
}

#pragma mark - Core Data

- (void) retrieveDatasetForGlucoseForPeriod: (NSInteger) __unused period
{
    NSArray *readings = nil;
    
    APCScoring *glucoseReadings = [[APCScoring alloc] initWithTask:@"APHLogGlucose-42449E07-7124-40EF-AC93-CA5BBF95FC15"
                                                      numberOfDays:-5
                                                          valueKey:@"value"
                                                           dataKey:nil
                                                           sortKey:nil
                                                           groupBy:APHTimelineGroupForInsights];
    readings = [glucoseReadings allObjects];
    
    NSPredicate *predicateBefore = [NSPredicate predicateWithFormat:@"%K == %@", @"raw.period", @"before"];
    NSPredicate *predicateAfter = [NSPredicate predicateWithFormat:@"%K == %@", @"raw.period", @"after"];
    
    NSArray *beforeReadings = [readings filteredArrayUsingPredicate:predicateBefore];
    NSArray *afterReadings  = [readings filteredArrayUsingPredicate:predicateAfter];
    
    NSArray *groupedBeforeReadings = [self groupDataset:beforeReadings];
    NSArray *groupedAfterReadings = [self groupDataset:afterReadings];
    
    NSMutableArray *groupedReadings = [NSMutableArray new];
    [groupedReadings addObjectsFromArray:groupedBeforeReadings];
    [groupedReadings addObjectsFromArray:groupedAfterReadings];
    
    self.insightPoints = [[self markDataset:groupedReadings] mutableCopy];
    
    [self fetchDataFromHealthKitForItemsInInsightQueue];
}

#pragma mark HealthKit

- (void)statsCollectionQueryForQuantityType:(HKQuantityType *)quantityType
                                       unit:(HKUnit *)unit
                                 forReading:(NSDictionary *)reading
                             withCompletion:(void (^)(void)) __unused completion
{
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;
    
    NSDate *readingDate = reading[kDatasetDateKey];
    
    NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                 minute:0
                                                                 second:0
                                                                 ofDate:[self dateForSpan:[self.insightPeriodInDays integerValue]
                                                                                 fromDate:readingDate]
                                                                options:0];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:[NSDate date] options:HKQueryOptionStrictEndDate];
    
    BOOL isDecreteQuantity = ([quantityType aggregationStyle] == HKQuantityAggregationStyleDiscrete);
    
    HKStatisticsOptions queryOptions;
    
    if (isDecreteQuantity) {
        queryOptions = HKStatisticsOptionDiscreteAverage;
    } else {
        queryOptions = HKStatisticsOptionCumulativeSum;
    }
    
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                           quantitySamplePredicate:predicate
                                                                                           options:queryOptions
                                                                                        anchorDate:startDate
                                                                                intervalComponents:interval];
    
    // set the results handler
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery * __unused query,
                                    HKStatisticsCollection *results,
                                    NSError *error) {
        if (!error) {
            NSDate *endDate = [[NSCalendar currentCalendar] dateBySettingHour:23
                                                                       minute:59
                                                                       second:59
                                                                       ofDate:startDate
                                                                      options:0];
            NSDate *beginDate = startDate;
            
            __block NSDictionary *dataPoint = nil;
            
            [results enumerateStatisticsFromDate:beginDate
                                          toDate:endDate
                                       withBlock:^(HKStatistics *result, BOOL * __unused stop) {
                                           HKQuantity *quantity;
                                           
                                           if (isDecreteQuantity) {
                                               quantity = result.averageQuantity;
                                           } else {
                                               quantity = result.sumQuantity;
                                           }
                                           
                                           NSDate *date = result.startDate;
                                           double value = [quantity doubleValueForUnit:unit];
                                           
                                           dataPoint = @{
                                                       kDatasetDateKey: date,
                                                       kDatasetValueKey: (!quantity) ? @(NSNotFound) : @(value),
                                                       kAPCInsightFactorNameKey: self.insightFactorName
                                                       };
                                           
                                           
                                       }];
            
            NSMutableDictionary *readingPoint = [NSMutableDictionary dictionaryWithDictionary:reading];
            [readingPoint setObject:self.insightFactorName forKey:kAPCInsightFactorNameKey];
            [readingPoint setObject:dataPoint[kDatasetValueKey] forKey:kAPCInsightFactorValueKey];
            
            [self.insightPointValues addObject:readingPoint];
            
            [self fetchDataFromHealthKitForItemsInInsightQueue];
        }
    };
    
    [self.healthStore executeQuery:query];
}

#pragma mark - Helpers

- (void)fetchDataFromHealthKitForItemsInInsightQueue
{
    APCLogDebug(@"Fetching data from HealthKit entry point...");
    
    [self.insightQueue addOperationWithBlock:^{
        
        BOOL hasInsightPointsInQueue = self.insightPoints.count > 0;
        
        APCLogDebug(@"About to queue insight item...");
        
        if (hasInsightPointsInQueue) {
            
            NSDictionary *item = [self.insightPoints firstObject];
            [self.insightPoints removeObjectAtIndex:0];
            
            APCLogDebug(@"We are about to ask HK for item %@...", item);
            
            [self statsCollectionQueryForQuantityType:[HKQuantityType quantityTypeForIdentifier:self.insightFactorName]
                                                 unit:self.insightFactorUnit
                                           forReading:item
                                       withCompletion:nil];
        } else {
            APCLogDebug(@"Insights: We're done!");
            [self dataPointsAreAvailableFromHealthKit:self.insightPointValues];
        }
    }];
}

- (void)dataPointsAreAvailableFromHealthKit:(NSArray *)insightPoints
{
    APCLogDebug(@"Insights: %@", insightPoints);
    
    NSString *caption = NSLocalizedString(@"Not enough data", @"Not enough data");
    NSNumber *pointValue = @(0);
    
    NSArray *goodPoints = [insightPoints filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", kInsightDatasetIsGoodDayKey, @(YES)]];
    NSArray *badPoints  = [insightPoints filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", kInsightDatasetIsGoodDayKey, @(NO)]];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setMaximumFractionDigits:0];
    
    if (goodPoints.count > 0) {
        pointValue = [goodPoints valueForKeyPath:@"@avg.insightFactorValueKey"];
        
        if ([self.insightFactorName isEqualToString:HKQuantityTypeIdentifierDietaryEnergyConsumed]) {
            if ([pointValue doubleValue] > 1000.0) {
                caption = [NSString stringWithFormat:@"%@ %@",
                           [numberFormatter stringFromNumber:pointValue],
                           self.insightFactorCaption];
            }
        } else {
            caption = [NSString stringWithFormat:@"%@ %@",
                       [numberFormatter stringFromNumber:pointValue],
                       self.insightFactorCaption];
        }

        self.valueGood = pointValue;
        self.captionGood = NSLocalizedString(caption, caption);
    }
    
    if (badPoints.count > 0) {
        pointValue = [badPoints valueForKeyPath:@"@avg.insightFactorValueKey"];
        
        if ([self.insightFactorName isEqualToString:HKQuantityTypeIdentifierDietaryEnergyConsumed]) {
            if ([pointValue doubleValue] > 1000.0) {
                caption = [NSString stringWithFormat:@"%@ %@",
                           [numberFormatter stringFromNumber:pointValue],
                           self.insightFactorCaption];
            }
        } else {
            caption = [NSString stringWithFormat:@"%@ %@",
                       [numberFormatter stringFromNumber:pointValue],
                       self.insightFactorCaption];
        }
        
        self.valueBad = pointValue;
        self.captionBad  = NSLocalizedString(caption, caption);
    }
    
    NSOperationQueue *realMainQueue = [NSOperationQueue mainQueue];
    
    [realMainQueue addOperationWithBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kAPCInsightDataCollectionIsCompletedNotification
                                                            object:nil];
    }];
}

- (NSArray *)groupDataset:(NSArray *)dataset
{
    NSMutableArray *groupedDataset = [NSMutableArray array];
    NSArray *days = [dataset valueForKeyPath:@"@distinctUnionOfObjects.datasetGroupByDay"];
    NSArray *beforeAfter = @[@"before", @"after"];
    
    for (NSString *day in days) {
        
        for (NSString *period in beforeAfter) {
            NSMutableDictionary *entry = [NSMutableDictionary dictionary];
            [entry setObject:day forKey:kDatasetDateKey];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@) and (%K = %@)", kDatasetDateKey, day, @"raw.period", period];
            NSArray *groupItems = [dataset filteredArrayUsingPredicate:predicate];
            double itemSum = 0;
            double dayAverage = 0;
            
            for (NSDictionary *item in groupItems) {
                NSNumber *value = item[kDatasetValueKey];
                
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
            [entry setObject:@([period isEqualToString:@"before"]) forKey:@"period"];
            
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
            
            if ([average isEqualToNumber:@(NSNotFound)] == NO) {
                // check if the average in-range or high
                if ([reading[@"period"] boolValue]) {
                    if ([average doubleValue] >= [self.baselineHigh integerValue]) {
                        tally++;
                    }
                } else {
                    if ([average doubleValue] >= [self.baselineHighOther integerValue]) {
                        tally++;
                    }
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
        
        [dayReading setObject:dayAverages forKey:kInsightDatasetAverageReadingKey];
        [dayReading setObject:@(isGoodDay) forKey:kInsightDatasetIsGoodDayKey];
        
        [markedDataset addObject:dayReading];
    }
    
    return markedDataset;
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
