//
//  APHScoring.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "APCScoring.h"
#import "APCAppCore.h"

static NSDateFormatter *dateFormatter = nil;

static NSString *const kDatasetDateKey  = @"datasetDateKey";
static NSString *const kDatasetValueKey = @"datasetValueKey";
static NSString *const kDatasetSortKey = @"datasetSortKey";

@interface APCScoring()

@property (nonatomic, strong) NSMutableArray *dataPoints;
@property (nonatomic, strong) NSMutableArray *correlateDataPoints;
@property (nonatomic) NSUInteger current;
@property (nonatomic) NSUInteger correlatedCurrent;
@property (nonatomic) BOOL hasCorrelateDataPoints;
@property (nonatomic, strong) HKHealthStore *healthStore;

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

- (void)sharedInit
{
    _dataPoints = [NSMutableArray array];
    _correlateDataPoints = [NSMutableArray array];
    _hasCorrelateDataPoints = NO; //(correlateKind != APHDataKindNone);
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
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

- (instancetype)initWithTask:(NSString *)taskId numberOfDays:(NSUInteger)numberOfDays valueKey:(NSString *)valueKey
{
    self = [self initWithTask:taskId numberOfDays:numberOfDays valueKey:valueKey dataKey:nil sortKey:nil];
    
    return self;
}

- (instancetype)initWithTask:(NSString *)taskId numberOfDays:(NSUInteger)numberOfDays valueKey:(NSString *)valueKey dataKey:(NSString *)dataKey
{
    self = [self initWithTask:taskId numberOfDays:numberOfDays valueKey:valueKey dataKey:dataKey sortKey:nil];
    
    return self;
}

- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSUInteger)numberOfDays
                    valueKey:(NSString *)valueKey
                     dataKey:(NSString *)dataKey
                     sortKey:(NSString *)sortKey
{
    self = [super init];
    
    if (self) {
        [self sharedInit];
        [self queryTaskId:taskId forDays:numberOfDays valueKey:valueKey dataKey:dataKey sortKey:sortKey];
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
                                 numberOfDays:(NSUInteger)numberOfDays
{
    self = [super init];
    
    if (self) {
        [self sharedInit];
        
        // The very first thing that we need to make sure is that
        // the unit and quantity types are compatible
        if ([quantityType isCompatibleWithUnit:unit]) {
            [self statsCollectionQueryForQuantityType:quantityType unit:unit forDays:numberOfDays];
        } else {
            NSAssert([quantityType isCompatibleWithUnit:unit], @"The quantity and the unit must be compatible");
        }
    }
    
    return self;
}

#pragma mark - Queries
#pragma mark Core Data

- (void)queryTaskId:(NSString *)taskId
            forDays:(NSUInteger)days
           valueKey:(NSString *)valueKey
            dataKey:(NSString *)dataKey
            sortKey:(NSString *)sortKey
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
                if (!dataKey) {
                    [self.dataPoints addObject:@{
                                                 kDatasetDateKey: task.startOn,
                                                 kDatasetValueKey: [taskResult valueForKey:valueKey],
                                                 kDatasetSortKey: (sortKey) ? [taskResult valueForKey:sortKey] : [NSNull null]
                                                 }];
                } else {
                    NSDictionary *nestedData = [taskResult valueForKey:dataKey];
                    
                    if (nestedData) {
                        [self.dataPoints addObject:@{
                                                     kDatasetDateKey: task.startOn,
                                                     kDatasetValueKey: [nestedData valueForKey:valueKey],
                                                     kDatasetSortKey: (sortKey) ? [taskResult valueForKey:sortKey] : [NSNull null]
                                                     }];
                    }
                }
            }
        }
    }
    
    if (sortKey) {
        NSSortDescriptor *sortBy = [[NSSortDescriptor alloc] initWithKey:kDatasetSortKey ascending:YES];
        NSArray *sortedDataPoints = [self.dataPoints sortedArrayUsingDescriptors:@[sortBy]];
        
        self.dataPoints = [sortedDataPoints mutableCopy];
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

#pragma mark HealthKit

- (void)statsCollectionQueryForQuantityType:(HKQuantityType *)quantityType
                                       unit:(HKUnit *)unit
                                    forDays:(NSInteger)days
{
    NSMutableArray *queryDataset = [NSMutableArray array];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;
    
    NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                 minute:0
                                                                 second:0
                                                                 ofDate:[self dateForSpan:days]
                                                                options:0];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:[NSDate date] options:HKQueryOptionStrictStartDate];
    
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
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSDate *endDate = [[NSCalendar currentCalendar] dateBySettingHour:23
                                                                       minute:59
                                                                       second:59
                                                                       ofDate:[NSDate date]
                                                                      options:0];
            NSDate *beginDate = startDate;
            
            [results enumerateStatisticsFromDate:beginDate
                                          toDate:endDate
                                       withBlock:^(HKStatistics *result, BOOL *stop) {
                                           HKQuantity *quantity = result.sumQuantity;
                                           
                                           if (quantity) {
                                               NSDate *date = result.startDate;
                                               double value = [quantity doubleValueForUnit:unit];
                                               
                                               NSDictionary *dataPoint = @{
                                                                           kDatasetDateKey: [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle],
                                                                           kDatasetValueKey: [NSNumber numberWithDouble:value]
                                                                           };
                                               
                                               [queryDataset addObject:dataPoint];
                                           }
                                       }];
            
            [self dataIsAvailableFromHealthKit:queryDataset];
        }
    };
    
    [self.healthStore executeQuery:query];
}

- (void)dataIsAvailableFromHealthKit:(NSArray *)dataset
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataPoints = [dataset mutableCopy];
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


- (NSNumber *)minimumDataPoint
{
    return [self.dataPoints valueForKeyPath:@"@min.datasetValueKey"];
}

- (NSNumber *)maximumDataPoint
{
    return [self.dataPoints valueForKeyPath:@"@max.datasetValueKey"];
}

- (NSNumber *)averageDataPoint
{
    NSLog(@"Avg. %lu", [[self.dataPoints valueForKeyPath:@"@avg.datasetValueKey"] integerValue]);
    return [self.dataPoints valueForKeyPath:@"@avg.datasetValueKey"];
}

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

#pragma mark - Graph Datasource

- (NSInteger)lineGraph:(APCLineGraphView *)graphView numberOfPointsInPlot:(NSInteger)plotIndex
{
    NSInteger numberOfPoints = 0;
    
    if (plotIndex == 0) {
        numberOfPoints = [self.dataPoints count];
    } else {
        numberOfPoints = [self.correlateDataPoints count];
    }
    return numberOfPoints;
}

- (NSInteger)numberOfPlotsInLineGraph:(APCLineGraphView *)graphView
{
    NSUInteger numberOfPlots = 1;
    
    if (self.hasCorrelateDataPoints) {
        numberOfPlots = 2;
    }
    return numberOfPlots;
}

- (CGFloat)minimumValueForLineGraph:(APCLineGraphView *)graphView
{
    return [[self minimumDataPoint] doubleValue];
}

- (CGFloat)maximumValueForLineGraph:(APCLineGraphView *)graphView
{
    return [[self maximumDataPoint] doubleValue];
}

- (CGFloat)lineGraph:(APCLineGraphView *)graphView plot:(NSInteger)plotIndex valueForPointAtIndex:(NSInteger)pointIndex
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


@end