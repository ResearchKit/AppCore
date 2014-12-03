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
@interface RKSTActiveStep : RKSTStep

/**
 * @brief The value in seconds for count down timer.
 * Default value is 0.
 *
 * @note If countDown > 0, RKSTActiveStepViewController displays count down timer in the step view.
 * When timer is down to zero, step view transit to next one.
 */
@property (nonatomic) NSTimeInterval countDownInterval;

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
 * @brief Whether to vibrate when the step starts.
 *
 * Default value is NO.
 */
@property (nonatomic) BOOL shouldVibrateOnStart;

/**
 * @brief Leave Next button continuously enabled before the step completes.
 * At the same time, hides the skip button.
 *
 * Default value is NO.
 */
@property (nonatomic) BOOL shouldUseNextAsSkipButton;

/**
 * @brief Instructional voice prompt.
 *
 * Instructional speech begins when the step starts.
 */
@property (nonatomic, copy) NSString *spokenInstruction;


/**
 * @brief Recorder configurations.
 *
 * @discussion Recorder configurations define the parameters for recorders to be
 * run during a step.
 *
 */
@property (nonatomic, copy) NSArray *recorderConfigurations;


@end
