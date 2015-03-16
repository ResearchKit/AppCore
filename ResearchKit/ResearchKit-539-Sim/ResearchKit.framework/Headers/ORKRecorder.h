//
//  ORKRecorder.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKStep.h>
#import <HealthKit/HealthKit.h>
#import <ResearchKit/ORKResult.h>

@class ORKRecorder;

/**
 * @brief Abstract base class for recorder configurations.
 *
 * @discussion Recorder configurations provide an easy way to collect CoreMotion
 * or other sensor data into a serialized format during the duration of an active step.
 * If you want to filter or process the data in real time, then it is better to
 * use the existing APIs directly.
 *
 * @note To use a recorder, add its configuration to the ORKActiveStep's recorderConfigurations
 * list.
 */
ORK_CLASS_AVAILABLE
@interface ORKRecorderConfiguration : NSObject<NSSecureCoding>

- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Generates recorder instance.
 * @return A recorder instance, correctly configured according to this configuration.
 */
- (ORKRecorder*)recorderForStep:(ORKStep*)step outputDirectory:(NSURL *)outputDirectory;

- (NSSet *)requestedHealthKitTypesForReading;

@end


/**
 * @brief Collects raw accelerometer data
 */
ORK_CLASS_AVAILABLE
@interface ORKAccelerometerRecorderConfiguration : ORKRecorderConfiguration

/**
 * @brief Accelerometer data collection frequency in Hz.
 */
@property (nonatomic, readonly) double frequency;

/**
 * @param frequency Accelerometer data collection frequency in Hz.
 */
- (instancetype)initWithFrequency:(double)freq NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


/**
 * @brief Collects audio data
 */
ORK_CLASS_AVAILABLE
@interface ORKAudioRecorderConfiguration : ORKRecorderConfiguration

/**
 * @brief Audio format settings
 *
 * Settings for the recording session.
 * Passed to AVAudioRecorder's -initWithURL:settings:error:
 * For information on the settings available for an audio recorder, see "AV Foundation Audio Settings Constants".
 */
@property (nonatomic, readonly) NSDictionary *recorderSettings;

/**
 * @param recorderSettings Settings for the recording session.
 * @note For information on the settings available for an audio recorder, see "AV Foundation Audio Settings Constants".
 */
- (instancetype)initWithRecorderSettings:(NSDictionary *)recorderSettings NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


/**
 * @brief Collects device motion data. See CMMotionManager.
 */
ORK_CLASS_AVAILABLE
@interface ORKDeviceMotionRecorderConfiguration : ORKRecorderConfiguration

/**
 * @brief motion data collection frequency, unit is hertz (Hz).
 */
@property (nonatomic, readonly) double frequency;

/**
 * @param frequency    Accelerometer data collection frequency, unit is hertz (Hz).
 */
- (instancetype)initWithFrequency:(double)freq NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end



/**
 * @brief Collects pedometer data. See CMPedometer.
 */
ORK_CLASS_AVAILABLE
@interface ORKPedometerRecorderConfiguration : ORKRecorderConfiguration

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

/**
 * @brief Configuration for location data collection
 */
ORK_CLASS_AVAILABLE
@interface ORKLocationRecorderConfiguration : ORKRecorderConfiguration

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

/**
 * @brief Configuration for location data collection
 */
ORK_CLASS_AVAILABLE
@interface ORKHealthQuantityTypeRecorderConfiguration : ORKRecorderConfiguration

- (instancetype)initWithHealthQuantityType:(HKQuantityType *)quantityType unit:(HKUnit *)unit NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, copy) HKQuantityType *quantityType;
@property (nonatomic, readonly, copy) HKUnit *unit;

@end

@protocol ORKRecorderDelegate <NSObject>

/**
 * @brief Tells the delegate that the recorder is completed and pass out recording result.
 * @note The methods will be called when recording is stopped.
 */
- (void)recorder:(ORKRecorder *)recorder didCompleteWithResult:(ORKResult *)result;

/**
 * @brief Tells the delegate that recording failed.
 */
- (void)recorder:(ORKRecorder *)recorder didFailWithError:(NSError *)error;

@end


ORK_CLASS_AVAILABLE
@interface ORKRecorder : NSObject

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, weak) id<ORKRecorderDelegate> delegate;

@property (nonatomic, strong, readonly) ORKStep *step;

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


