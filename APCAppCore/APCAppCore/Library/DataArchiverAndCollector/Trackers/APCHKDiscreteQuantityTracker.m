// 
//  APCHKDiscreteQuantityTracker.m 
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
