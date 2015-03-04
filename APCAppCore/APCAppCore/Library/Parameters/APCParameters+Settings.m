// 
//  APCParameters+Settings.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
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
