//
//  APCTimePeriod.m
//  Schedule
//
//  Created by Edward Cessna on 9/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTimePeriod.h"

@implementation APCTimePeriod

- (instancetype)initWithStartDate:(NSDate*)startDate endDate:(NSDate*)endDate
{
    self = [super init];
    if (self)
    {
        _startDate = startDate;
        _endDate   = endDate;
    }
    
    return self;
}

- (instancetype)initWithStartDate:(NSDate*)startDate duration:(NSTimeInterval)duration
{
    return [self initWithStartDate:startDate endDate:[startDate dateByAddingTimeInterval:duration]];
}

@end
