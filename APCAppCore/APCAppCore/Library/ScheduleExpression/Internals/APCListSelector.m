// 
//  APCListSelector.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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
    
    [self.subSelectors enumerateObjectsUsingBlock:^(APCTimeSelector* selector, NSUInteger ndx, BOOL* stop)
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
    
    [self.subSelectors enumerateObjectsUsingBlock:^(APCPointSelector* selector, NSUInteger ndx, BOOL* stop)
     {
         isAny = [selector matches:value];
         *stop = isAny;
     }];

    return isAny;
}

- (NSNumber*)nextMomentAfter:(NSNumber*)point;
{
    NSMutableArray* possibleNextPoints = [NSMutableArray array];
    NSNumber*       nextPoint          = nil;

    [self.subSelectors enumerateObjectsUsingBlock:^(APCTimeSelector* selector, NSUInteger ndx, BOOL* stop)
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









