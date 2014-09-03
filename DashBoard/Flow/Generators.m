//
//  Generators.m
//  Generators
//
//  Created by Edward Cessna on 8/26/14.
//  Copyright (c) 2014 Edward Cessna. All rights reserved.
//

#import "Generators.h"

//  Example 1

@interface IndexGenerator ()

@property (nonatomic, strong) NSDecimalNumber*  index;

@end

@implementation IndexGenerator

- (instancetype)initWithIndex:(NSDecimalNumber*)index
{
    self = [super init];
    if (self)
    {
        _index = index;
    }
    
    return self;
}

- (BOOL)hasNext
{
    return YES;
}

- (NSDecimalNumber*)next
{
    self.index = [self.index decimalNumberByAdding:[NSDecimalNumber one]];
    
    return self.index;
}

@end


//  Example 2

void minMaxValue(NSArray* data, NSDecimalNumber* __strong * minValue, NSDecimalNumber* __strong * maxValue)
{
    *minValue = [NSDecimalNumber minimumDecimalNumber];
    *maxValue = [NSDecimalNumber maximumDecimalNumber];
    
    for (NSDecimalNumber* num in data)
    {
        if ([num compare:*minValue] == NSOrderedAscending)
        {
            *minValue = num;
        }
        
        if ([num compare:*maxValue] == NSOrderedDescending)
        {
            *maxValue = num;
        }
    }
    
}

@interface NormalizingGenerator ()

@property (nonatomic, strong) NSArray*          data;
@property (nonatomic, assign) NSInteger         nextIndex;
@property (nonatomic, strong) NSDecimalNumber*  minValue;
@property (nonatomic, strong) NSDecimalNumber*  maxValue;
@property (nonatomic, strong) NSDecimalNumber*  valueRange;

@end


@implementation NormalizingGenerator

- (instancetype)initWithDataArray:(NSArray*)data
{
    self = [super init];
    if (self)
    {
        minMaxValue(data, &_minValue, &_maxValue);
        
        _data       = data;
        _nextIndex  = 0;
        _valueRange = [_maxValue decimalNumberBySubtracting:_minValue];
    }
    
    return self;
}


- (BOOL)hasNext
{
    return self.nextIndex < self.data.count;
}

- (NSDecimalNumber*)next
{
    NSDecimalNumber*    nextValue = [[self.data[self.nextIndex] decimalNumberBySubtracting:self.minValue] decimalNumberByDividingBy:self.valueRange];
    
    ++self.nextIndex;
    
    return nextValue;
}

@end
