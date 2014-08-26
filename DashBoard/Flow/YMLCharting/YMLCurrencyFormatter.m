//
//  YMLCurrencyFormatter.m
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/17/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import "YMLCurrencyFormatter.h"
#import "YMLDefaultFormatter.h"

@interface YMLCurrencyFormatter()

@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;

@end

@implementation YMLCurrencyFormatter

- (id)init
{
    self = [super init];
    if (self) {
        NSLocale *currentLocale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        _currencyCode = [[currentLocale objectForKey:NSLocaleCurrencyCode] copy];
        _currencyFormatter = [[NSNumberFormatter alloc] init];
        [_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [_currencyFormatter setCurrencyCode:_currencyCode];
        [self setMinimumDecimalPlaces:0];
    }
    return self;
}

- (void)setCurrencyCode:(NSString *)currencyCode
{
    if ([_currencyCode isEqualToString:currencyCode])
        return;
    
    _currencyCode = [currencyCode copy];
    [_currencyFormatter setCurrencyCode:_currencyCode];
    // on iOS 5.1 it is necessary for us to again set our desired min/max because it
    // will revert to the default settings for the selected currency otherwise
    [_currencyFormatter setMinimumFractionDigits:self.minimumDecimalPlaces];
}

- (void)setMinimumDecimalPlaces:(NSUInteger)minimumDecimalPlaces
{
    _minimumDecimalPlaces = minimumDecimalPlaces;
    [_currencyFormatter setMinimumFractionDigits:minimumDecimalPlaces];
}

- (NSUInteger)maximumDecimalPlaces
{
    return self.currencyFormatter.maximumFractionDigits;
}

- (void)setMaximumDecimalPlaces:(NSUInteger)maximumDecimalPlaces
{
    [self.currencyFormatter setMaximumFractionDigits:maximumDecimalPlaces];
}

- (NSString *)currencySymbol
{
    return [self.currencyFormatter currencySymbol];
}

- (NSString *)displayValueForValue:(id)value
{
    if (![value isKindOfClass:[NSNumber class]])
    {
        return [[YMLDefaultFormatter defaultFormatter] displayValueForValue:value];
    }
    
    NSString *suffix = @"";
    CGFloat floatValue = [value floatValue];
    
    if (self.shortenNumbers)
    {
        int log10 = floor(log10f(floatValue));
        if (log10 >= 9)
        {
            floatValue /= 1000000000;
            suffix = @"B";
        }
        else if (log10 >= 6)
        {
            floatValue /= 1000000;
            suffix = @"M";
        }
        else if (log10 >= 3)
        {
            floatValue /= 1000;
            suffix = @"K";
        }
        
        if ([suffix length] > 0)
            return [NSString stringWithFormat:@"%@%@", [self.currencyFormatter stringFromNumber:@(floatValue)], suffix];
    }
    
    BOOL shouldReset = [self checkForCurrencySymbol:_currencyCode];
    NSString *returnValue = [self.currencyFormatter stringFromNumber:@(floatValue)];
    
    if(shouldReset)
    {
        _currencyCode = @"";
        [_currencyFormatter setCurrencyCode:_currencyCode];
    }
    
    return returnValue;
}

- (void)setNegativeFormat:(NSString *)negativeFormat
{
    [_currencyFormatter setNegativeFormat:negativeFormat];
}

- (id)valueForDisplayValue:(NSString *)displayValue
{
    return [self.currencyFormatter numberFromString:displayValue];
}

- (BOOL)checkForCurrencySymbol:(NSString *)string
{
    if(string.length == 0)
    {
        NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        NSString *code = [locale objectForKey:NSLocaleCurrencyCode];
        _currencyCode = code;
        [_currencyFormatter setCurrencyCode:_currencyCode];
    }
    
    return NO;
}

@end
