//
//  NSArray+Helpers.h
//  Avero
//
//  Created by Mark Pospesel on 11/2/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray(Helpers)

// returns nil if empty array
- (id)firstObjectOrNil;
// returns nil if no item at index
- (id)objectAtIndexOrNil:(NSUInteger)index;
// returns NSNull if no item at index
- (id)safeObjectAtIndex:(NSUInteger)index;

@end
