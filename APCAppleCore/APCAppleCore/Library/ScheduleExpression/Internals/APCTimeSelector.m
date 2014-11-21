//
//  APCTimeSelector.m
//  Schedule
//
//  Created by Edward Cessna on 9/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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

@end
