//
//  RKPedometerRecorder.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

/**
 * @brief A recorder that requests and collects device motion data from CoreMotion at a fixed frequency.
 *
 * The accelerometer recorder continues to record if the application enters the
 * background using UIApplication's background task support.
 */
@interface RKPedometerRecorder : RKRecorder

/**
 * @brief Accelerometer data collection frequency from CoreMotion in Hz.
 */
@property (nonatomic, readonly) double frequency;

/**
 * @brief Designated initializer
 * @param frequency    Accelerometer data collection frequency in Hz
 */
- (instancetype)initWithFrequency:(double)frequency step:(RKStep*)step taskInstanceUUID:(NSUUID*)taskInstanceUUID;

@end

/**
 * @brief RKAccelerometerRecorderConfiguration implements RKRecorderConfiguration and able to generate RKAccelerometerRecorder instance.
 */
@interface RKPedometerRecorderConfiguration : NSObject <RKRecorderConfiguration>

/**
 * @brief pedometer data collection frequency, unit is hertz (Hz).
 */
@property (nonatomic, readonly) double frequency;

/**
 * @brief Designated initializer
 * @param frequency    Accelerometer data collection frequency, unit is hertz (Hz).
 */
- (instancetype)initWithFrequency:(double)freq;

@end