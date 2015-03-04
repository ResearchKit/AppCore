// 
//  NSBundle+Helper.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
#import "NSBundle+Helper.h"
static NSString *const kAPCAppCoreBundleID = @"com.ymedialabs.APCAppCore";

@implementation NSBundle (Helper)

+ (NSBundle *) appleCoreBundle {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kAPCAppCoreBundleID];
    
    return bundle;
}

@end
