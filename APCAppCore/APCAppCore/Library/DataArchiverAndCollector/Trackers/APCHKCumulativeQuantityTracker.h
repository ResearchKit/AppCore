//
//  APCHKCumulativeQuantityTracker.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 2/2/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import "APCDataTracker.h"

@interface APCHKCumulativeQuantityTracker : APCDataTracker

@property (nonatomic, strong) HKUnit* unitForTracker;

- (instancetype) initWithIdentifier:(NSString *)identifier quantityTypeIdentifier: (NSString*) QuantityTypeIdentifier interval: (NSDateComponents*) interval;

@end
