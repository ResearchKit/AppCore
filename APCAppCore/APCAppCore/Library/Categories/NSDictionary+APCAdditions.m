//
//  NSDictionary+APCAdditions.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "NSDictionary+APCAdditions.h"
#import "APCAppCore.h"

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

@end
