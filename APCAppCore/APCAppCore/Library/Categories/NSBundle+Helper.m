// 
//  NSBundle+Helper.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "NSBundle+Helper.h"
static NSString *const kAPCAppCoreBundleID = @"com.ymedialabs.APCAppCore";

@implementation NSBundle (Helper)

+ (NSBundle *) appleCoreBundle {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kAPCAppCoreBundleID];
    
    return bundle;
}

@end
