//
//  NSOperationQueue+Helper.m
//  APCAppCore
//
//  Created by Ron Conescu on 2/18/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "NSOperationQueue+Helper.h"

@implementation NSOperationQueue (Helper)

+ (instancetype) operationQueueWithName: (NSString *) name
{
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.name = name;
    return queue;
}

@end
