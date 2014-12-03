//
//  APCDataSubstrate+HealthKit.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDataSubstrate+HealthKit.h"
#import <HealthKit/HealthKit.h>

@implementation APCDataSubstrate (HealthKit)

- (void)setUpHealthKit
{
    
    self.healthStore = [HKHealthStore isHealthDataAvailable] ? [[HKHealthStore alloc] init] : nil;
}

@end
