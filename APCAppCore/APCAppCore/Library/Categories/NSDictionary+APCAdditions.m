//
//  NSDictionary+APCAdditions.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "NSDictionary+APCAdditions.h"
#import "APCAppCore.h"

static  NSString  *daysOfWeekNames[]     = { @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday" };
static  NSUInteger  numberOfDaysOfWeek   = (sizeof(daysOfWeekNames) / sizeof(NSString *));
static  NSString  *oneThroughFiveNames[] = { @"Once", @"Two times", @"Three times", @"Four times", @"Five times" };

@implementation NSDictionary (APCAdditions)

- (NSString *)JSONString
{
    NSError * error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    APCLogError2 (error);
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (instancetype)dictionaryWithJSONString:(NSString *)string
{
    NSData *resultData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary * retValue = [NSJSONSerialization JSONObjectWithData:resultData
                                             options:NSJSONReadingAllowFragments
                                               error:&error];
    APCLogError2 (error);
    return retValue;
}

    //
    //    to support Medication Tracking Requirements
    //
- (NSString *)formatNumbersAndDays
{
    NSDictionary  *mapper = @{ @"Monday" : @"Mon", @"Tuesday" : @"Tue", @"Wednesday" : @"Wed", @"Thursday" : @"Thu", @"Friday" : @"Fri", @"Saturday" : @"Sat", @"Sunday" : @"Sun" };
    
    BOOL  everyday = YES;
    NSNumber  *saved = nil;
    NSArray  *all = [self allValues];
    for (NSNumber  *number  in  all) {
        if ([number integerValue] > 0) {
            saved = number;
        } else {
            everyday = NO;
            break;
        }
    }
    
    NSString  *result = @"";
    if (everyday == YES) {
        if ([saved unsignedIntegerValue] > 5) {
            result = [NSString stringWithFormat:@"%lu times Every Day", (unsigned long)[saved unsignedIntegerValue]];
        } else {
            result = [NSString stringWithFormat:@"%@ Every Day", oneThroughFiveNames[[saved unsignedIntegerValue] - 1]];
        }
    } else {
        NSMutableString  *daysAndNumbers = [NSMutableString string];
        for (NSUInteger  day = 0;  day < numberOfDaysOfWeek;  day++) {
            NSString  *key = daysOfWeekNames[day];
            NSNumber  *number = [self objectForKey:key];
            if ([number integerValue] > 0) {
                if ([saved unsignedIntegerValue] > 5) {
                    if (daysAndNumbers.length == 0) {
                        [daysAndNumbers appendFormat:@"%lu times on %@", (unsigned long)[number unsignedIntegerValue], mapper[key]];
                    } else {
                        [daysAndNumbers appendFormat:@", %@", mapper[key]];
                    }
                } else {
                    if (daysAndNumbers.length == 0) {
                        [daysAndNumbers appendFormat:@"%@ on %@", oneThroughFiveNames[[number unsignedIntegerValue] - 1], mapper[key]];
                    } else {
                        [daysAndNumbers appendFormat:@", %@", mapper[key]];
                    }
                }
            }
        }
        result = daysAndNumbers;
    }
    return  result;
}
@end
