// 
//  APCListSelector.m 
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
 
#import "APCListSelector.h"
#import "APCTimeSelectorEnumerator.h"


@implementation APCListSelector

- (instancetype)initWithSubSelectors:(NSArray*)subSelectors
{
    self = [super init];
	
    if (self)
    {
        _subSelectors = subSelectors == nil ? @[] : subSelectors;
    }
    
    return self;
}

- (APCTimeSelectorEnumerator*)enumeratorBeginningAt:(NSNumber*)value
{
    APCTimeSelectorEnumerator*   enumerator = [[APCTimeSelectorEnumerator alloc] initWithSelector:self beginningAtMoment:value];

    return enumerator;
}

- (NSNumber*)initialValue
{
    __block NSNumber*   first;
    
    [self.subSelectors enumerateObjectsUsingBlock:^(APCTimeSelector* selector, NSUInteger __unused  ndx, BOOL* __unused stop)
    {
        NSNumber*   subFirst = [selector initialValue];
        if (first == nil || [subFirst compare:first] == NSOrderedAscending)
        {
            first = subFirst;
        }
    }];
    
    return first;
}

- (BOOL)matches:(NSNumber*)value
{
    __block BOOL    isAny = NO;
    
    [self.subSelectors enumerateObjectsUsingBlock:^(APCPointSelector* selector, NSUInteger __unused ndx, BOOL* __unused stop)
     {
         isAny = [selector matches:value];
         *stop = isAny;
     }];

    return isAny;
}

- (NSNumber*)nextMomentAfter:(NSNumber*)point
{
    NSMutableArray* possibleNextPoints = [NSMutableArray array];
    NSNumber*       nextPoint          = nil;

    [self.subSelectors enumerateObjectsUsingBlock:^(APCTimeSelector* selector, NSUInteger __unused ndx, BOOL* __unused stop)
    {
        NSNumber*   nextPoint = [selector nextMomentAfter:point];
        if (nextPoint != nil)
        {
            [possibleNextPoints addObject:nextPoint];
        }
    }];
    
    [possibleNextPoints sortUsingComparator:^(NSNumber* lhs, NSNumber* rhs)
    {
        return [lhs compare:rhs];
    }];
    
    if (possibleNextPoints.count > 0)
    {
        nextPoint = possibleNextPoints.firstObject;
    }
    
    return nextPoint;
}

-(BOOL) isWildcard
{
	BOOL iHaveNoKids = self.subSelectors.count == 0;

	BOOL allMyKidsAreWildcards = YES;

	for (APCTimeSelector *selector in self.subSelectors)
	{
		if (! selector.isWildcard)
		{
			allMyKidsAreWildcards = NO;
			break;
		}
	}

	return iHaveNoKids || allMyKidsAreWildcards;
}
- (NSString *) description
{
	return [NSString stringWithFormat: @"ListSelector { %@ }", self.subSelectors];
}

@end









