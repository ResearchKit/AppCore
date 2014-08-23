//
//  Profile.m
//  Profile
//
//  Created by Karthik Keyan on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "Profile.h"

@implementation Profile

@end


@implementation Profile (DateOfBirth)

- (NSString *) dateOfBirthStringWithFormat:(NSString *)formate {
    NSString *formattedString = nil;
    
    if (self.dateOfBirth) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = formate;
        formattedString = [dateFormatter stringFromDate:self.dateOfBirth];
    }
    
    return formattedString;
}

@end