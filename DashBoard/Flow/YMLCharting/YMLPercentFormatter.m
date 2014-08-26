//
//  YMLPercentFormatter.m
//  Avero
//
//  Created by Mark Pospesel on 11/27/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import "YMLPercentFormatter.h"
#import "YMLDefaultFormatter.h"

@interface YMLPercentFormatter()

@property (nonatomic, strong) NSNumberFormatter *formatter;

@end

@implementation YMLPercentFormatter

- (id)init
{
    self = [super init];
    if (self) {
        _formatter = [[NSNumberFormatter alloc] init];
        [_formatter setNumberStyle:NSNumberFormatterPercentStyle];
        [_formatter setMaximumFractionDigits:1];
        _includeSymbol = YES;
        _decimalPlaces = 1;
    }
    return self;
}

- (void)setIncludeSymbol:(BOOL)includeSymbol
{
    _includeSymbol = includeSymbol;
    [self.formatter setPercentSymbol:includeSymbol? @"%" : @""];
}

- (void)setDecimalPlaces:(NSUInteger)decimalPlaces
{
    _decimalPlaces = decimalPlaces;
    [self.formatter setMaximumFractionDigits:decimalPlaces];
}

- (void)setMinimumDecimalPlaces:(NSUInteger)number
{
    [self.formatter setMinimumFractionDigits:number];
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
