//
//  APCCoreMotionTracker.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCCoreMotionTracker.h"

static NSString *const kLastUsedTimeKey = @"APHLastUsedTime";

@implementation APCCoreMotionTracker

- (void) startTracking
{
    NSDate *lastUsedTime = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUsedTimeKey];
    if (!lastUsedTime) {
        
    }
}

- (void) stopTracking
{
    //Abstract implementation
}

- (void) updateTracking
{
    //Abstract implementation
}

//NSDate *currentTime = [NSDate date];
//[[NSUserDefaults standardUserDefaults] setObject:currentTime forKey:kLastUsedTimeKey];
//NSDate *lastUsedTime = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUsedTimeKey];
@end
