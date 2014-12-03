//
//  NSBundle+Helper.m
//  APCAppCore
//
//  Created by Karthik Keyan on 9/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "NSBundle+Helper.h"
static NSString *const kAPCAppCoreBundleID = @"com.ymedialabs.APCAppCore";

@implementation NSBundle (Helper)

+ (NSBundle *) appleCoreBundle {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kAPCAppCoreBundleID];
    
    return bundle;
}

@end
