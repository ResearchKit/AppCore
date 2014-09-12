//
//  NSDate+Category.m
//  UI
//
//  Created by Karthik Keyan on 9/4/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "NSDate+Category.h"

NSString * const NSDateDefaultDateFormat            = @"MMM dd, yyyy";

@implementation NSDate (Category)

- (NSString *) toStringWithFormat:(NSString *)format {
    if (!format) {
        format = NSDateDefaultDateFormat;
    }
    
    NSString *formattedString = nil;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = format;
    formattedString = [dateFormatter stringFromDate:self];
    
    return formattedString;
}

@end
