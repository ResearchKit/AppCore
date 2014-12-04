// 
//  APCTimeSelector.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCTimeSelector.h"

@implementation APCTimeSelector

- (NSNumber*)initialValue
{
    return nil;
}

- (BOOL)matches:(NSNumber*)value
{
    return NO;
}

- (NSNumber*)nextMomentAfter:(NSNumber*)point;
{
    return nil;
}

- (APCTimeSelectorEnumerator*)enumeratorBeginningAt:(NSNumber*)value
{
    return nil;
}

- (BOOL) isWildcard
{
	return NO;
}

@end
