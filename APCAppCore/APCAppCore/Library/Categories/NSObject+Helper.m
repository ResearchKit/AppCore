// 
//  NSObject+Helper.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "NSObject+Helper.h"

@implementation NSObject (Helper)

+ (BOOL) isNilOrNull:(id)obj {
    BOOL isNull = NO;
    
    if (obj == nil || [obj isKindOfClass:[NSNull class]]) {
        isNull = YES;
    }
    else {
        if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSMutableString class]]) {
            if ([[(NSString *)obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
                isNull = YES;
            }
        }
    }
    
    return isNull;
}

+ (void) performInMainThread:(void (^)(void))block {
    dispatch_async(dispatch_get_main_queue(), block);
}

+ (void) performInThread:(void (^)(void))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

- (void) performSelector:(SEL)selector withObject:(id)argument1 object:(id)argument2 afterDelay:(NSTimeInterval)delay {
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:self];
    [invocation setArgument:&argument1 atIndex:2];
    [invocation setArgument:&argument2 atIndex:3];
    
    if (delay == 0.0) {
        [invocation invoke];
    }
    else {
        [NSTimer scheduledTimerWithTimeInterval:delay invocation:invocation repeats:NO];
    }
}

@end
