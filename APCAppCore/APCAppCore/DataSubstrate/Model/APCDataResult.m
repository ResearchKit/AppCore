//
//  APCDataResult.m
//  AppCore 
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCDataResult.h"

@implementation APCDataResult

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setData:[self.data copyWithZone:zone]];
    }
    
    return copy;
}

@end
