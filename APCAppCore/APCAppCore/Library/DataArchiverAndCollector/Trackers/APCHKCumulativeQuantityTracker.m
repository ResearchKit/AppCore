// 
//  APCHKCumulativeQuantityTracker.m 
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
