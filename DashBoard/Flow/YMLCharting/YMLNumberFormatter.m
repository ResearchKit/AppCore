//
//  YMLNumberFormatter.m
//  Avero
//
//  Created by Mark Pospesel on 12/7/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import "YMLNumberFormatter.h"
#import "YMLDefaultFormatter.h"

@interface YMLNumberFormatter()

@property (nonatomic, strong) NSNumberFormatter *formatter;

@end

@implementation YMLNumberFormatter

- (id)init
{
    self = [super init];
    if (self) {
        _formatter = [[NSNumberFormatter alloc] init];
        [_formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        _minimumDecimalPlaces = 0;
        _maximumDecimalPlaces = 2;
        [_formatter setMinimumFractionDigits:_minimumDecimalPlaces];
        [_formatter setMaximumFractionDigits:_maximumDecimalPlaces];
    }
    return self;
}

- (void)setMinimumDecimalPlaces:(NSUInteger)minimumDecimalPlaces
{
    _minimumDecimalPlaces = minimumDecimalPlaces;
    [self.formatter setMinimumFractionDigits:minimumDecimalPlaces];
}

- (void)setMaximumDecimalPlaces:(NSUInteger)maximumDecimalPlaces
{
    _maximumDecimalPlaces = maximumDecimalPlaces;
    [self.formatter setMaximumFractionDigits:maximumDecimalPlaces];
}

- (NSString *)displayValueForValue:(id)value
{
    if (![value isKindOfClass:[NSNumber class]])
    {
        return [[YMLDefaultFormatter defaultFormatter] displayValueForValue:value];
    }
    
    return [self.formatter stringFromNumber:value];
}

- (id)valueForDisplayValue:(NSString *)displayValue
{
    return [[YMLDefaultFormatter defaultFormatter] valueForDisplayValue:displayValue];
}

@end
