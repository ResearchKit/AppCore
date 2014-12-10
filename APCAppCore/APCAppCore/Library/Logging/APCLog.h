//
//  APCLog.h
//  APCAppCore
//
//  Created by Ron Conescu on 12/7/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCLog : NSObject

+ (void) start;

+ (void) log: (NSString *) format, ...;
+ (void) logException: (NSException *) exception;
+ (void) logException: (NSException *) exception format: (NSString *) messageOrFormattingString, ...;

@end
