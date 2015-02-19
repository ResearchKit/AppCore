//
//  NSOperationQueue+Helper.h
//  APCAppCore
//
//  Created by Ron Conescu on 2/18/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (Helper)

+ (instancetype) sequentialOperationQueueWithName: (NSString *) name;

@end
