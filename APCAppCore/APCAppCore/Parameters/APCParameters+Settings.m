//
//  APCParameters+Settings.m
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 11/6/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCParameters+Settings.h"

@implementation APCParameters (Settings)

+ (NSArray *)autoLockValues
{
    return @[@5, @10, @15, @30, @45];
}

+ (NSArray *)autoLockOptionStrings
{
    NSArray *values = [APCParameters autoLockValues];
    
    NSMutableArray *options = [NSMutableArray new];
    
    for (NSNumber *val in values) {
        NSString *optionString = [NSString stringWithFormat:@"%ld %@", (long)val.integerValue, NSLocalizedString(@"minutes", nil)];
        [options addObject:optionString];
    }
    
    return [NSArray arrayWithArray:options];
}

@end
