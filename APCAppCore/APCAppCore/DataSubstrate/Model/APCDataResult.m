//
//  APCDataResult.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCDataResult.h"

@implementation APCDataResult

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [super copyWithZone:zone];
    
    if (copy) {
        [copy setData:[self.data copyWithZone:zone]];
    }
    
    return copy;
}

@end
