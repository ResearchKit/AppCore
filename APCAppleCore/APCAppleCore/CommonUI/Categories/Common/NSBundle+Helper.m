//
//  NSBundle+Helper.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "NSBundle+Helper.h"
static NSString *const kAPCAppleCoreBundleID = @"com.ymedialabs.APCAppleCore";

@implementation NSBundle (Helper)

+ (NSBundle *) appleCoreBundle {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kAPCAppleCoreBundleID];
    
    return bundle;
}

@end
