// 
//  APCTimeSelector.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <Foundation/Foundation.h>

//  Private implementation.

@class APCTimeSelectorEnumerator;

@interface APCTimeSelector : NSObject

/**
 Returns YES if the specified selector represents a "*",
 NO otherwise.  Implemented by subclasses, in the method
 -isWildcard.
 */
@property (nonatomic, readonly) BOOL isWildcard;

- (NSNumber*)initialValue;
- (BOOL)matches:(NSNumber*)value;
- (NSNumber*)nextMomentAfter:(NSNumber*)point;

- (APCTimeSelectorEnumerator*)enumeratorBeginningAt:(NSNumber*)value;

@end
