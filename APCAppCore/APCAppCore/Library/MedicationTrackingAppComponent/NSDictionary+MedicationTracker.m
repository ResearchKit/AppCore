//
//  NSDictionary+MedicationTracker.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "NSDictionary+MedicationTracker.h"

@implementation NSDictionary (MedicationTracker)

- (id)objectForKeyWithNil:(id)aKey
{
    if (self == nil) {
        return nil;
    }
    id object = [self objectForKey:aKey];
    if (object == [NSNull null]) {
        return nil;
    }
    return object;
}

@end
