//
//  APCHKCumulativeQuantityTracker.m
//  APCAppCore
//
//  Created by Dhanush Balachandran on 2/2/15.
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
@property (strong, nonatomic) HKObserverQuery *observerQuery;

@property (nonatomic, readonly) NSString* anchorDateFilePath;

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
    return @[@"startDate", @"endDate", @"dataType", @"data"];
}

- (void)startTracking
{
    if ([HKHealthStore isHealthDataAvailable]) {
        
        [self mainDataQuery];
    }
}

- (void) mainDataQuery
{
    if (self.anchorDate < [NSDate todayAtMidnight]) {
        NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:self.anchorDate endDate:nil options:HKQueryOptionNone];
        HKStatisticsCollectionQuery * collectionQuery = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:self.quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum anchorDate:self.anchorDate intervalComponents:self.interval];

        NSSortDescriptor *endDate = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];

        __weak APCHKCumulativeQuantityTracker * weakSelf = self;
        
        collectionQuery.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
            if (!error) {
                APCLogDebug(@"Results: %@", results.statistics);
                [weakSelf processStatisticsCollection:results];
            }
        };
        
        [self.healthStore executeQuery:collectionQuery];
    }

}

- (void) processStatisticsCollection: (HKStatisticsCollection*) collection
{
    
}

- (void)stopTracking
{
    [self.healthStore stopQuery:self.observerQuery];
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
                _anchorDate = [[NSDate date] dateByAddingDays:-2];
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
