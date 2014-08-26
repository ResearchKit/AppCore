//
//  NSArray+Helpers.m
//  Avero
//
//  Created by Mark Pospesel on 11/2/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import "NSArray+Helpers.h"

@implementation NSArray(Helpers)

- (id)firstObjectOrNil
{
    if ([self count] > 0)
        return [self objectAtIndex:0];
    else
        return nil;
}

- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (index < [self count])
        return [self objectAtIndex:index];
    else
        return [NSNull null];
}

- (id)objectAtIndexOrNil:(NSUInteger)index
{
    if (index < [self count])
        return [self objectAtIndex:index];
    else
        return nil;
}

@end
