//
//  RKRecorder.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@class RKRecorder;

/**
 * @brief Abstract base class for recorder configurations.
 *
 * @discussion Recorder configurations provide an easy way to collect CoreMotion
 * or other sensor data into a serialized format during the duration of an active step.
 * If you want to filter or process the data in real time, then it is better to
 * use the existing APIs directly.
 *
 * @note To use a recorder, add its configuration to the RKActiveStep's recorderConfigurations
 * list.
 */
@interface RKRecorderConfiguration : NSObject<NSSecureCoding>

- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Generates recorder instance.
 * @return A recorder instance, correctly configured according to this configuration.
 */
- (RKRecorder*)recorderForStep:(RKStep*)step outputDirectory:(NSURL *)outputDirectory;

@end


/**
 * @brief Collects raw accelerometer data
 */
@interface RKAccelerometerRecorderConfiguration : RKRecorderConfiguration

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
@interface RKAudioRecorderConfiguration : RKRecorderConfiguration

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
@interface RKDeviceMotionRecorderConfiguration : RKRecorderConfiguration

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
@interface RKPedometerRecorderConfiguration : RKRecorderConfiguration

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


@protocol RKRecorderDelegate <NSObject>

/**
 * @brief Tells the delegate that the recorder is completed and pass out recording result.
 * @note The methods will be called when recording is stopped.
 */
- (void)recorder:(RKRecorder *)recorder didCompleteWithResult:(RKResult *)result;

/**
 * @brief Tells the delegate that recording failed.
 */
- (void)recorder:(RKRecorder *)recorder didFailWithError:(NSError *)error;

@end


@interface RKRecorder : NSObject

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, weak) id<RKRecorderDelegate> delegate;

@property (nonatomic, strong, readonly) RKStep *step;

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


