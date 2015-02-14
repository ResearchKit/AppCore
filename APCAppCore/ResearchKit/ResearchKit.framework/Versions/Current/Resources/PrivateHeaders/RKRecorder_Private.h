//
//  RKRecorder_Private.h
//  Itasca
//
//  Created by John Earl on 10/29/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/ResearchKit_Private.h>
#import <AVFoundation/AVFoundation.h>
#import <ResearchKit/RKRecorder.h>


@class RKResult;
@class RKRecorder;



@class RKStep;


/**
 * @brief RKTouchRecorderConfiguration implements RKRecorderConfiguration and able to generate RKTouchRecorder instance.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKTouchRecorderConfiguration: RKRecorderConfiguration

+ (instancetype)configuration;

@end


@interface RKRecorder()

- (instancetype)_init;

- (instancetype)initWithStep:(RKStep*)step
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


@interface RKRecorderConfiguration()

- (instancetype)_init;

- (RKPermissionMask)requestedPermissionMask;


@end

/**
 * @brief A recorder that requests and collects raw accelerometer data from CoreMotion at a fixed frequency.
 *
 * The accelerometer recorder continues to record if the application enters the
 * background using UIApplication's background task support.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKAccelerometerRecorder : RKRecorder

/**
 * @brief Accelerometer data collection frequency from CoreMotion, unit is hertz (Hz).
 */
@property (nonatomic, readonly) double frequency;

/**
 * @param frequency    Accelerometer data collection frequency, unit is hertz (Hz).
 */
- (instancetype)initWithFrequency:(double)frequency
                             step:(RKStep*)step
                  outputDirectory:(NSURL *)outputDirectory NS_DESIGNATED_INITIALIZER;

@end

/**
 * @brief The RKAudioRecorder use AVAudioSession to record audio.
 *
 * To ensure audio recording continues if a task enters the background, the
 * application should add the "audio" tag to UIBackgroundModes in its Info.plist.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKAudioRecorder : RKRecorder

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
 * @param recorderSettings Settings for the recording session.
 */
- (instancetype)initWithRecorderSettings:(NSDictionary *)recorderSettings
                                    step:(RKStep*)step
                         outputDirectory:(NSURL *)outputDirectory NS_DESIGNATED_INITIALIZER;


@property (nonatomic, strong, readonly) AVAudioRecorder *audioRecorder;

@end

/**
 * @brief The RKTouchRecorder class defines the attributes and behavior of touch events recorder.
 *
 * Just add its customView to view hierarchy to allow the recorder to receive touch events.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKTouchRecorder : RKRecorder

/**
 * @brief The RKTouchRecorder attach gesture recognizer to touchView to receive touch events.
 * @note Use (viewController:willStartStepWithView:) to set this.
 */
@property (nonatomic, strong, readonly) UIView* touchView;

@end

/**
 * @brief A recorder for collecting location from CoreLocation
 *
 * Location data is identifying information and special care should be taken
 * in handling it or to remove or otherwise prepare it for a
 * de-identified data set.
 *
 * The accuracy of location data may also be limited indoors.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKLocationRecorder : RKRecorder


@end


@class RKHealthQuantityTypeRecorder;

@protocol RKHealthQuantityTypeRecorderDelegate <RKRecorderDelegate>

@optional

- (void)healthQuantityTypeRecorderDidUpdate:(RKHealthQuantityTypeRecorder *)healthQuantityTypeRecorder;

@end

/**
 * @brief A recorder for collecting real time sample data from HealthKit during
 * an active task. (e.g. heart-rate)
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKHealthQuantityTypeRecorder : RKRecorder

@property (nonatomic, readonly, copy) HKQuantityType *quantityType;
@property (nonatomic, readonly, copy) HKUnit *unit;
@property (nonatomic, readonly, copy) HKQuantitySample *lastSample;

- (instancetype)initWithHealthQuantityType:(HKQuantityType *)quantityType
                                      unit:(HKUnit *)unit
                                      step:(RKStep *)step
                           outputDirectory:(NSURL *)outputDirectory NS_DESIGNATED_INITIALIZER;

@end


/**
 * @brief A recorder that requests and collects device motion data from CoreMotion at a fixed frequency.
 *
 * The motion recorder continues to record if the application enters the
 * background using UIApplication's background task support.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKDeviceMotionRecorder : RKRecorder

/**
 * @brief Motion data collection frequency from CoreMotion in Hz.
 */
@property (nonatomic, readonly) double frequency;

/**
 * @param frequency    Accelerometer data collection frequency in Hz
 */
- (instancetype)initWithFrequency:(double)frequency
                             step:(RKStep*)step
                  outputDirectory:(NSURL *)outputDirectory NS_DESIGNATED_INITIALIZER;

@end

@class RKPedometerRecorder;

@protocol RKPedometerRecorderDelegate <RKRecorderDelegate>

@optional

- (void)pedometerRecorderDidUpdate:(RKPedometerRecorder *)pedometerRecorder;

@end

/**
 * @brief A recorder that requests and collects device motion data from CoreMotion at a fixed frequency.
 *
 * The accelerometer recorder continues to record if the application enters the
 * background using UIApplication's background task support.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKPedometerRecorder : RKRecorder

@property (nonatomic, readonly) NSDate *lastUpdateDate;
@property (nonatomic, readonly) NSInteger totalNumberOfSteps;
@property (nonatomic, readonly) NSInteger totalDistance; // negative for invalid value

- (instancetype)initWithStep:(RKStep*)step
             outputDirectory:(NSURL *)outputDirectory NS_DESIGNATED_INITIALIZER;

@end

