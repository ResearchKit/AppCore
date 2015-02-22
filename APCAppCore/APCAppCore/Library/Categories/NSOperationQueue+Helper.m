//
//  NSOperationQueue+Helper.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "NSOperationQueue+Helper.h"

@implementation NSOperationQueue (Helper)

+ (instancetype) sequentialOperationQueueWithName: (NSString *) name
{
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.name = name;
    queue.maxConcurrentOperationCount = 1;
    return queue;
}

@end
