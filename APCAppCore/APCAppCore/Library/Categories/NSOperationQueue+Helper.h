//
//  NSOperationQueue+Helper.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSOperationQueue (Helper)

/**
 Creates an operation queue with medium priority.
 Designed (by Apple) for doing user-requested things
 in the background.
 
 Note:  internally, inside this file, we actually specify
 the priority we want to use.  There's also a method
 which lets us specify the priority explicitly.  I'm not
 exposing that, yet, until we're sure we need and want
 it:  allowing ourselves to set priorities to random things
 might cause more trouble than we want to have to debug.
 */
+ (instancetype) sequentialOperationQueueWithName: (NSString *) name;

@end
