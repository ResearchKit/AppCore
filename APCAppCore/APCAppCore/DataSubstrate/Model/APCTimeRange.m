//
//  APCTimeRange.m
//  APCAppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "APCTimeRange.h"

@implementation APCTimeRange

- (instancetype) initWithStartDate: (NSDate*) startDate endDate: (NSDate*) endDate {
    self = [super init];
    self.startDate = startDate;
    self.endDate = endDate;
    return self;
}

@end
