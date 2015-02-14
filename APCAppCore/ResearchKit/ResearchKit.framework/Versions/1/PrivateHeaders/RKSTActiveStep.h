//
//  RKSTActiveStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit_Private.h>

/**
 * @brief The RKSTActiveStep class defines the attributes and behavior of an active test.
 *
 * An active test is a kind of step interacts with participant to collect data.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTActiveStep : RKSTStep

/**
 * @brief The duration of the step in seconds.
 * Default value is 0 (no built in step timer).
 */
@property (nonatomic) NSTimeInterval stepDuration;

/**
 * @brief Whether to show a view with the default timer
 * Defaults to YES.
 * This property is ignored if stepDuration == 0.
 *
 */
@property (nonatomic) BOOL shouldShowDefaultTimer;

/**
 * @brief During timer countdown, counts down the last few seconds with voice
 *
 * Default value is NO.
 */
@property (nonatomic) BOOL shouldSpeakCountDown;


/**
 * @brief Whether to start the count down timer automatically on step start, or click button to start. 
 * 
 * Default value is NO.
 */
@property (nonatomic) BOOL shouldStartTimerAutomatically;

/**
 * @brief Whether to play a default sound on step start.
 *
 * Default value is NO.
 */
@property (nonatomic) BOOL shouldPlaySoundOnStart;

/**
 * @brief Whether to play a default sound on step finish.
 *
 * Default value is NO.
 */
@property (nonatomic) BOOL shouldPlaySoundOnFinish;

/**
 * @brief Whether to vibrate when the step starts.
 *
 * Default value is NO.
 */
@property (nonatomic) BOOL shouldVibrateOnStart;

/**
 * @brief Whether to vibrate when the step finish.
 *
 * Default value is NO.
 */
@property (nonatomic) BOOL shouldVibrateOnFinish;

/**
 * @brief Leave Next button continuously enabled before the step completes.
 * At the same time, hides the skip button.
 *
 * Default value is NO.
 */
@property (nonatomic) BOOL shouldUseNextAsSkipButton;

/**
 * @brief Whether to transition automatically when the step finishes.
 *
 * Default value is NO.
 */
@property (nonatomic) BOOL shouldContinueOnFinish;

/**
 * @brief Instructional voice prompt.
 *
 * Instructional speech begins when the step starts.
 */
@property (nonatomic, copy) NSString *spokenInstruction;

/**
 * @brief Image to be displayed below instructions.
 */
@property (nonatomic, strong) UIImage *image;

/**
 * @brief Recorder configurations.
 *
 * @discussion Recorder configurations define the parameters for recorders to be
 * run during a step.
 *
 */
@property (nonatomic, copy) NSArray *recorderConfigurations;

@property (nonatomic, readonly) NSSet *requestedHealthKitTypesForReading;
@property (nonatomic, readonly) RKPermissionMask requestedPermissions;


@end
