//
//  YMLDateFormatter.m
//  Avero
//
//  Created by Mark Pospesel on 11/15/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import "YMLDateFormatter.h"
#import "YMLDefaultFormatter.h"

@interface YMLDateFormatter()

@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation YMLDateFormatter

- (id)init
{
    return [self initWithDateFormatTemplate:@"dMMMyyyy"];
}

- (id)initWithDateFormat:(NSString *)dateFormat
{
    self = [super init];
    if (self) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:dateFormat];
    }
    return self;
}

- (id)initWithDateFormatTemplate:(NSString *)template
{
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:template options:0 locale:[NSLocale currentLocale]];
    return [self initWithDateFormat:dateFormat];
}

- (NSString *)displayValueForValue:(id)value
{
    if ([value isKindOfClass:[NSDate class]])
    {
        return [self.formatter stringFromDate:value];
    }
    else
    {
        return [[YMLDefaultFormatter defaultFormatter] displayValueForValue:value];        
    }    
}

- (id)valueForDisplayValue:(NSString *)displayValue
{
    return [[YMLDefaultFormatter defaultFormatter] valueForDisplayValue:displayValue];
}

+ (YMLDateFormatter *)defaultFormatter
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end
