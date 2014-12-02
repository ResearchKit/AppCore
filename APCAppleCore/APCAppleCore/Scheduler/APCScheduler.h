//
//  Scheduler.h
//  APCAppleCore
//
//  Created by Justin Warmkessel on 8/27/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class APCDataSubstrate;
@class APCSchedule;

@interface APCScheduler : NSObject

- (instancetype) initWithDataSubstrate: (APCDataSubstrate*) dataSubstrate;

- (void)updateScheduledTasksIfNotUpdating: (BOOL) today; //If today is not set, it will always update tasks for tomorrow

@end

