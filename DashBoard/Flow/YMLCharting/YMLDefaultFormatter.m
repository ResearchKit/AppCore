//
//  YMLDefaultFormatter.m
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/17/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import "YMLDefaultFormatter.h"

@implementation YMLDefaultFormatter

- (NSString *)displayValueForValue:(id)value
{
    // just return strings as is
    if ([value isKindOfClass:[NSString class]])
        return value;
    
    // return medium dates by default (for other behavior, implement a custom formatter
    if ([value isKindOfClass:[NSDate class]])
    {
        /*NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle]; // e.g. Nov 23, 1987
        return [formatter stringFromDate:value];*/
        
        // Display just short month name + day, but in locale-specific manner
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"dMMM" options:0
                                                                  locale:[NSLocale currentLocale]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:formatString];
        
        return [dateFormatter stringFromDate:value];
    }

    if ([value isKindOfClass:[NSNumber class]])
    {
        // TODO: save formatter as private property?
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        return [formatter stringFromNumber:value];
    }
    
    NSLog(@"Value type not implemented!");
    return nil;
}
- (id)valueForDisplayValue:(NSString *)displayValue
{
    // just return strings as is
    if ([displayValue isKindOfClass:[NSString class]])
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        NSString *decimalValue = [displayValue stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789.,"] invertedSet]];
        
        NSNumber *number = [formatter numberFromString:decimalValue];
        return number;
    }
    return nil;
}

+ (YMLDefaultFormatter *)defaultFormatter
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end
