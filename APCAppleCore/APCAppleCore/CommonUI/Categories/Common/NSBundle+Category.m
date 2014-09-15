//
//  NSBundle+Category.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "NSBundle+Category.h"

@implementation NSBundle (Category)

+ (NSBundle *) appleCoreBundle {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"APCAppleCoreBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    
    return bundle;
}

@end
