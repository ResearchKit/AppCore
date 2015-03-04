//
//  APCCoreMotionTracker.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCDataTracker.h"
#import <CoreMotion/CoreMotion.h>

@interface APCCoreMotionTracker : APCDataTracker

@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;

@end

