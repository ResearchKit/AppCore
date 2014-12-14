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
static NSString *const kDatasetValueKindKey = @"datasetValueKindKey";
static NSString *const kDatasetValueNoDataKey = @"datasetValueNoDataKey";

@interface APCScoring()

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) NSMutableArray *dataPoints;
@property (nonatomic, strong) NSMutableArray *correlateDataPoints;
@property (nonatomic, strong) NSArray *timeline;

@property (nonatomic) NSUInteger current;
@property (nonatomic) NSUInteger correlatedCurrent;
@property (nonatomic) BOOL hasCorrelateDataPoints;


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
    _correlateDataPoints = [NSMutableArray array];
    _hasCorrelateDataPoints = NO; //(correlateKind != APHDataKindNone);
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    
    _timeline = [self configureTimelineForDays:days];
    
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
    self = [self initWithTask:taskId numberOfDays:numberOfDays valueKey:valueKey dataKey:nil sortKey:nil groupByDay:NO];
    
    return self;
}

- (instancetype)initWithTask:(NSString *)taskId numberOfDays:(NSInteger)numberOfDays valueKey:(NSString *)valueKey dataKey:(NSString *)dataKey
{
    self = [self initWithTask:taskId numberOfDays:numberOfDays valueKey:valueKey dataKey:dataKey sortKey:nil groupByDay:NO];
    
    return self;
}

- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSInteger)numberOfDays
                    valueKey:(NSString *)valueKey
                     dataKey:(NSString *)dataKey
                     sortKey:(NSString *)sortKey
{
    self = [super init];
    
    if (self) {
        NSInteger days = numberOfDays + 1;
        [self sharedInit:days];
        [self queryTaskId:taskId forDays:days valueKey:valueKey dataKey:dataKey sortKey:sortKey groupByDay:NO];
    }
    
    return self;
}

- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSInteger)numberOfDays
                    valueKey:(NSString *)valueKey
                     dataKey:(NSString *)dataKey
                     sortKey:(NSString *)sortKey
                  groupByDay:(BOOL)groupByDay
{
    self = [super init];
    
    if (self) {
        NSInteger days = numberOfDays + 1;
        [self sharedInit:days];
        [self queryTaskId:taskId forDays:days valueKey:valueKey dataKey:dataKey sortKey:sortKey groupByDay:groupByDay];
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
    self = [super init];
    
    if (self) {
        NSInteger days = numberOfDays + 1;
        [self sharedInit:days];
        
        // The very first thing that we need to make sure is that
        // the unit and quantity types are compatible
        if ([quantityType isCompatibleWithUnit:unit]) {
            [self statsCollectionQueryForQuantityType:quantityType unit:unit forDays:days];
        } else {
            NSAssert([quantityType isCompatibleWithUnit:unit], @"The quantity and the unit must be compatible");
        }
    }
    
    return self;
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

- (void)generateEmptyDataset
{
    for (NSDate *day in self.timeline) {
        NSDate *timelineDay = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                       minute:0
                                                                       second:0
                                                                       ofDate:day
                                                                      options:0];
        [self.dataPoints addObject:@{
                                     kDatasetDateKey: timelineDay,
                                     kDatasetValueKey: @(0),
                                     kDatasetValueNoDataKey: @(NO)
                                     }];
    }
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
        
        if (matches) {
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
         groupByDay:(BOOL)groupByDay
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
            
            // remove the time from the startOn date
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            
            if (taskResult) {
                if (!dataKey) {
                    [self addDataPointToTimeline:@{
                                                    kDatasetDateKey: [dateFormatter stringFromDate:task.startOn],
                                                    kDatasetValueKey: [taskResult valueForKey:valueKey]?:@(0),
                                                    kDatasetSortKey: (sortKey) ? [taskResult valueForKey:sortKey] : [NSNull null],
                                                    kDatasetValueNoDataKey: @(YES)
                                                  }];
                } else {
                    NSDictionary *nestedData = [taskResult valueForKey:dataKey];
                    
                    if (nestedData) {
                        [self addDataPointToTimeline:@{
                                                        kDatasetDateKey: task.startOn,
                                                        kDatasetValueKey: [nestedData valueForKey:valueKey],
                                                        kDatasetSortKey: (sortKey) ? [taskResult valueForKey:sortKey] : [NSNull null],
                                                        kDatasetValueNoDataKey: @(YES)
                                                      }];
                    }
                }
            }
        }
    }
    
    if ([self.dataPoints count] != 0) {
        if (sortKey) {
            NSSortDescriptor *sortBy = [[NSSortDescriptor alloc] initWithKey:kDatasetSortKey ascending:YES];
            NSArray *sortedDataPoints = [self.dataPoints sortedArrayUsingDescriptors:@[sortBy]];
            
            self.dataPoints = [sortedDataPoints mutableCopy];
        }
        
        if (groupByDay) {
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

- (void)groupDatasetByDay //WithStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate
{
    NSMutableArray *groupedDataset = [NSMutableArray array];
    NSArray *days = [self.dataPoints valueForKeyPath:@"@distinctUnionOfObjects.datasetDateKey"];
    
    for (NSString *day in days) {
        NSMutableDictionary *entry = [NSMutableDictionary dictionary];
        [entry setObject:day forKey:kDatasetDateKey];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", kDatasetDateKey, day];
        NSArray *groupItems = [self.dataPoints filteredArrayUsingPredicate:predicate];
        double itemSum = 0;
        double dayAverage = 0;
        
        for (NSDictionary *item in groupItems) {
            NSNumber *value = [item valueForKey:kDatasetValueKey];
            
            itemSum += [value doubleValue];
        }
        
        if (groupItems.count != 0) {
            dayAverage = itemSum / groupItems.count;
        }
        
        [entry setObject:@(dayAverage) forKey:kDatasetValueKey];
        
        [groupedDataset addObject:entry];
    }
    
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
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
        if (!error) {
            NSDate *endDate = [[NSCalendar currentCalendar] dateBySettingHour:23
                                                                       minute:59
                                                                       second:59
                                                                       ofDate:[NSDate date]
                                                                      options:0];
            NSDate *beginDate = startDate;
            
            [results enumerateStatisticsFromDate:beginDate
                                          toDate:endDate
                                       withBlock:^(HKStatistics *result, BOOL *stop) {
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
                                                                       kDatasetValueKey: [NSNumber numberWithDouble:value],
                                                                       kDatasetValueNoDataKey: (isDecreteQuantity) ? @(YES) : @(NO)
                                                                       };
                                           
                                           [self addDataPointToTimeline:dataPoint];
                                       }];
            
            [self dataIsAvailableFromHealthKit];
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
        numberOfPoints = [self.timeline count]; //[self.dataPoints count];
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
        
        if ([[point valueForKey:kDatasetValueNoDataKey] boolValue] && value == 0) {
            value = NSNotFound;
        }
    } else {
        NSDictionary *correlatedPoint = [self nextCorrelatedObject];
        value = [[correlatedPoint valueForKey:kDatasetValueKey] doubleValue];
    }
    
    return value;
}

- (NSString *)lineGraph:(APCLineGraphView *)graphView titleForXAxisAtIndex:(NSInteger)pointIndex
{
    NSDate *titleDate = [[self.dataPoints objectAtIndex:pointIndex] valueForKey:kDatasetDateKey];

    [dateFormatter setDateFormat:@"MMM d"];
    
    NSString *xAxisTitle = [dateFormatter stringFromDate:titleDate];
                            
    return xAxisTitle;
}


@end