//
//  APCHKQuantityTracker.m
//  APCAppCore
//
//  Created by Dhanush Balachandran on 2/2/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCHKDiscreteQuantityTracker.h"

@implementation APCHKDiscreteQuantityTracker

- (NSArray *)columnNames
{
    return @[@"startDate", @"endDate", @"dataType", @"data"];
}

@end
