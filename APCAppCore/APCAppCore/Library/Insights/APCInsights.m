// 
//  APCInsights.m 
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
static NSString *kInsightDatasetDayAverage = @"insightDatasetDayAverage";
static NSString *kInsightDatasetHighKey = @"insightDatasetHighKey";
static NSString *kInsightDatasetLowKey = @"InsightDatasetLowKey";

static double kBaselinePreMeal  = 130;
static double kBaselinePostMeal = 180;

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
        _insightPoints = [NSMutableArray new];
        
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
    [self startCollectionInsightData];
}

- (void)startCollectionInsightData
{
    [self resetInsight];
    [self retrieveDatasetForGlucoseForPeriod:-30];
}

#pragma mark - Core Data

- (void) retrieveDatasetForGlucoseForPeriod: (NSInteger)period
{
    NSArray *readings = nil;
    
    APCScoring *glucoseReadings = [[APCScoring alloc] initWithTask:@"APHLogGlucose-42449E07-7124-40EF-AC93-CA5BBF95FC15"
                                                      numberOfDays:period
                                                          valueKey:@"value"
                                                           dataKey:nil
                                                           sortKey:nil
                                                           groupBy:APHTimelineGroupForInsights];
    readings = [glucoseReadings allObjects];
    
    NSPredicate *predicateBefore = [NSPredicate predicateWithFormat:@"%K == %@", @"datasetRawData.period", @"before"];
    NSPredicate *predicateAfter = [NSPredicate predicateWithFormat:@"%K == %@", @"datasetRawData.period", @"after"];
    
    NSArray *beforeReadings = [readings filteredArrayUsingPredicate:predicateBefore];
    NSArray *afterReadings  = [readings filteredArrayUsingPredicate:predicateAfter];
    
    NSArray *groupedBeforeReadings = [self groupDataset:beforeReadings];
    NSArray *groupedAfterReadings = [self groupDataset:afterReadings];
    
    NSMutableArray *groupedReadings = [NSMutableArray new];
    [groupedReadings addObjectsFromArray:groupedBeforeReadings];
    [groupedReadings addObjectsFromArray:groupedAfterReadings];
    
    NSArray *markedReadings = [self markDataset:groupedReadings];
    
    // sort the array in ascending order
    NSSortDescriptor *sortByDayAverage = [NSSortDescriptor sortDescriptorWithKey:@"insightDatasetDayAverage" ascending:YES];
    NSArray *sortedReadings = [markedReadings sortedArrayUsingDescriptors:@[sortByDayAverage]];
    
    if (sortedReadings.count == 0) {
        // There is nothing to do.
    } else {
        [self.insightPoints addObjectsFromArray:sortedReadings];
        [self fetchDataFromHealthKitForItemsInInsightQueue];
    }
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
    NSNumber *pointValue = nil;
    
    NSArray *goodPoints = [insightPoints filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K == %@) AND (%K <> %@)",
                                                                      kInsightDatasetIsGoodDayKey, @(YES),
                                                                      kAPCInsightFactorValueKey, @(NSNotFound)]];
    NSArray *badPoints  = [insightPoints filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K == %@) AND (%K <> %@)",
                                                                      kInsightDatasetIsGoodDayKey, @(NO),
                                                                      kAPCInsightFactorValueKey, @(NSNotFound)]];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setMaximumFractionDigits:0];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundDown];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    if (goodPoints.count > 0) {
        pointValue = [goodPoints valueForKeyPath:@"@avg.insightFactorValueKey"];
        
        if ([self.insightFactorName isEqualToString:HKQuantityTypeIdentifierDietaryEnergyConsumed]) {
            if ([pointValue doubleValue] >= 1000) {
                caption = [NSString stringWithFormat:@"%@ %@",
                           [numberFormatter stringFromNumber:pointValue],
                           self.insightFactorCaption];
            } else {
                pointValue = @(0);
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
            if ([pointValue doubleValue] >= 1000) {
                caption = [NSString stringWithFormat:@"%@ %@",
                           [numberFormatter stringFromNumber:pointValue],
                           self.insightFactorCaption];
            } else {
                pointValue = @(0);
            }
        } else {
            caption = [NSString stringWithFormat:@"%@ %@",
                       [numberFormatter stringFromNumber:pointValue],
                       self.insightFactorCaption];
        }
        
        self.valueBad = pointValue;
        self.captionBad  = NSLocalizedString(caption, caption);
    }
    
    // Check if the difference between the good and bad vaules is at least 10%. Othewise don't show the insight.
    // The Steps and Calories are excluded from this comparion
    if ((self.insightFactorName != HKQuantityTypeIdentifierDietaryEnergyConsumed) && (self.insightFactorName != HKQuantityTypeIdentifierStepCount)) {
        double largerValue = ([self.valueGood doubleValue] > [self.valueBad doubleValue]) ? [self.valueGood doubleValue] : [self.valueBad doubleValue];
        double smallerValue = ([self.valueGood doubleValue] < [self.valueBad doubleValue]) ? [self.valueGood doubleValue] : [self.valueBad doubleValue];
        double differenceBetweenGoodAndBadValues = ((largerValue - smallerValue) / largerValue) * 100;
        
        if (differenceBetweenGoodAndBadValues < 10) {
            [self resetInsight];
        }
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
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@) and (%K = %@)", kDatasetDateKey, day, @"datasetRawData.period", period];
            NSArray *groupItems = [dataset filteredArrayUsingPredicate:predicate];
            double itemSum = 0;
            double dayAverage = 0;
            
            // Deviation from baseline
            for (NSDictionary *item in groupItems) {
                NSNumber *value = item[kDatasetValueKey];
                
                if ([value integerValue] != NSNotFound) {
                    double baseline = ([period isEqualToString:@"before"] ? kBaselinePreMeal : kBaselinePostMeal);
                    
                    itemSum += (baseline - [value doubleValue]); // This will be positive for in range and negative for out of range
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K <> %@)", kDatasetValueKey, @(NSNotFound)];
    NSArray *readings = [dataset filteredArrayUsingPredicate:predicate];
    NSArray *days = [readings valueForKeyPath:@"@distinctUnionOfObjects.datasetDateKey"];
    
    for (NSString *day in days) {
        NSMutableDictionary *dayReading = [NSMutableDictionary new];
        [dayReading setObject:day forKey:kDatasetDateKey];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@)", kDatasetDateKey, day];
        NSArray *groupedReadings = [readings filteredArrayUsingPredicate:predicate];
        NSMutableArray *avgReadingsForTheDay = [NSMutableArray new];
        
        for (NSDictionary *reading in groupedReadings) {
            NSNumber *average = reading[kDatasetValueKey];
            
            if ([average isEqualToNumber:@(NSNotFound)] == NO) {
                [avgReadingsForTheDay addObject:average];
            }
        }
        
        NSNumber *dayAverage = [avgReadingsForTheDay valueForKeyPath:@"@avg.self"];
        BOOL isGoodDay;
        
        if ([dayAverage doubleValue] > 0) {
            isGoodDay = YES; // Good day == reading deviation is positive/in-range
        } else {
            isGoodDay = NO;  // Bad day  == reading deviation is negative/out-of-range
        }
        
        [dayReading setObject:avgReadingsForTheDay forKey:kInsightDatasetAverageReadingKey];
        [dayReading setObject:(dayAverage != nil) ? dayAverage: @(0) forKey:kInsightDatasetDayAverage];
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

- (void)resetInsight
{
    self.captionGood = NSLocalizedString(@"Not enough data", @"Not enough data");
    self.captionBad  = NSLocalizedString(@"Not enough data", @"Not enough data");
    self.valueGood = @(0);
    self.valueBad  = @(0);
    
    [self.insightPoints removeAllObjects];
    [self.insightPointValues removeAllObjects];
}

@end
