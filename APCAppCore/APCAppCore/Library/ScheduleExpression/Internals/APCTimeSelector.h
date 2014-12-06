// 
//  APCTimeSelector.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>

//  Private implementation.

@class APCTimeSelectorEnumerator;

@interface APCTimeSelector : NSObject

/**
 Returns YES if the specified selector represents a "*",
 NO otherwise.  Implemented by subclasses, in the method
 -isWildcard.
 
 This is a property so that we can use the "dot" syntax
 to access it.
 
 @author Ron
 */
@property (nonatomic, readonly) BOOL isWildcard;

- (NSNumber*)initialValue;
- (BOOL)matches:(NSNumber*)value;
- (NSNumber*)nextMomentAfter:(NSNumber*)point;

- (APCTimeSelectorEnumerator*)enumeratorBeginningAt:(NSNumber*)value;

@end
