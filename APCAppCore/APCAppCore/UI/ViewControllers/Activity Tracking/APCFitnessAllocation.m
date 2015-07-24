// 
//  Activity 
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
 
#import "APCFitnessAllocation.h"
#import <CoreMotion/CoreMotion.h>
#import "APCTheme.h"

static NSDateFormatter *dateFormatter = nil;

NSString *const kDataset7DayDateKey         = @"datasetDateKey";
NSString *const kDataset7DayValueKey        = @"datasetValueKey";
NSString *const kDatasetSegmentNameKey  = @"datasetSegmentNameKey";
NSString *const kDatasetSegmentColorKey = @"datasetSegmentColorKey";

NSString *const kDatasetSegmentKey      = @"segmentKey";
NSString *const kDatasetDateHourKey     = @"dateHourKey";
NSString *const kSegmentSumKey          = @"segmentSumKey";

NSString *const kSevenDayFitnessStartDateKey  = @"sevenDayFitnessStartDateKey";

NSString *const APHSevenDayAllocationDataIsReadyNotification = @"APHSevenDayAllocationDataIsReadyNotification";
NSString *const APHSevenDayAllocationSleepDataIsReadyNotification = @"APHSevenDayAllocationSleepDataIsReadyNotification";
NSString *const APHSevenDayAllocationHealthKitDataIsReadyNotification = @"APHSevenDayAllocationHealthKitIsReadyNotification";

NSString *const kDatasetDateKeyFormat   = @"YYYY-MM-dd-hh";

typedef NS_ENUM(NSUInteger, SevenDayFitnessDatasetKinds)
{
    SevenDayFitnessDatasetKindToday = 0,
    SevenDayFitnessDatasetKindWeek,
    SevenDayFitnessDataSetKindYesterday
};

typedef NS_ENUM(NSUInteger, SevenDayFitnessQueryType)
{
    SevenDayFitnessQueryTypeWake = 0,
    SevenDayFitnessQueryTypeSleep,
    SevenDayFitnessQueryTypeTotal
};

@interface APCFitnessAllocation()

@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;

@property (nonatomic, strong) NSMutableArray *datasetForToday;
@property (nonatomic, strong) __block NSMutableArray *datasetForTheWeek;
@property (nonatomic, strong) NSMutableArray *datasetForYesterday;

@property (nonatomic, strong) NSMutableArray *datasetNormalized;

@property (nonatomic, strong) NSMutableArray *motionDatasetForToday;
@property (nonatomic, strong) __block NSMutableArray *motionDatasetForTheWeek;

@property (nonatomic, strong) __block NSMutableArray *sleepDataset;
@property (nonatomic, strong) __block NSMutableArray *wakeDataset;

@property (nonatomic, strong) NSDate *allocationStartDate;

@property (nonatomic, strong) NSString *segmentInactive;
@property (nonatomic, strong) NSString *segmentSedentary;
@property (nonatomic, strong) NSString *segmentModerate;
@property (nonatomic, strong) NSString *segmentVigorous;
@property (nonatomic, strong) NSString *segmentSleep;

@property (nonatomic, strong) __block NSMutableArray *motionData;

@property (nonatomic,strong) NSDate *userDayStart;
@property (nonatomic,strong) NSDate *userDayEnd;

@end

@implementation APCFitnessAllocation

- (instancetype)initWithAllocationStartDate:(NSDate *)startDate
{
    self = [super init];
    
    if (self) {
        if (startDate) {
            if (startDate) {
                
                NSDate *startDateZeroHour = startDate;
                NSDate *comparisonDate = nil;
                {
                    NSDate *currentDate = startDate;
                    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                    [dateComponents setHour:0];
                    [dateComponents setMinute:0];
                    [dateComponents setSecond:0];
                    
                    startDateZeroHour = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];

                }
                
                {
                    NSDate *currentDate = [NSDate date];
                    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                    [dateComponents setDay:-6];

                    comparisonDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
                    
                    comparisonDate = [[NSCalendar currentCalendar] dateBySettingHour:0 minute:0 second:0 ofDate:comparisonDate options:0];
                }
                
                // If the start date is younger than the comparison date then use the start date
                // Else if the start date is older than the comparsion date then set the comparison date
                if ([startDateZeroHour isLaterThanDate:comparisonDate])
                {
                    startDate = startDateZeroHour;
                }
                
                else
                {
                    startDate = comparisonDate;
                }

                
                _allocationStartDate = startDate;
                
            } else {
                
                NSDate *currentDate = [NSDate date];
                NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                [dateComponents setDay:-6];
                NSDate *sevenDaysAgo = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];

                _allocationStartDate = sevenDaysAgo;
            }
            
            if (!dateFormatter) {
                dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                [dateFormatter setDateFormat:kDatasetDateKeyFormat];
            }
            
            
            _datasetForToday = [NSMutableArray array];
            _datasetForTheWeek = [NSMutableArray array];
            _datasetForYesterday = [NSMutableArray array];
            
            _motionDatasetForToday = [NSMutableArray array];
            _motionDatasetForTheWeek = [NSMutableArray array];
            
            _sleepDataset = [NSMutableArray array];
            _wakeDataset = [NSMutableArray array];
            
            _motionData = [NSMutableArray new];
            _datasetNormalized = [NSMutableArray new];
            
            _segmentSleep = NSLocalizedString(@"Sleep", @"Sleep");
            _segmentInactive = NSLocalizedString(@"Light", @"Light");
            _segmentSedentary = NSLocalizedString(@"Sedentary", @"Sedentary");
            _segmentModerate = NSLocalizedString(@"Moderate", @"Moderate");
            _segmentVigorous = NSLocalizedString(@"Vigorous", @"Vigorous");
            
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(motionDataGatheringComplete)
                                                 name:APHSevenDayAllocationSleepDataIsReadyNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reporterDone:)
                                                 name:APCMotionHistoryReporterDoneNotification
                                               object:nil];

    
    return self;
}

- (void) startDataCollection {
    
    
    NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                         minute:0
                                                         second:0
                                                         ofDate:self.allocationStartDate
                                                        options:0];
    
    NSDateComponents *numberOfDaysFromStartDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                                  fromDate:startDate
                                                                                    toDate:[NSDate date]
                                                                                   options:NSCalendarWrapComponents];
    
    
    
    // if today number of days will be zero.
    

    // numberOfDaysFromStartDate provides the difference of days from now to start
    // of task and therefore if there is no difference we are only getting data for one day.
    numberOfDaysFromStartDate.day += 1;
    
    APCMotionHistoryReporter *reporter = [APCMotionHistoryReporter sharedInstance];
    
    
    //Now using start and end of day as ranges. 
    NSDate *startOfToday = [[NSDate date] startOfDay];
    NSDate *endOfToday = [startOfToday endOfDay];
    
    [reporter startMotionCoProcessorDataFrom:startOfToday andEndDate:endOfToday andNumberOfDays:numberOfDaysFromStartDate.day];

}

- (void)reporterDone:(NSNotification *) __unused notification {
    
    APCMotionHistoryReporter *reporter = [APCMotionHistoryReporter sharedInstance];
    NSArray * theMotionData = reporter.retrieveMotionReport;

    //The count will be the number of days in the array, each element represents a day
    if(theMotionData.count > 0)
    {
        for (NSArray *dayArray in theMotionData)
        {
            NSUInteger inactiveCounter      = 0;
            NSUInteger sedentaryCounter     = 0;
            NSUInteger moderateCounter      = 0;
            NSUInteger vigorousCounter      = 0;
            NSUInteger sleepCounter         = 0;

            for(APCMotionHistoryData * theData in dayArray)
            {
                if(theData.activityType == ActivityTypeSleeping)
                {
                    sleepCounter += theData.timeInterval;
                }
                else if(theData.activityType == ActivityTypeSedentary)
                {
                    sedentaryCounter += theData.timeInterval;
                }
                else if(theData.activityType == ActivityTypeLight)
                {
                    inactiveCounter += theData.timeInterval;
                }
                else if(theData.activityType == ActivityTypeModerate)
                {
                    moderateCounter += theData.timeInterval;
                }
                else if(theData.activityType == ActivityTypeRunning)
                {
                    vigorousCounter += theData.timeInterval;
                }
            }
            
            NSDictionary *activityData = @{
                                           self.segmentInactive : @(inactiveCounter),
                                           self.segmentSedentary: @(sedentaryCounter),
                                           self.segmentModerate : @(moderateCounter),
                                           self.segmentVigorous : @(vigorousCounter),
                                           self.segmentSleep    : @(sleepCounter)
                                           };
            
            [self.wakeDataset addObject:activityData];

            //    Active minutes = minutes of moderate activity + 2x(minutes of vigorous activity). This should be the TOTAL ACTIVE MINUTES FOR THE WEEK,
            self.activeSeconds += (double)moderateCounter + (vigorousCounter * 2) ;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:APHSevenDayAllocationSleepDataIsReadyNotification object:nil];
    });
}
- (HKHealthStore *) healthStore
{
    APCAppDelegate *delegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    
    return delegate.dataSubstrate.healthStore;
}

#pragma mark - Public Interface

- (NSArray *)todaysAllocation
{
    NSArray *allocationForToday = nil;
    NSDictionary *todaysData = [self.datasetNormalized firstObject];
    
    allocationForToday = [self buildSegmentArrayForData:todaysData];
    
    return allocationForToday;
}

- (NSArray *)yesterdaysAllocation
{
    NSArray *allcationForYesterday = nil;
    if ([self.datasetNormalized count] > 1) {
        NSUInteger yesterdayIndex = [self.datasetNormalized indexOfObject:[self.datasetNormalized firstObject]] + 1;
        NSDictionary *yesterdaysData = [self.datasetNormalized objectAtIndex:yesterdayIndex];
        
        allcationForYesterday = [self buildSegmentArrayForData:yesterdaysData];
    }
    
    return allcationForYesterday;
}

- (NSArray *)weeksAllocation
{
    NSArray *allocationForTheWeek = nil;
    
    NSUInteger weekInactiveCounter = 0;
    NSUInteger weekSedentaryCounter = 0;
    NSUInteger weekModerateCounter = 0;
    NSUInteger weekVigorousCounter = 0;
    NSUInteger weekSleepCounter = 0;
    
    for (NSDictionary *day in self.datasetNormalized) {
        
        weekInactiveCounter += [day[self.segmentInactive] integerValue];
        weekSedentaryCounter += [day[self.segmentSedentary] integerValue];
        weekModerateCounter += [day[self.segmentModerate] integerValue];
        weekVigorousCounter += [day[self.segmentVigorous] integerValue];
        weekSleepCounter += [day[self.segmentSleep] integerValue];
    }
    
    NSDictionary *weekData = @{
                               self.segmentInactive: @(weekInactiveCounter),
                               self.segmentSedentary: @(weekSedentaryCounter),
                               self.segmentModerate: @(weekModerateCounter),
                               self.segmentVigorous: @(weekVigorousCounter),
                               self.segmentSleep: @(weekSleepCounter)
                              };
    
    allocationForTheWeek = [self buildSegmentArrayForData:weekData];
    
    return allocationForTheWeek;
}

#pragma mark - Helpers

- (NSArray *)buildSegmentArrayForData:(NSDictionary *)data
{
    NSMutableArray *allocationData = [NSMutableArray new];
    NSArray *segments = @[self.segmentSleep, self.segmentSedentary, self.segmentInactive, self.segmentModerate, self.segmentVigorous];
    UIColor *segmentColor = nil;
    
    for (NSString *segmentId in segments) {
        if ([segmentId isEqualToString:self.segmentSleep]) {
            segmentColor =[APCTheme colorForActivitySleep];
        } else if ([segmentId isEqualToString:self.segmentInactive]) {
            segmentColor = [APCTheme colorForActivityInactive];
        } else if ([segmentId isEqualToString:self.segmentSedentary]) {
            segmentColor = [APCTheme colorForActivitySedentary];
        } else if ([segmentId isEqualToString:self.segmentModerate]) {
            segmentColor = [APCTheme colorForActivityModerate];
        } else {
            segmentColor = [APCTheme colorForActivityVigorous];
        }
        
        [allocationData addObject:@{
                                    kSegmentSumKey: (data[segmentId]) ?: @(0),
                                    kDatasetSegmentKey: segmentId,
                                    kDatasetSegmentColorKey: segmentColor
                                    }];
    }
    
    return allocationData;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APHSevenDayAllocationSleepDataIsReadyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APCMotionHistoryReporterDoneNotification object:nil];
}

- (void)motionDataGatheringComplete
{
    for (NSDictionary *day in self.sleepDataset) {
        NSUInteger dayIndex = [self.sleepDataset indexOfObject:day];
        
        NSMutableDictionary *wakeData = [[self.wakeDataset objectAtIndex:dayIndex] mutableCopy];
        
        //[wakeData setObject:day[self.segmentSleep] forKey:self.segmentSleep];
        
        [self.wakeDataset replaceObjectAtIndex:dayIndex withObject:wakeData];
    }
    
    self.datasetNormalized = self.wakeDataset;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:APHSevenDayAllocationDataIsReadyNotification
                                                            object:nil];
    });
    

}

@end
