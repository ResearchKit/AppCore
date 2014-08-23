//
//  NSString+Extension.m
//  Profile
//
//  Created by Karthik Keyan on 8/23/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (BOOL) isValidForRegex:(NSString *)regex {
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [emailTest evaluateWithObject:self];
}

@end
