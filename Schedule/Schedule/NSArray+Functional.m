//
//  NSArray+Functional.m
//  Schedule
//
//  Created by Edward Cessna on 9/19/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "NSArray+Functional.h"

@implementation NSArray (Functional)

- (id)reduce:(id(^)(id a, id b))block
{
    id  accumulator;
    
    if (self.count > 0)
    {
        accumulator = [self objectAtIndex:0];
        for (NSUInteger ndx = 1; ndx < self.count; ndx++)
        {
            accumulator = block(accumulator, [self objectAtIndex:ndx]);
        }
    }
    
    return accumulator;
}

- (void)each:(void(^)(id object))block
{
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger ndx, BOOL* stop) { block(obj); }];
}

- (NSArray*)map:(id(^)(id object))block
{
    NSMutableArray* mappedResults = [NSMutableArray arrayWithCapacity:self.count];

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger ndx, BOOL* stop) { mappedResults[ndx] = block(obj); }];

    return [mappedResults copy];
}

- (NSArray*)mapWithIndex:(id(^)(id object, NSUInteger index))block
{
    NSMutableArray* mappedResults = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger ndx, BOOL* stop) { mappedResults[ndx] = block(obj, ndx); }];
    
    return [mappedResults copy];
}

- (BOOL)every:(BOOL(^)(id object))block
{
    BOOL    isEvery = NO;
    
    if (self.count > 0)
    {
        NSInteger   ndx = 0;
        
        isEvery = self[ndx++];
        
        while (isEvery)
        {
            isEvery = block(self[ndx++]);
        }
    }
    
    return isEvery;
}

- (BOOL)everyWithIndex:(BOOL(^)(id object, NSUInteger index))block
{
    BOOL    isEvery = NO;
    
    if (self.count > 0)
    {
        NSUInteger  ndx = 0;
        
        isEvery = self[ndx++];
        
        while (isEvery)
        {
            isEvery = block(self[ndx++], ndx);
        }
    }
    
    return isEvery;
}

- (BOOL)any:(BOOL(^)(id object))block
{
    __block BOOL    isAny = NO;
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger ndx, BOOL* stop)
    {
        isAny = block(obj);
        *stop = isAny;
    }];
    
    return isAny;
}

@end
