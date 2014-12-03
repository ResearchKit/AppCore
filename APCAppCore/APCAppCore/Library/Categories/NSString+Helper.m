// 
//  NSString+Helper.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "NSString+Helper.h"

@implementation NSString (Helper)

- (BOOL) isValidForRegex:(NSString *)regex {
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [emailTest evaluateWithObject:self];
}

@end
