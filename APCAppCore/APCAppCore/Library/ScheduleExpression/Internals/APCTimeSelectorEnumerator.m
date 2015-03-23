// 
//  APCTimeSelectorEnumerator.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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
		_selector = selector;
		_previousMoment = nil;
		_beginningMoment = nil;
    }
    
    return self;
}

- (instancetype) initWithSelector: (APCTimeSelector*) selector
				beginningAtMoment: (NSNumber*) beginning
{
    self = [self initWithSelector: selector];

    if (self)
    {
		_beginningMoment = selector.initialValue;

		if ([selector matches: beginning])
		{
			_beginningMoment = beginning;
		}
		else
		{
			_beginningMoment = [selector nextMomentAfter: beginning];
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
