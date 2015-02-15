//
//  APHScoring.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "APCScoring.h"
#import "APCAppCore.h"

static NSDateFormatter *dateFormatter = nil;

NSString *const kDatasetDateKey        = @"datasetDateKey";
NSString *const kDatasetValueKey       = @"datasetValueKey";
static NSString *const kDatasetSortKey        = @"datasetSortKey";
static NSString *const kDatasetValueKindKey   = @"datasetValueKindKey";
static NSString *const kDatasetValueNoDataKey = @"datasetValueNoDataKey";
static NSString *const kDatasetGroupByDay     = @"datasetGroupByDay";
static NSString *const kDatasetGroupByWeek    = @"datasetGroupByWeek";
static NSString *const kDatasetGroupByMonth   = @"datasetGroupByMonth";
static NSString *const kDatasetGroupByYear    = @"datasetGroupByYear";

@interface APCScoring()

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) NSMutableArray *dataPoints;
@property (nonatomic, strong) NSMutableArray *updatedDataPoints;
@property (nonatomic, strong) NSMutableArray *correlateDataPoints;
@property (nonatomic, strong) NSArray *timeline;

@property (nonatomic) NSUInteger current;
@property (nonatomic) NSUInteger correlatedCurrent;
@property (nonatomic) BOOL hasCorrelateDataPoints;
@property (nonatomic) BOOL usesHealthKitData;

@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, strong) NSString *valueKey;
@property (nonatomic, strong) NSString *dataKey;
@property (nonatomic, strong) NSString *sortKey;

@property (nonatomic, strong) HKQuantityType *quantityType;
@property (nonatomic, strong) HKUnit *hkUnit;

@end

@implementation APCScoring

/*
 * @usage  APHScoring.h should be imported.
 *
 *   There are two ways to get data, Core Data and HealthKit. Each source can
 *
 *   For Core Data:
 *      APHScoring *scoring = [APHScoring alloc] initWithTaskId:taskId numberOfDays:-5 valueKey:@"value";
 *
 *   For HealthKit:
 *      APHScoring *scoring = [APHScoring alloc] initWithHealthKitQuantityType:[HKQuantityType ...] numberOfDays:-5
 *
 *   NSLog(@"Score Min: %f", [[scoring minimumDataPoint] doubleValue]);
 *   NSLog(@"Score Max: %f", [[scoring maximumDataPoint] doubleValue]);
 *   NSLog(@"Score Avg: %f", [[scoring averageDataPoint] doubleValue]);
 *
 *   NSDictionary *score = nil;
 *   while (score = [scoring nextObject]) {
 *       NSLog(@"Score: %f", [[score valueForKey:@"value"] doubleValue]);
 *   }
 */

- (void)sharedInit:(NSInteger)days
{
    _dataPoints = [NSMutableArray array];
    _updatedDataPoints = [NSMutableArray array];
    _correlateDataPoints = [NSMutableArray array];
    _hasCorrelateDataPoints = NO;
    _usesHealthKitData = YES;
    
    _quantityType = nil;
    _hkUnit = nil;
    
    _taskId = nil;
    _valueKey = nil;
    _dataKey = nil;
    _sortKey = nil;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    
    _timeline = [self configureTimelineForDays:days groupBy:APHTimelineGroupDay]; //[self configureTimelineForDays:days];
    
    [self generateEmptyDataset];
}

- (HKHealthStore *)healthStore
{
    return ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.healthStore;
}

/**
 * @brief   Returns an instance of APHScoring.
 *
 * @param   taskId          The ID of the task whoes data needs to be displayed
 *
 * @param   numberOfDays    Number of days that the data is needed. Negative will produce data
 *                          from past and positive will yeild future days.
 *
 * @param   valueKey        The key that is used for storing data
 *
 */

- (instancetype)initWithTask:(NSString *)taskId numberOfDays:(NSInteger)numberOfDays valueKey:(NSString *)valueKey
{
    self = [self initWithTask:taskId numberOfDays:numberOfDays valueKey:valueKey dataKey:nil sortKey:nil groupBy:APHTimelineGroupDay];
    
    return self;
}

- (instancetype)initWithTask:(NSString *)taskId numberOfDays:(NSInteger)numberOfDays valueKey:(NSString *)valueKey dataKey:(NSString *)dataKey
{
    self = [self initWithTask:taskId numberOfDays:numberOfDays valueKey:valueKey dataKey:dataKey sortKey:nil groupBy:APHTimelineGroupDay];
    
    return self;
}

- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSInteger)numberOfDays
                    valueKey:(NSString *)valueKey
                     dataKey:(NSString *)dataKey
                     sortKey:(NSString *)sortKey
{
    self = [self initWithTask:taskId
                 numberOfDays:numberOfDays
                     valueKey:valueKey
                      dataKey:dataKey
                      sortKey:sortKey
                   groupBy:APHTimelineGroupDay];
    
    return self;
}

- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSInteger)numberOfDays
                    valueKey:(NSString *)valueKey
                     dataKey:(NSString *)dataKey
                     sortKey:(NSString *)sortKey
                  groupBy:(APHTimelineGroups)groupBy
{
    self = [super init];
    
    if (self) {
        NSInteger days = numberOfDays + 1;
        [self sharedInit:days];
        
        _usesHealthKitData = NO;
        
        _taskId = taskId;
        _valueKey = valueKey;
        _dataKey = dataKey;
        _sortKey = sortKey;
        
        [self queryTaskId:taskId forDays:days valueKey:valueKey dataKey:dataKey sortKey:sortKey groupBy:groupBy];
    }
    
    return self;
}

/**
 * @brief   Returns an instance of APHScoring.
 *
 * @param   quantityType    The HealthKit quantity type.
 *
 * @param   unit            The unit that is compatible with the the quantity type that is provided.
 *
 * @param   numberOfDays    Number of days that the data is needed. Negative will produce data
 *                          from past and positive will yeild future days.
 *
 */
- (instancetype)initWithHealthKitQuantityType:(HKQuantityType *)quantityType
                                         unit:(HKUnit *)unit
                                 numberOfDays:(NSInteger)numberOfDays
{
    self = [self initWithHealthKitQuantityType:quantityType
                                          unit:unit
                                  numberOfDays:numberOfDays
                                       groupBy:APHTimelineGroupDay];
    return self;
}

- (instancetype)initWithHealthKitQuantityType:(HKQuantityType *)quantityType
                                         unit:(HKUnit *)unit
                                 numberOfDays:(NSInteger)numberOfDays
                                      groupBy:(APHTimelineGroups) __unused groupBy
{
    self = [super init];
    
    if (self) {
        NSInteger days = numberOfDays + 1;
        [self sharedInit:days];
        
        // The very first thing that we need to make sure is that
        // the unit and quantity types are compatible
        if ([quantityType isCompatibleWithUnit:unit]) {
            _quantityType = quantityType;
            _hkUnit = unit;
            [self statsCollectionQueryForQuantityType:quantityType unit:unit forDays:days];
        } else {
            NSAssert([quantityType isCompatibleWithUnit:unit], @"The quantity and the unit must be compatible");
        }
    }
    
    return self;
}

- (void)updatePeriodForDays:(NSInteger)numberOfDays
                    groupBy:(APHTimelineGroups)groupBy
      withCompletionHandler:(void (^)(void))completion
{
    NSInteger days = numberOfDays + 1;
    
    if (self.usesHealthKitData) {
        if ([self.quantityType isCompatibleWithUnit:self.hkUnit]) {
            
            [self updateStatsCollectionForQuantityType:self.quantityType
                                                  unit:self.hkUnit
                                               forDays:days
                                               groupBy:groupBy
                                            completion:completion];
        } else {
            NSAssert([self.quantityType isCompatibleWithUnit:self.hkUnit], @"The quantity and the unit must be compatible");
        }
    } else {
        self.timeline = [self configureTimelineForDays:numberOfDays groupBy:groupBy];
        
        [self queryTaskId:self.taskId
                    forDays:days
                 valueKey:self.valueKey
                  dataKey:self.dataKey
                  sortKey:self.sortKey
                  groupBy:groupBy];
    }
}

#pragma mark - Helpers

- (NSArray *)configureTimelineForDays:(NSInteger)days
{
    NSMutableArray *timeline = [NSMutableArray array];
    
    for (NSInteger day = days; day <= 0; day++) {
        NSDate *timelineDate = [self dateForSpan:day];
        [timeline addObject:timelineDate];
    }
    
    return timeline;
}

- (NSArray *)configureTimelineForDays:(NSInteger)days groupBy:(NSUInteger)groupBy
{
    NSMutableArray *timeline = [NSMutableArray array];
    
    if (groupBy == APHTimelineGroupDay) {
        for (NSInteger day = days; day <= 0; day++) {
            NSDate *timelineDate = [self dateForSpan:day];
            [timeline addObject:timelineDate];
        }
    } else if (groupBy == APHTimelineGroupWeek) {
        for (NSInteger day = days; day <= 0; day += 7) {
            NSDate *timelineDate = [self dateForSpan:day];
            [timeline addObject:timelineDate];
        }
    } else if (groupBy == APHTimelineGroupMonth) {
        for (NSInteger day = days; day <= 0; day += 30) {
            NSDate *timelineDate = [self dateForSpan:day];
            [timeline addObject:timelineDate];
        }
    } else {
        for (NSInteger day = days; day <= 0; day += 365) {
            NSDate *timelineDate = [self dateForSpan:day];
            [timeline addObject:timelineDate];
        }
    }
    
    return timeline;
}

- (void)generateEmptyDataset
{
    for (NSDate *day in self.timeline) {
        NSDate *timelineDay = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                       minute:0
                                                                       second:0
                                                                       ofDate:day
                                                                      options:0];
        
        [self.dataPoints addObject:[self generateDataPointForDate:timelineDay
                                                        withValue:@(NSNotFound)
                                                      noDataValue:YES]];
    }
}

- (NSDictionary *)generateDataPointForDate:(NSDate *)pointDate
                                 withValue:(NSNumber *)pointValue
                               noDataValue:(BOOL)noDataValue
{
    NSInteger weekNumber  = [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfYear fromDate:pointDate] weekOfYear];
    NSInteger monthNumber = [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:pointDate] month];
    NSInteger yearNumber  = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:pointDate] year];
    
    return @{
             kDatasetDateKey: pointDate,
             kDatasetValueKey: pointValue,
             kDatasetValueNoDataKey: @(noDataValue),
             kDatasetGroupByDay: pointDate,
             kDatasetGroupByWeek: @(weekNumber),
             kDatasetGroupByMonth: @(monthNumber),
             kDatasetGroupByYear: @(yearNumber)
             };
}

- (void)addDataPointToTimeline:(NSDictionary *)dataPoint
{
    if ([dataPoint[kDatasetValueKey] integerValue] != 0) {
        NSDate *pointDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                     minute:0
                                                                     second:0
                                                                     ofDate:[dataPoint valueForKey:kDatasetDateKey]
                                                                    options:0];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", kDatasetDateKey, pointDate];
        NSArray *matches = [self.dataPoints filteredArrayUsingPredicate:predicate];
        
        if ([matches count] > 0) {
            NSUInteger pointIndex = [self.dataPoints indexOfObject:[matches firstObject]];
            NSMutableDictionary *point = [[self.dataPoints objectAtIndex:pointIndex] mutableCopy];
            
            point[kDatasetValueKey] = dataPoint[kDatasetValueKey];
            point[kDatasetValueNoDataKey] = dataPoint[kDatasetValueNoDataKey];
            
            [self.dataPoints replaceObjectAtIndex:pointIndex withObject:point];
        }
    }
}

#pragma mark - Queries
#pragma mark Core Data

- (void)queryTaskId:(NSString *)taskId
            forDays:(NSInteger)days
           valueKey:(NSString *)valueKey
            dataKey:(NSString *)dataKey
            sortKey:(NSString *)sortKey
         groupBy:(APHTimelineGroups)groupBy
{
    APCAppDelegate *appDelegate = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startOn"
                                                                   ascending:YES];
    
    NSFetchRequest *request = [APCScheduledTask request];
    
    NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                 minute:0
                                                                 second:0
                                                                 ofDate:[self dateForSpan:days]
                                                                options:0];
    
    NSDate *endDate = [[NSCalendar currentCalendar] dateBySettingHour:23
                                                               minute:59
                                                               second:59
                                                               ofDate:[NSDate date]
                                                              options:0];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(task.taskID == %@) AND (startOn >= %@) AND (startOn <= %@)",
                              taskId, startDate, endDate];
    
    request.predicate = predicate;
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error = nil;
    NSArray *tasks = [appDelegate.dataSubstrate.mainContext executeFetchRequest:request error:&error];
    
    for (APCScheduledTask *task in tasks) {
        if ([task.completed boolValue]) {
            NSDictionary *taskResult = [self retrieveResultSummaryFromResults:task.results];
            
            if (taskResult) {
                NSDate *pointDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                             minute:0
                                                                             second:0
                                                                             ofDate:task.startOn
                                                                            options:0];
                
                id taskResultValue = [taskResult valueForKey:valueKey];
                NSNumber *taskValue = nil;
                
                if ([taskResultValue isKindOfClass:[NSNull class]] || !taskResultValue) {
                    taskValue = @(NSNotFound);
                } else {
                    taskValue = (NSNumber *)taskResultValue;
                }
                
                NSMutableDictionary *dataPoint = nil;
                
                if (groupBy == APHTimelineGroupForInsights) {
                    dataPoint = [[self generateDataPointForDate:pointDate
                                                      withValue:taskValue
                                                    noDataValue:YES] mutableCopy];
                    dataPoint[@"raw"] = taskResult;
                } else {
                    if (!dataKey) {
                        dataPoint = [[self generateDataPointForDate:pointDate
                                                          withValue:taskValue
                                                        noDataValue:YES] mutableCopy];
                        dataPoint[kDatasetSortKey] = (sortKey) ? [taskResult valueForKey:sortKey] : [NSNull null];
                        
                    } else {
                        NSDictionary *nestedData = [taskResult valueForKey:dataKey];
                        
                        if (nestedData) {
                            dataPoint = [[self generateDataPointForDate:pointDate
                                                              withValue:taskValue
                                                            noDataValue:YES] mutableCopy];
                            dataPoint[kDatasetSortKey] = (sortKey) ? [taskResult valueForKey:sortKey] : [NSNull null];
                        }
                    }
                }
                [self.dataPoints addObject:dataPoint];
            }
        }
    }
    
    if ([self.dataPoints count] != 0) {
        if (sortKey) {
            NSSortDescriptor *sortBy = [[NSSortDescriptor alloc] initWithKey:kDatasetSortKey ascending:YES];
            NSArray *sortedDataPoints = [self.dataPoints sortedArrayUsingDescriptors:@[sortBy]];
            
            self.dataPoints = [sortedDataPoints mutableCopy];
        }
        
        if (groupBy == APHTimelineGroupDay) {
            [self groupDatasetByDay];
        }
    }
}

- (NSDictionary *)retrieveResultSummaryFromResults:(NSSet *)results
{
    NSDictionary *result = nil;
    NSArray *scheduledTaskResults = [results allObjects];
    
    // sort the results in a decsending order,
    // in case there are more than one result for a meal time.
    NSSortDescriptor *sortByCreateAtDescending = [[NSSortDescriptor alloc] initWithKey:@"createdAt"
                                                                             ascending:YES];
    
    NSArray *sortedScheduleTaskresults = [scheduledTaskResults sortedArrayUsingDescriptors:@[sortByCreateAtDescending]];
    
    // We are iterating throught the results because:
    // a.) There could be more than one result
    // b.) In case the last result is nil, we will pick the next result that has a value.
    NSString *resultSummary = nil;
    
    for (APCResult *result in sortedScheduleTaskresults) {
        resultSummary = [result resultSummary];
        if (resultSummary) {
            break;
        }
    }
    
    if (resultSummary) {
        NSData *resultData = [resultSummary dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        result = [NSJSONSerialization JSONObjectWithData:resultData
                                                 options:NSJSONReadingAllowFragments
                                                   error:&error];
    }
    
    return result;
}

- (void)groupDatasetByDay
{
    NSMutableArray *groupedDataset = [NSMutableArray array];
    NSArray *days = [self.dataPoints valueForKeyPath:@"@distinctUnionOfObjects.datasetDateKey"];
    
    for (NSString *day in days) {
        NSMutableDictionary *entry = [NSMutableDictionary dictionary];
        [entry setObject:day forKey:kDatasetDateKey];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@) and (%K <> %@)", kDatasetDateKey, day, kDatasetValueKey, @(NSNotFound)];
        NSArray *groupItems = [self.dataPoints filteredArrayUsingPredicate:predicate];
        double itemSum = 0;
        double dayAverage = 0;
        
        for (NSDictionary *item in groupItems) {
            NSNumber *value = [item valueForKey:kDatasetValueKey];
            
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
        
        [groupedDataset addObject:entry];
    }
    
    // resort the grouped dataset by date
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:kDatasetDateKey
                                                               ascending:YES];
    [groupedDataset sortUsingDescriptors:@[sortByDate]];
    
    [self.dataPoints removeAllObjects];
    [self.dataPoints addObjectsFromArray:groupedDataset];
}

#pragma mark HealthKit

- (void)statsCollectionQueryForQuantityType:(HKQuantityType *)quantityType
                                       unit:(HKUnit *)unit
                                    forDays:(NSInteger)days
{
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;
    
    NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                 minute:0
                                                                 second:0
                                                                 ofDate:[self dateForSpan:days]
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
                                                                       ofDate:[NSDate date]
                                                                      options:0];
            NSDate *beginDate = startDate;
            
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
                                           
                                           NSDictionary *dataPoint = @{
                                                                       kDatasetDateKey: date,
                                                                       kDatasetValueKey: (!quantity) ? @(NSNotFound) : @(value),
                                                                       kDatasetValueNoDataKey: (isDecreteQuantity) ? @(YES) : @(NO)
                                                                       };
                                           
                                           [self addDataPointToTimeline:dataPoint];
                                       }];
            
            [self dataIsAvailableFromHealthKit];
        }
    };
    
    [self.healthStore executeQuery:query];
}

- (void)updateStatsCollectionForQuantityType:(HKQuantityType *)quantityType
                                        unit:(HKUnit *)unit
                                     forDays:(NSInteger)days
                                     groupBy:(APHTimelineGroups)groupBy
                                  completion:(void (^)(void))completion
{
    [self.updatedDataPoints removeAllObjects];
    
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    
    // 5D, 1W, 1M, 3M, 6M, 1Y
    if (groupBy == APHTimelineGroupDay) {
        interval.day = 1;
    } else if (groupBy == APHTimelineGroupWeek) {
        interval.day = 7;
    } else if (groupBy == APHTimelineGroupMonth) {
        interval.month = 1;
    } else {
        interval.year = 1;
    }
    
    NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                 minute:0
                                                                 second:0
                                                                 ofDate:[self dateForSpan:days]
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
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery * __unused query, HKStatisticsCollection *results, NSError *error) {
        if (!error) {
            NSDate *endDate = [[NSCalendar currentCalendar] dateBySettingHour:23
                                                                       minute:59
                                                                       second:59
                                                                       ofDate:[NSDate date]
                                                                      options:0];
            NSDate *beginDate = startDate;
            
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
                                           
                                           NSDictionary *dataPoint = @{
                                                                       kDatasetDateKey: date,
                                                                       kDatasetValueKey: (!quantity) ? @(NSNotFound) : @(value),
                                                                       kDatasetValueNoDataKey: (isDecreteQuantity) ? @(YES) : @(NO)
                                                                       };
                                           
                                           //[self addDataPointToTimeline:dataPoint];
                                           [self.updatedDataPoints addObject:dataPoint];
                                       }];
            
            [self.dataPoints removeAllObjects];
            
            // Redo the timeline
            NSMutableArray *updatedTimeline = [NSMutableArray new];
            
            for (NSDictionary *point in self.updatedDataPoints) {
                [updatedTimeline addObject:[point valueForKey:kDatasetDateKey]];
            }
            
            self.timeline = updatedTimeline;
            [self.dataPoints addObjectsFromArray:self.updatedDataPoints];
            
            if (completion) {
                completion();
            }
        }
    };
    
    [self.healthStore executeQuery:query];
}

- (void)dataIsAvailableFromHealthKit
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:APCScoringHealthKitDataIsAvailableNotification
                                                            object:self.dataPoints];
    });
}

/**
 * @brief   Returns an NSDate that is past/future by the value of daySpan.
 *
 * @param   daySpan Number of days relative to current date.
 *                  If negative, date will be number of days in the past;
 *                  otherwise the date will be number of days in the future.
 *
 * @return  Returns the date as NSDate.
 */
- (NSDate *)dateForSpan:(NSInteger)daySpan
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:daySpan];
    
    NSDate *spanDate = [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                                     toDate:[NSDate date]
                                                                    options:0];
    return spanDate;
}

#pragma mark - Min/Max/Avg

- (NSNumber *)minimumDataPoint
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K <> %@", kDatasetValueKey, @(NSNotFound)];
    NSArray *filteredArray = [self.dataPoints filteredArrayUsingPredicate:predicate];
    
    NSNumber *minValue = [filteredArray valueForKeyPath:@"@min.datasetValueKey"];
    
    return minValue;
}

- (NSNumber *)maximumDataPoint
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K <> %@", kDatasetValueKey, @(NSNotFound)];
    NSArray *filteredArray = [self.dataPoints filteredArrayUsingPredicate:predicate];
    
    NSNumber *maxValue = [filteredArray valueForKeyPath:@"@max.datasetValueKey"];
    
    return maxValue;
}

- (NSNumber *)averageDataPoint
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K <> %@", kDatasetValueKey, @(NSNotFound)];
    NSArray *filteredArray = [self.dataPoints filteredArrayUsingPredicate:predicate];
    
    NSNumber *avgValue = [filteredArray valueForKeyPath:@"@avg.datasetValueKey"];
    
    return avgValue;
}

#pragma mark - Object related methods

- (id)nextObject
{
    id nextPoint = nil;
    
    if (self.current < [self.dataPoints count]) {
        nextPoint = [self.dataPoints objectAtIndex:self.current++];
    } else {
        self.current = 0;
        nextPoint = [self.dataPoints objectAtIndex:self.current++];
    }

    return nextPoint;
}

- (id)nextCorrelatedObject
{
    id nextCorrelatedPoint = nil;
    
    if (self.correlatedCurrent < [self.correlateDataPoints count]) {
        nextCorrelatedPoint = [self.correlateDataPoints objectAtIndex:self.correlatedCurrent++];
    }
    
    return nextCorrelatedPoint;
}

- (NSArray *)allObjects
{
    return self.dataPoints;
}

#pragma mark - Graph Datasource

- (NSInteger)lineGraph:(APCLineGraphView *) __unused graphView numberOfPointsInPlot:(NSInteger)plotIndex
{
    NSInteger numberOfPoints = 0;
    
    if (plotIndex == 0) {
        numberOfPoints = [self.timeline count]; //[self.dataPoints count];
    } else {
        numberOfPoints = [self.correlateDataPoints count];
    }
    return numberOfPoints;
}

- (NSInteger)numberOfPlotsInLineGraph:(APCLineGraphView *) __unused graphView
{
    NSUInteger numberOfPlots = 1;
    
    if (self.hasCorrelateDataPoints) {
        numberOfPlots = 2;
    }
    return numberOfPlots;
}

- (CGFloat)minimumValueForLineGraph:(APCLineGraphView *) __unused graphView
{
    return [[self minimumDataPoint] doubleValue];
}

- (CGFloat)maximumValueForLineGraph:(APCLineGraphView *) __unused graphView
{
    return [[self maximumDataPoint] doubleValue];
}

- (CGFloat)lineGraph:(APCLineGraphView *) __unused graphView plot:(NSInteger)plotIndex valueForPointAtIndex:(NSInteger) __unused pointIndex
{
    CGFloat value;
    
    if (plotIndex == 0) {
        NSDictionary *point = [self nextObject];
        value = [[point valueForKey:kDatasetValueKey] doubleValue];
    } else {
        NSDictionary *correlatedPoint = [self nextCorrelatedObject];
        value = [[correlatedPoint valueForKey:kDatasetValueKey] doubleValue];
    }
    
    return value;
}

- (NSString *)lineGraph:(APCLineGraphView *) __unused graphView titleForXAxisAtIndex:(NSInteger)pointIndex
{
    NSDate *titleDate = nil;
    
    titleDate = [[self.dataPoints objectAtIndex:pointIndex] valueForKey:kDatasetDateKey];

    [dateFormatter setDateFormat:@"MMM d"];
    
    NSString *xAxisTitle = [dateFormatter stringFromDate:titleDate];
                            
    return xAxisTitle;
}


@end