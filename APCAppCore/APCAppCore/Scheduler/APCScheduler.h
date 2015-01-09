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

@interface APCScheduler : NSObject

- (instancetype) initWithDataSubstrate: (APCDataSubstrate*) dataSubstrate;

- (void)updateScheduledTasksIfNotUpdating: (BOOL) today;

@end

