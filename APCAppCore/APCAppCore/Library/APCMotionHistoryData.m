//
//  APCMotionHistoryData.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
#import "APCMotionHistoryData.h"

@implementation APCMotionHistoryData


- (id)initWithActivityType:(ActivityType)activityType andTimeInterval:(NSTimeInterval)timeInterval
{
    if (self = [super init]) {
        self.activityType = activityType;
        self.timeInterval = timeInterval;
    }
    return self;
}


@end
