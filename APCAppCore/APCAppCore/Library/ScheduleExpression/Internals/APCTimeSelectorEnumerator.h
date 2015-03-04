// 
//  APCTimeSelectorEnumerator.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import <Foundation/Foundation.h>
#import "APCTimeSelector.h"

//  Private implementation.

@interface APCTimeSelectorEnumerator : NSEnumerator

@property (nonatomic, strong) APCTimeSelector* selector;

- (instancetype)initWithSelector:(APCTimeSelector*)selector;
- (instancetype)initWithSelector:(APCTimeSelector*)selector beginningAtMoment:(NSNumber*)beginning;

- (NSNumber*)reset;
- (NSNumber*)nextObjectAfterRollover;

@end
