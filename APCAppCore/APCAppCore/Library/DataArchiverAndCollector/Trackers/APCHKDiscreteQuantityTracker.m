//
//  APCHKQuantityTracker.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCHKDiscreteQuantityTracker.h"
#import "APCAppCore.h"

static NSString *const kAnchorDataFilename = @"anchorData";

@interface APCHKDiscreteQuantityTracker ()
{
    NSNumber * _anchorData;
}

@property (nonatomic, strong) NSDateComponents * interval;
@property (nonatomic, strong) HKSampleType * sampleType;
@property (nonatomic, strong) NSNumber * anchorData;

@property (nonatomic, readonly) HKHealthStore * healthStore;

@property (nonatomic, readonly) NSString* anchorDataFilePath;
@property (nonatomic) BOOL queryStarted;

@end

@implementation APCHKDiscreteQuantityTracker

- (instancetype) initWithIdentifier:(NSString *)identifier sampleType: (HKSampleType*) sampleType
{
    self = [super initWithIdentifier:identifier];
    if (self) {
        _sampleType = sampleType;
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
        NSPredicate *predicate;
        if (!self.anchorData || [self.anchorData integerValue] == 0) {
            predicate = [HKQuery predicateForSamplesWithStartDate:[NSDate todayAtMidnight] endDate:nil options:HKQueryOptionNone];
        }
        
        __weak APCHKDiscreteQuantityTracker * weakSelf = self;
        HKAnchoredObjectQuery * anchorQuery = [[HKAnchoredObjectQuery alloc] initWithType:self.sampleType
                                                                                predicate:predicate
                                                                                   anchor:[self.anchorData integerValue]
                                                                                    limit:HKObjectQueryNoLimit
                                                                        completionHandler:
                                               ^(HKAnchoredObjectQuery * __unused query, NSArray *results, NSUInteger newAnchor, NSError *error) {
                                                   weakSelf.queryStarted = NO;
                                                   if (!error) {
                                                       self.anchorData = @(newAnchor);
                                                       [weakSelf processResults:results];
                                                   }
                                               }];
        self.queryStarted = YES;
        [self.healthStore executeQuery:anchorQuery];
    }
}

- (void) processResults: (NSArray*) anchorResults
{
    NSMutableArray * results = [NSMutableArray array];
    
    [anchorResults enumerateObjectsUsingBlock:^(HKSample * sample, NSUInteger __unused idx, BOOL * __unused stop) {
        
        HKUnit * unit = self.unitForTracker;
        //NOTE: Currently only HKQuantitySample is supported. Other types may require a separate tracker.
        if ([sample isKindOfClass:[HKQuantitySample class]]) {
            HKQuantitySample * quantitySample = (HKQuantitySample*) sample;
            NSArray * result = @[quantitySample.startDate.description?:@"No start date", quantitySample.endDate.description?:@"No end date", self.sampleType.identifier?:@"No identifier", @([quantitySample.quantity doubleValueForUnit:unit])?:@0,unit.unitString?:@"no unit"];
            [results addObject:result];
        }
    }];
    [self.delegate APCDataTracker:self hasNewData:results];
}

/*********************************************************************************/
#pragma mark - Anchor Data
/*********************************************************************************/
- (NSString *)anchorDataFilePath
{
    return [self.folder stringByAppendingPathComponent:kAnchorDataFilename];
}

- (void)setAnchorData:(NSNumber*)anchorData
{
    _anchorData = anchorData;
    [self writeAnchorData:anchorData];
}

- (NSNumber*)anchorData
{
    if (!_anchorData) {
        if (self.folder) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:self.anchorDataFilePath]) {
                NSError * error;
                NSString * anchorDataString = [NSString stringWithContentsOfFile:self.anchorDataFilePath encoding:NSUTF8StringEncoding error:&error];
                APCLogError2(error);
                _anchorData = @([anchorDataString integerValue]);
            }
            else
            {
                _anchorData = @0;
                [self writeAnchorData:_anchorData];
            }
        }
        
    }
    return _anchorData;
}

- (void) writeAnchorData: (NSNumber*) data
{
    NSString * anchorDataString = [NSString stringWithFormat:@"%@",data];
    [APCPassiveDataCollector createOrReplaceString:anchorDataString toFile:self.anchorDataFilePath];
}

@end
