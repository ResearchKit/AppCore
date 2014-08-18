//
//  NSString+Extension.m
//  Parameters
//
//  Created by Karthik Keyan on 8/15/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (BOOL) isNumber {
    NSString *emailRegex = @"[0-9]+";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
}

@end
