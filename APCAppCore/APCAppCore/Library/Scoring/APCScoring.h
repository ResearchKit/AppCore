// 
//  APCScoring.h 
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
 
#import <HealthKit/HealthKit.h>
#import "APCLineGraphView.h"
#import "APCDiscreteGraphView.h"

extern NSString *const kDatasetDateKey;
extern NSString *const kDatasetValueKey;
extern NSString *const kDatasetRawDataKey;

typedef NS_ENUM(NSUInteger, APHTimelineGroups)
{
    APHTimelineGroupDay = 0,
    APHTimelineGroupWeek,
    APHTimelineGroupMonth,
    APHTimelineGroupYear,
    APHTimelineGroupForInsights
};

@class APCScoring;

@protocol APCScoringDelegate <NSObject>

-(void)graphViewControllerShouldUpdateChartWithScoring: (APCScoring *)scoring;

@end

@interface APCScoring : NSEnumerator <APCLineGraphViewDataSource, APCDiscreteGraphViewDataSource>

@property (nonatomic) CGFloat customMaximumPoint;
@property (nonatomic) CGFloat customMinimumPoint;

//APCScoring Delegate
@property (weak, nonatomic) id<APCScoringDelegate> scoringDelegate;

//Exposed for APCCorrelationsSelectorViewController
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *series1Name;
@property (nonatomic, strong) NSString *series2Name;
@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, strong) NSString *valueKey;
@property (nonatomic, strong) HKQuantityType *quantityType;
@property (nonatomic, strong) HKUnit *unit;

- (instancetype)initWithHealthKitQuantityType:(HKQuantityType *)quantityType
                                         unit:(HKUnit *)unit
                                 numberOfDays:(NSInteger)numberOfDays;

- (instancetype)initWithHealthKitQuantityType:(HKQuantityType *)quantityType
                                         unit:(HKUnit *)unit
                                 numberOfDays:(NSInteger)numberOfDays
                                      groupBy:(APHTimelineGroups)groupBy;

- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSInteger)numberOfDays
                    valueKey:(NSString *)valueKey;

- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSInteger)numberOfDays
                    valueKey:(NSString *)valueKey
                  latestOnly:(BOOL)latestOnly;

- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSInteger)numberOfDays
                    valueKey:(NSString *)valueKey
                     dataKey:(NSString *)dataKey;

- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSInteger)numberOfDays
                    valueKey:(NSString *)valueKey
                     dataKey:(NSString *)dataKey
                     sortKey:(NSString *)sortKey;

- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSInteger)numberOfDays
                    valueKey:(NSString *)valueKey
                     dataKey:(NSString *)dataKey
                     sortKey:(NSString *)sortKey
                     groupBy:(APHTimelineGroups)groupBy;

- (void)updatePeriodForDays:(NSInteger)numberOfDays
                    groupBy:(APHTimelineGroups)groupBy;

-(void)correlateWithScoringObject:(APCScoring *)scoring;

- (NSNumber *)minimumDataPoint;
- (NSNumber *)maximumDataPoint;
- (NSNumber *)averageDataPoint;
- (id)nextObject;
- (NSArray *)allObjects;
- (NSNumber *)numberOfDataPoints;
- (void)updateCharts;

@end
