/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKStep.h>
#import <HealthKit/HealthKit.h>
#import <ResearchKit/ORKResult.h>

ORK_ASSUME_NONNULL_BEGIN

@class ORKRecorder;

/**
 `ORKRecorderConfiguration` is the abstract base class for recorder configurations
 that can be attached to active steps (`ORKActiveStep`).
 
 Recorder configurations provide an easy way to collect CoreMotion
 or other sensor data into a serialized format during the duration of an active step.
 If you want to filter or process the data in real time, then it is better to
 use the existing APIs directly.
 
 To use a recorder, include its configuration in the `[ORKActiveStep recorderConfigurations]`
 of an `ORKActiveStep`, include that step in a task, and present it with
 a task view controller.
 
 To add a new recorder, subclass both `ORKRecorderConfiguration` and `ORKRecorder`,
 and then add the new `ORKRecorderConfiguration` subclass to an `ORKActiveStep`.
 */
ORK_CLASS_AVAILABLE
@interface ORKRecorderConfiguration : NSObject <NSSecureCoding>

/**
 The init method is unavailable outside the framework on `ORKRecorderConfiguration`,
 because it is an abstract class.
 
 `ORKRecorderConfiguration` classes should be initialized with custom designated
 initializers on each subclass.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 Generates a recorder instance from this configuration.
 
 @param step      The step for which this recorder is being generated.
 @param outputDirectory     The directory where any output file data should be written
 (if producing ORKFileResult instances).
 
 @return Returns a recorder instance, correctly configured according to this configuration.
 */
- (ORK_NULLABLE ORKRecorder *)recorderForStep:(ORK_NULLABLE ORKStep *)step outputDirectory:(ORK_NULLABLE NSURL *)outputDirectory;

/**
 Returns the set of HealthKit types for which this recorder requires read access.
 
 Each element of the set is an `HKSampleType`.
 
 If non-nil, in normal usage the `ORKTaskViewController` will automatically collect
 and collate the types of HealthKit data requested by each of the active steps in a task,
 and request access to them at the end of the last of the initial instruction
 steps in the task.
 
 If your recorder requires or would benefit from read access to HealthKit at
 runtime during the task, return the appropriate set of `HKSampleType` objects.
 */
- (ORK_NULLABLE NSSet *)requestedHealthKitTypesForReading;

@end


/**
 The `ORKAccelerometerRecorderConfiguration` recorder configuration configures
 the collection of accelerometer data during an active task.
 
 Generates an `ORKAccelerometerRecorder`.
 
 The data are serialized to JSON and returned as an `ORKFileResult`.
 For details of the format, see `CMAccelerometerData+ORKJSONDictionary`.
 
 To use a recorder, include its configuration in the `[ORKActiveStep recorderConfigurations]`
 of an `ORKActiveStep`, include that step in a task, and present it with
 a task view controller.
 */
ORK_CLASS_AVAILABLE
@interface ORKAccelerometerRecorderConfiguration : ORKRecorderConfiguration

/**
 Accelerometer data collection frequency in samples per second (Hz).
 */
@property (nonatomic, readonly) double frequency;

/**
 Designated Initializer.
 
 @param frequency Accelerometer data collection frequency in samples per second (Hz).
 */
- (instancetype)initWithFrequency:(double)frequency NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end



/**
 The `ORKAudioRecorderConfiguration` class represents a configuration that records
 audio data during an `ORKActiveStep`.
 
 Generates an `ORKAudioRecorder`.
 
 To use a recorder, include its configuration in the `[ORKActiveStep recorderConfigurations]`
 of an `ORKActiveStep`, include that step in a task, and present it with
 a task view controller.
 */
ORK_CLASS_AVAILABLE
@interface ORKAudioRecorderConfiguration : ORKRecorderConfiguration

/**
 The audio format settings for the recorder.
 
 Settings for the recording session, passed to AVAudioRecorder's `initWithURL:settings:error:`
 For information on the settings available for an audio recorder, see "AV Foundation Audio Settings Constants" in
 the AVFoundation documentation.
 
 The results are returned as an `ORKFileResult`, pointing to an audio file.
 */
@property (nonatomic, readonly, ORK_NULLABLE) NSDictionary *recorderSettings;

/**
 Designated initializer.
 
 For information on the settings available for an audio recorder, see "AV Foundation Audio Settings Constants".
 
 @param recorderSettings Settings for the recording session.
 */
- (instancetype)initWithRecorderSettings:(NSDictionary *)recorderSettings NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


/**
 The `ORKDeviceMotionRecorderConfiguration` configuration represents a configuration
 that records device motion data during an `ORKActiveStep`.
 
 Device motion data is the processed motion data output by CoreMotion, obtained
 via `CMMotionManager`. This includes measures of the overall device orientation
 obtained from fusing accelerometer, magnetometer, and gyroscopic data.
 
 The data are serialized to JSON and returned as an `ORKFileResult`.
 For details of the format, see `CMDeviceMotion+ORKJSONDictionary`.
 
 To use a recorder, include its configuration in the `[ORKActiveStep recorderConfigurations]`
 of an `ORKActiveStep`, include that step in a task, and present it with
 a task view controller.
 */
ORK_CLASS_AVAILABLE
@interface ORKDeviceMotionRecorderConfiguration : ORKRecorderConfiguration

/**
 Motion data collection frequency in samples per second (Hz).
 */
@property (nonatomic, readonly) double frequency;

/**
 Designated initializer.
 
 @param frequency    Motion data collection frequency in samples per second (Hz).
 */
- (instancetype)initWithFrequency:(double)frequency NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end



/**
 The `ORKPedometerRecorderConfiguration` configuration represents a configuration
 that records pedometer data during an `ORKActiveStep`.
 
 The pedometer data reported is the processed steps output by CoreMotion, obtained
 via `CMPedometer`. This essentially reports the total number of steps since the
 start of recording, updating every time a significant number of steps have
 been detected.
 
 The data are serialized to JSON and returned as an `ORKFileResult`.
 For details of the format, see `CMPedometerData+ORKJSONDictionary`.
 
 To use a recorder, include its configuration in the `[ORKActiveStep recorderConfigurations]`
 of an `ORKActiveStep`, include that step in a task, and present it with
 a task view controller.
 */
ORK_CLASS_AVAILABLE
@interface ORKPedometerRecorderConfiguration : ORKRecorderConfiguration

/**
 Designated initializer.
 
 No parameters are required; the recorder just instantiates a `CMPedometer`.
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

/**
 The `ORKLocationRecorderConfiguration` configuration represents a configuration
 that records location data during an `ORKActiveStep`.
 
 The location data reported is the location reported by CoreLocation.
 
 If this configuration is included on an active step in a task, the task
 view controller will request access to location data at the end of the 
 last of the initial instruction steps in the task.
 
 The data are serialized to JSON and returned as an `ORKFileResult`.
 For details of the format, consult `CLLocation+ORKJSONDictionary`.
 
 To use a recorder, include its configuration in the `[ORKActiveStep recorderConfigurations]`
 of an `ORKActiveStep`, include that step in a task, and present it with
 a task view controller.
 */
ORK_CLASS_AVAILABLE
@interface ORKLocationRecorderConfiguration : ORKRecorderConfiguration

/**
 Designated initializer.
 
 No parameters are required.
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


/**
 The `ORKHealthQuantityTypeRecorderConfiguration` configuration represents a configuration
 that records data from a HealthKit quantity type during an active step.
 
 To use this configuration successfully, the appropriate HealthKit entitlement
 must be enabled in Xcode for your app.
 
 The data are serialized to JSON and returned as an `ORKFileResult`.
 For details of the format, consult `HKSample+ORKJSONDictionary`.
 
 To use a recorder, include its configuration in the `[ORKActiveStep recorderConfigurations]`
 of an `ORKActiveStep`, include that step in a task, and present it with
 a task view controller.
 */
ORK_CLASS_AVAILABLE
@interface ORKHealthQuantityTypeRecorderConfiguration : ORKRecorderConfiguration

/**
 Designated initializer.
 
 @param quantityType    The quantity type that should be collected during the active task.
 @param unit            The unit for the data that should be collecte and serialized.
 */
- (instancetype)initWithHealthQuantityType:(HKQuantityType *)quantityType unit:(HKUnit *)unit NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 The quantity type to be collected from HealthKit (read-only).
 */
@property (nonatomic, readonly, copy) HKQuantityType *quantityType;


/**
 The unit in which to serialize the data from HealthKit (read-only).
 */
@property (nonatomic, readonly, copy) HKUnit *unit;

@end

/**
 The delegate of the `ORKRecorder` should handle errors, and log the
 completed results.
 
 This protocol is implemented by `ORKActiveStepViewController` and should not 
 normally need to be implemented in an application.
 */
@protocol ORKRecorderDelegate <NSObject>

/**
 Indicates that the recorder has completed, with the specified result.
 
 This method is normally called once when recording is stopped.
 
 @param recorder        The generating recorder object.
 @param result          The generated result.
 */
- (void)recorder:(ORKRecorder *)recorder didCompleteWithResult:(ORK_NULLABLE ORKResult *)result;

/**
 Indicates that recording failed.
 
 This method is usually called once when the error occurred.
 
 @param recorder        The generating recorder object.
 @param error           The error that occurred.
 */
- (void)recorder:(ORKRecorder *)recorder didFailWithError:(NSError *)error;

@end

/**
 Recorders are the runtime companion to an `ORKRecorderConfiguration`, and are
 usually generated by one.
 
 During active tasks, it is often useful to collect one or more pieces of data
 from sensors on the system. In research tasks it is generally not strictly
 necessary to display that data, only to record it in a controlled manner.
 
 Active steps (`ORKActiveStep`) each have an array of recorder configurations
 (`ORKRecorderConfiguration`) identifying the types of data they need to record
 for the duration of the step. When the step starts, the `ORKActiveStepViewController`
 instantiates a recorder for each of the step's recorder configurations.
 It will then start the recorder when the active step is started, and stop the
 recorder when the active step is finished.
 
 The results of recording are typically written to a file in the `outputDirectory`.
 
 Typically the `ORKActiveStepViewController` is the recorder's delegate, and
 receives callbacks when errors occur or when recording is complete.
 */
ORK_CLASS_AVAILABLE
@interface ORKRecorder : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// @name Configuration

@property (nonatomic, weak, ORK_NULLABLE) id<ORKRecorderDelegate> delegate;

/**
 A reference to the step that produced this recorder, configured during initialization.
 */
@property (nonatomic, strong, readonly, ORK_NULLABLE) ORKStep *step;

/**
 A reference to the configuration that produced this recorder.
 */
@property (nonatomic, strong, readonly, ORK_NULLABLE) ORKRecorderConfiguration *configuration;

/**
 The file URL of the output directory configured during initialization.
 
 To set the `outputDirectory` in normal usage, set the `[ORKTaskViewController outputDirectory]`
 on the task view controller before presenting it.
 */
@property (nonatomic, copy, readonly, ORK_NULLABLE) NSURL *outputDirectory;

/**
 Returns the log prefix for the log file.
 */
- (ORK_NULLABLE NSString *)logName;

/// @name Runtime lifecycle

/**
 Starts data recording.
 
 If an error occurs as recording starts, it will be returned via the delegate.
 */
- (void)start NS_REQUIRES_SUPER;

/**
 Stops data recording. Generally triggers return of results.
 
 If an error occurs when stopping the recorder, it will be returned via the delegate.
 Subclasses should call `finishRecordingWithError:` rather than base-call.
 */
- (void)stop NS_REQUIRES_SUPER;

/**
 A boolean value indicating whether the recorder is currently recording.
 
 @return Returns `YES` if the recorder is recording; otherwise, `NO`.
 */
@property (nonatomic, readonly, getter=isRecording) BOOL recording;

@end

ORK_ASSUME_NONNULL_END

