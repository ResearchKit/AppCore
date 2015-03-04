//
//  NSDictionary+APCAdditions.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (APCAdditions)

- (NSString*) JSONString;
+ (instancetype) dictionaryWithJSONString: (NSString *) string;
- (NSString *)formatNumbersAndDays;

@end
