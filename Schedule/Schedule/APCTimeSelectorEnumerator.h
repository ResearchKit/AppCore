//
//  APCTimeSelectorEnumerator.h
//  Schedule
//
//  Created by Edward Cessna on 10/10/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCTimeSelector.h"

@interface APCTimeSelectorEnumerator : NSEnumerator

@property (nonatomic, strong) APCTimeSelector* selector;

- (instancetype)initWithSelector:(APCTimeSelector*)selector;
- (instancetype)initWithSelector:(APCTimeSelector*)selector beginningAtMoment:(NSNumber*)beginning;

- (NSNumber*)reset;
- (NSNumber*)nextObjectAfterRollover;

@end
