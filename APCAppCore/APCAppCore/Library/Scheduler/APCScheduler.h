// 
//  APCScheduler.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class APCDataSubstrate;
@class APCSchedule;
@class APCDateRange;

typedef NS_ENUM(NSUInteger, APCSchedulerDateRange) {
    kAPCSchedulerDateRangeYesterday,
    kAPCSchedulerDateRangeToday,
    kAPCSchedulerDateRangeTomorrow
};

@interface APCScheduler : NSObject

- (instancetype) initWithDataSubstrate: (APCDataSubstrate*) dataSubstrate;

- (void)updateScheduledTasksIfNotUpdating: (BOOL) today;
- (void)updateScheduledTasksIfNotUpdatingWithRange: (APCSchedulerDateRange) range;

@end

