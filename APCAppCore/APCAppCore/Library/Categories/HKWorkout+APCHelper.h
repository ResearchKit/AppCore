//
//  HKWorkout+APCHelper.h
//  APCAppCore
//
//  Created by Justin Warmkessel on 4/20/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <HealthKit/HealthKit.h>

@interface HKWorkout (APCHelper)

+ (NSString*)workoutActivityTypeStringRepresentation:(int)num;

@end
