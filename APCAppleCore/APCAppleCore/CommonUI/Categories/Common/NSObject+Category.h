//
//  NSObject+Category.m
//  APCAppleCore
//
//  Created by Karthik Keyan B on 9/16/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import Foundation;

@interface NSObject (Category)

+ (BOOL) isNilOrNull:(id)obj;

+ (void) performInMainThread:(void (^)(void))block;

+ (void) performInThread:(void (^)(void))block;

- (void) performSelector:(SEL)selector withObject:(id)argument1 object:(id)argument2 afterDelay:(NSTimeInterval)delay;

@end
