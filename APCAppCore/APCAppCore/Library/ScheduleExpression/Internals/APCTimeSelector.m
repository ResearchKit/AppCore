// 
//  APCTimeSelector.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCTimeSelector.h"

@implementation APCTimeSelector

- (NSNumber*)initialValue
{
    return nil;
}

- (BOOL)matches:(NSNumber*) __unused value
{
    return NO;
}

- (NSNumber*)nextMomentAfter:(NSNumber*) __unused point
{
    return nil;
}

- (APCTimeSelectorEnumerator*)enumeratorBeginningAt:(NSNumber*) __unused value
{
    return nil;
}

- (BOOL) isWildcard
{
	return NO;
}

@end
