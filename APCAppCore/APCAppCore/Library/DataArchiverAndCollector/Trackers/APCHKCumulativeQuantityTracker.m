//
//  APCHKCumulativeQuantityTracker.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCHKCumulativeQuantityTracker.h"
#import "APCAppCore.h"

static NSString *const kAnchorDateFilename = @"anchorDate";

@interface APCHKCumulativeQuantityTracker ()
{
    NSDate * _anchorDate;
}

@property (nonatomic, strong) NSDateComponents * interval;
@property (nonatomic, strong) HKQuantityType * quantityType;
@property (nonatomic, strong) NSDate * anchorDate;

@property (nonatomic, readonly) HKHealthStore * healthStore;

@property (nonatomic, readonly) NSString* anchorDateFilePath;
@property (nonatomic) BOOL queryStarted;

@end

@implementation APCHKCumulativeQuantityTracker

- (instancetype) initWithIdentifier:(NSString *)identifier quantityTypeIdentifier: (NSString*) quantityTypeIdentifier interval: (NSDateComponents*) interval
{
    self = [super initWithIdentifier:identifier];
    if (self) {
        _quantityType = [HKObjectType quantityTypeForIdentifier:quantityTypeIdentifier];
        _interval = interval;
        
    }
    return self;
}

- (HKHealthStore *)healthStore
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.healthStore;
}

- (NSArray *)columnNames
{
    return @[@"startDate", @"endDate", @"dataType", @"data", @"unit"];
}

- (void)startTracking
{
    [self updateTracking];
}

- (void)updateTracking
{
    if ([HKHealthStore isHealthDataAvailable]) {
        
        [self mainDataQuery];
    }
}

- (void) mainDataQuery
{
    if (!self.queryStarted) {
        if (self.anchorDate < [NSDate todayAtMidnight]) {
            NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:self.anchorDate endDate:[NSDate todayAtMidnight] options:HKQueryOptionNone];
            HKStatisticsCollectionQuery * collectionQuery = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:self.quantityType
                                                                                              quantitySamplePredicate:predicate
                                                                                                              options:HKStatisticsOptionCumulativeSum
                                                                                                           anchorDate:self.anchorDate
                                                                                                   intervalComponents:self.interval];
            
            __weak APCHKCumulativeQuantityTracker * weakSelf = self;
            
            collectionQuery.initialResultsHandler = ^(HKStatisticsCollectionQuery * __unused query,
                                                      HKStatisticsCollection *results,
                                                      NSError *error)
            {
                weakSelf.queryStarted = NO;
                if (!error) {
                    [weakSelf processStatisticsCollection:results];
                }
            };

            self.queryStarted = YES;
            [self.healthStore executeQuery:collectionQuery];
        }
    }
}

- (void) processStatisticsCollection: (HKStatisticsCollection*) collection
{
    NSMutableArray * results = [NSMutableArray array];
    
    [collection.statistics enumerateObjectsUsingBlock: ^(HKStatistics * obj,
                                                         NSUInteger __unused idx,
                                                         BOOL * __unused stop)
     {
        if (!self.unitForTracker) {
            NSAssert(NO, @"unitForTracker missing");
        }
        HKUnit * unit = self.unitForTracker;
        
        NSArray * result = @[obj.startDate.description?:@"No start date", obj.endDate.description?:@"No end date", self.quantityType.identifier?:@"No identifier", @([[obj sumQuantity] doubleValueForUnit:unit])?:@0,unit.unitString?:@"no unit"];
        [results addObject:result];

    }];

    [self.delegate APCDataTracker:self hasNewData:results];
    self.anchorDate = [NSDate todayAtMidnight];
}

/*********************************************************************************/
#pragma mark - Anchor Date
/*********************************************************************************/
- (NSString *)anchorDateFilePath
{
    return [self.folder stringByAppendingPathComponent:kAnchorDateFilename];
}

- (void)setAnchorDate:(NSDate *)anchorDate
{
    _anchorDate = anchorDate;
    [self writeAnchorDate:anchorDate];
}

- (NSDate *)anchorDate
{
    if (!_anchorDate) {
        if (self.folder) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:self.anchorDateFilePath]) {
                NSError * error;
                NSString * anchorDateString = [NSString stringWithContentsOfFile:self.anchorDateFilePath encoding:NSUTF8StringEncoding error:&error];
                APCLogError2(error);
                _anchorDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[anchorDateString doubleValue]];
            }
            else
            {
                _anchorDate = [NSDate todayAtMidnight];
                [self writeAnchorDate:_anchorDate];
            }
        }
        
    }
    return _anchorDate;
}

- (void) writeAnchorDate: (NSDate*) date
{
    NSString * anchorDateString = [NSString stringWithFormat:@"%0.0f",[date timeIntervalSinceReferenceDate]];
    [APCPassiveDataCollector createOrReplaceString:anchorDateString toFile:self.anchorDateFilePath];
}


@end
