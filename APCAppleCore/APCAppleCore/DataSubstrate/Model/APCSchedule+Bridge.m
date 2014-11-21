//
//  APCSchedule+Bridge.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 11/21/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSchedule+Bridge.h"

@implementation APCSchedule (Bridge)
+ (void) updateSchedulesOnCompletion: (void (^)(NSError * error)) completionBlock
{
    [SBBComponent(SBBScheduleManager) getSchedulesWithCompletion:^(id schedulesList, NSError *error) {
        SBBResourceList *list = (SBBResourceList *)schedulesList;
        NSArray * schedules = list.items;
        [schedules enumerateObjectsUsingBlock:^(SBBSchedule* schedule, NSUInteger idx, BOOL *stop) {
            NSLog(@"%@", schedule);
        }];
    }];
}
@end
