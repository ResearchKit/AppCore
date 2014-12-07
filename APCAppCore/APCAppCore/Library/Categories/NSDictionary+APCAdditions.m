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
    [error handle];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
