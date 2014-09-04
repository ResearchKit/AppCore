//
//  NSDate+Category.m
//  UI
//
//  Created by Karthik Keyan on 9/4/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "NSDate+Category.h"

@implementation NSDate (Category)

- (NSString *) toStringWithFormat:(NSString *)formate {
    NSString *formattedString = nil;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = formate;
    formattedString = [dateFormatter stringFromDate:self];
    
    return formattedString;
}

@end
