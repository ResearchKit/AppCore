//
//  NSOperationQueue+Helper.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (Helper)

+ (instancetype) sequentialOperationQueueWithName: (NSString *) name;

@end
