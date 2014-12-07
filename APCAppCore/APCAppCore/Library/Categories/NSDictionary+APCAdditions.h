//
//  NSDictionary+APCAdditions.h
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (APCAdditions)

- (NSString*) JSONString;
+ (instancetype) dictionaryWithJSONString: (NSString *) string;

@end
