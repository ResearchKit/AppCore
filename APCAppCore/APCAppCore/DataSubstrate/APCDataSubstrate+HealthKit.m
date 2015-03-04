// 
//  APCDataSubstrate+HealthKit.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCDataSubstrate+HealthKit.h"
#import <HealthKit/HealthKit.h>

@implementation APCDataSubstrate (HealthKit)

- (void)setUpHealthKit
{
    
    self.healthStore = [HKHealthStore isHealthDataAvailable] ? [[HKHealthStore alloc] init] : nil;
}

@end
