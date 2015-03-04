//
//  NSDictionary+MedicationTracker.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "NSDictionary+MedicationTracker.h"

@implementation NSDictionary (MedicationTracker)

- (id)objectForKeyWithNil:(id)aKey
{
    id  answer = nil;
    
    id  object = [self objectForKey:aKey];
    if (object != [NSNull null]) {
        answer = object;
    }
    return answer;
}

@end
