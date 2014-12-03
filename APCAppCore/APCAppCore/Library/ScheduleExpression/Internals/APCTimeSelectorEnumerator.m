//
//  APCTimeSelectorEnumerator.m
//  Schedule
//
//  Created by Edward Cessna on 10/10/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTimeSelectorEnumerator.h"

@interface APCTimeSelectorEnumerator ()

@property (nonatomic, strong) NSNumber* previousMoment;
@property (nonatomic, strong) NSNumber* beginningMoment;

@end

@implementation APCTimeSelectorEnumerator

- (instancetype)initWithSelector:(APCTimeSelector*)selector
{
    self = [super init];
    if (self)
    {
        _selector       = selector;
        _previousMoment = nil;
    }
    
    return self;
}

- (instancetype)initWithSelector:(APCTimeSelector*)selector beginningAtMoment:(NSNumber*)beginning
{
    self = [self initWithSelector:selector];
    
    if (self)
    {
        _selector        = selector;
        _previousMoment  = nil;
        
        if (beginning != nil)
        {
            NSNumber*   first = [selector initialValue];
            
            if ([beginning compare:first] == NSOrderedAscending)    //  beginning < first?
            {
                _beginningMoment = first;
            }
            else
            {
                _beginningMoment = beginning;
            }
        }
    }
    
    return self;
}


- (id)nextObject
{
    NSNumber*   nextMoment;
    
    if (self.previousMoment == nil)
    {
        nextMoment = self.beginningMoment;
    }
    else
    {
        nextMoment = [self.selector nextMomentAfter:self.previousMoment];
    }
    
    self.previousMoment = nextMoment;
    
    return nextMoment;
}

- (NSNumber*)nextObjectAfterRollover
{
    NSNumber*   nextMoment = [self.selector initialValue];
    
    self.previousMoment = nextMoment;
    
    return nextMoment;
}

- (NSNumber*)reset
{
    NSNumber*   nextMoment = self.beginningMoment ?: [self nextObjectAfterRollover];
    
    self.previousMoment = nextMoment;

    return nextMoment;
}

@end
