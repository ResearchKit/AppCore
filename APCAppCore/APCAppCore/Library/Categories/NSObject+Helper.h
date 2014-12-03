// 
//  NSObject+Helper.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
@import Foundation;

@interface NSObject (Helper)

+ (BOOL) isNilOrNull:(id)obj;

+ (void) performInMainThread:(void (^)(void))block;

+ (void) performInThread:(void (^)(void))block;

- (void) performSelector:(SEL)selector withObject:(id)argument1 object:(id)argument2 afterDelay:(NSTimeInterval)delay;

@end
