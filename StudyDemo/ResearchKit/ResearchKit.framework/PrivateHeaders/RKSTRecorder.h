//
//  RKSTRecorder.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@class RKSTRecorder;

/**
 * @brief Abstract base class for recorder configurations.
 *
 * @discussion Recorder configurations provide an easy way to collect CoreMotion
 * or other sensor data into a serialized format during the duration of an active step.
 * If you want to filter or process the data in real time, then it is better to
 * use the existing APIs directly.
 *
 * @note To use a recorder, add its configuration to the RKSTActiveStep's recorderConfigurations
 * list.
 */
@interface RKSTRecorderConfiguration : NSObject<NSSecureCoding>

- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Generates recorder instance.
 * @return A recorder instance, correctly configured according to this configuration.
 */
- (RKSTRecorder*)recorderForStep:(RKSTStep*)step outputDirectory:(NSURL *)outputDirectory;

@end


/**
 * @brief Collects raw accelerometer data
 */
@interface RKSTAccelerometerRecorderConfiguration : RKSTRecorderConfiguration

/**
 * @brief Accelerometer data collection frequency in Hz.
 */
@property (nonatomic, readonly) double frequency;

/**
 * @brief Designated initializer
 * @param frequency Accelerometer data collection frequency in Hz.
 */
- (instancetype)initWithFrequency:(double)freq;

@end


/**
 * @brief Collects audio data
 */
@interface RKSTAudioRecorderConfiguration : RKSTRecorderConfiguration

/**
 * @brief Audio format settings
 *
 * Settings for the recording session.
 * Passed to AVAudioRecorder's -initWithURL:settings:error:
 * For information on the settings available for an audio recorder, see "AV Foundation Audio Settings Constants".
 */
@property (nonatomic, readonly) NSDictionary *recorderSettings;

/**
 * @brief Designated initializer
 * @param recorderSettings Settings for the recording session.
 * @note For information on the settings available for an audio recorder, see "AV Foundation Audio Settings Constants".
 */
- (instancetype)initWithRecorderSettings:(NSDictionary *)recorderSettings;

@end


/**
 * @brief Collects device motion data. See CMMotionManager.
 */
@interface RKSTDeviceMotionRecorderConfiguration : RKSTRecorderConfiguration

/**
 * @brief motion data collection frequency, unit is hertz (Hz).
 */
@property (nonatomic, readonly) double frequency;

/**
 * @brief Designated initializer
 * @param frequency    Accelerometer data collection frequency, unit is hertz (Hz).
 */
- (instancetype)initWithFrequency:(double)freq;

@end


/**
 * @brief Collects pedometer data. See CMPedometer.
 */
@interface RKSTPedometerRecorderConfiguration : RKSTRecorderConfiguration

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


@protocol RKSTRecorderDelegate <NSObject>

/**
 * @brief Tells the delegate that the recorder is completed and pass out recording result.
 * @note The methods will be called when recording is stopped.
 */
- (void)recorder:(RKSTRecorder *)recorder didCompleteWithResult:(RKSTResult *)result;

/**
 * @brief Tells the delegate that recording failed.
 */
- (void)recorder:(RKSTRecorder *)recorder didFailWithError:(NSError *)error;

@end


@interface RKSTRecorder : NSObject

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, weak) id<RKSTRecorderDelegate> delegate;

@property (nonatomic, strong, readonly) RKSTStep *step;

@property (nonatomic, copy, readonly) NSURL *outputDirectory;

- (NSString *)logName;

/**
 * @brief Start data recording.
 * @note If an error occurs as recording starts, it will be returned via the delegate.
 */
- (void)start NS_REQUIRES_SUPER;

/**
 * @brief Stop data recording. Generally triggers return of results.
 * @note If an error occurs when stopping the recorder, it will be returned via the delegate.
 * @note Subclasses should call -finishRecordingWithError: rather than base-call
 */
- (void)stop NS_REQUIRES_SUPER;

/**
 * @brief Recording status.
 * @return YES if recorder is recording, otherwise NO.
 */
@property (nonatomic, readonly, getter=isRecording) BOOL recording;

@end


