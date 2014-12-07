// 
//  APCTimeSelectorEnumerator.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCTimeSelectorEnumerator.h"

@interface APCTimeSelectorEnumerator ()

@property (nonatomic, strong) NSNumber* previousMoment;
@property (nonatomic, strong) NSNumber* beginningMoment;

@end

@implementation APCTimeSelectorEnumerator

- (instancetype) initWithSelector: (APCTimeSelector*) selector
{
    self = [super init];

    if (self)
    {
		self.selector = selector;
		self.previousMoment = nil;
    }
    
    return self;
}

- (instancetype) initWithSelector: (APCTimeSelector*) selector
				beginningAtMoment: (NSNumber*) beginning
{
    self = [self initWithSelector: selector];

    if (self)
    {
		self.selector = selector;
		self.previousMoment = nil;
		self.beginningMoment = selector.initialValue;

		if ([beginning compare: self.beginningMoment] == NSOrderedDescending)	// "beginning" > initialValue
		{
			self.beginningMoment = beginning;
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
