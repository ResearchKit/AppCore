//
//  RKSTRecorder_Private.h
//  Itasca
//
//  Created by John Earl on 10/29/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/ResearchKit_Private.h>
#import <AVFoundation/AVFoundation.h>


@class RKSTResult;
@class RKSTRecorder;



@class RKSTStep;


/**
 * @brief RKSTTouchRecorderConfiguration implements RKSTRecorderConfiguration and able to generate RKSTTouchRecorder instance.
 */
@interface RKSTTouchRecorderConfiguration: RKSTRecorderConfiguration

+ (instancetype)configuration;

@end


@interface RKSTRecorder()

- (instancetype)_init;

/**
 * Designated initializer.
 */
- (instancetype)initWithStep:(RKSTStep*)step
             outputDirectory:(NSURL *)outputDirectory;


/**
 * @brief A preparation step to provide viewController and view before record starting.
 * @note Call this method before starting the recorder.
 */
- (void)viewController:(UIViewController*)viewController willStartStepWithView:(UIView*)view;

/**
 * @brief Recording has failed; stop recording and report the error to the delegate
 */
- (void)finishRecordingWithError:(NSError *)error;

@end

@interface RKSTRecorderConfiguration()

- (instancetype)_init;
@end

/**
 * @brief A recorder that requests and collects raw accelerometer data from CoreMotion at a fixed frequency.
 *
 * The accelerometer recorder continues to record if the application enters the
 * background using UIApplication's background task support.
 */
@interface RKSTAccelerometerRecorder : RKSTRecorder

/**
 * @brief Accelerometer data collection frequency from CoreMotion, unit is hertz (Hz).
 */
@property (nonatomic, readonly) double frequency;

/**
 * @brief Designated initializer
 * @param frequency    Accelerometer data collection frequency, unit is hertz (Hz).
 */
- (instancetype)initWithFrequency:(double)frequency
                             step:(RKSTStep*)step
                  outputDirectory:(NSURL *)outputDirectory;

@end

/**
 * @brief The RKSTAudioRecorder use AVAudioSession to record audio.
 *
 * To ensure audio recording continues if a task enters the background, the
 * application should add the "audio" tag to UIBackgroundModes in its Info.plist.
 */
@interface RKSTAudioRecorder : RKSTRecorder

/**
 * @brief Default audio format settings
 *
 * If no specific settings are specified, the audio configuration is
 * MPEG4 AAC, 2 channels, 16 bit, 44.1 kHz, AVAudioQualityMin.
 */
+ (NSDictionary *)defaultRecorderSettings;

/**
 * @brief Audio format settings
 *
 * Settings for the recording session.
 * Passed to AVAudioRecorder's -initWithURL:settings:error:
 * For information on the settings available for an audio recorder, see "AV Foundation Audio Settings Constants".
 */
@property (nonatomic, copy, readonly) NSDictionary *recorderSettings;

/**
 * @brief Designated initializer
 * @param recorderSettings Settings for the recording session.
 */
- (instancetype)initWithRecorderSettings:(NSDictionary *)recorderSettings
                                    step:(RKSTStep*)step
                         outputDirectory:(NSURL *)outputDirectory;


@property (nonatomic, strong, readonly) AVAudioRecorder *audioRecorder;

@end

/**
 * @brief The RKSTTouchRecorder class defines the attributes and behavior of touch events recorder.
 *
 * Just add its customView to view hierarchy to allow the recorder to receive touch events.
 */
@interface RKSTTouchRecorder : RKSTRecorder

/**
 * @brief The RKSTTouchRecorder attach gesture recognizer to touchView to receive touch events.
 * @note Use (viewController:willStartStepWithView:) to set this.
 */
@property (nonatomic, strong, readonly) UIView* touchView;

@end


/**
 * @brief A recorder that requests and collects device motion data from CoreMotion at a fixed frequency.
 *
 * The motion recorder continues to record if the application enters the
 * background using UIApplication's background task support.
 */
@interface RKSTDeviceMotionRecorder : RKSTRecorder

/**
 * @brief Motion data collection frequency from CoreMotion in Hz.
 */
@property (nonatomic, readonly) double frequency;

/**
 * @brief Designated initializer
 * @param frequency    Accelerometer data collection frequency in Hz
 */
- (instancetype)initWithFrequency:(double)frequency
                             step:(RKSTStep*)step
                  outputDirectory:(NSURL *)outputDirectory;

@end


/**
 * @brief A recorder that requests and collects device motion data from CoreMotion at a fixed frequency.
 *
 * The accelerometer recorder continues to record if the application enters the
 * background using UIApplication's background task support.
 */
@interface RKSTPedometerRecorder : RKSTRecorder

/**
 * @brief Accelerometer data collection frequency from CoreMotion in Hz.
 */
@property (nonatomic, readonly) double frequency;

/**
 * @brief Designated initializer
 * @param frequency    Accelerometer data collection frequency in Hz
 */
- (instancetype)initWithFrequency:(double)frequency
                             step:(RKSTStep*)step
                  outputDirectory:(NSURL *)outputDirectory;

@end

