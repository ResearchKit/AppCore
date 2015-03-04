//
//  APCHKQuantityTracker.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import "APCDataTracker.h"

@interface APCHKDiscreteQuantityTracker : APCDataTracker

@property (nonatomic, strong) HKUnit* unitForTracker;

- (instancetype) initWithIdentifier:(NSString *)identifier sampleType: (HKSampleType*) sampleType;

@end
