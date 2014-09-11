//
//  RKActiveStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import "RKStep.h"
#import "RKRecorder.h"

/**
 * @brief The RKActiveStep class defines the attributes and behavior of an active test.
 *
 * An active test is a kind of step interacts with participant to collect data.
 */
@interface RKActiveStep : RKStep

/**
 * @brief The value in seconds for count down timer.
 * Default value is 0.
 *
 * @note If countDown > 0, RKActiveStepViewController displays count down timer in the step view.
 * When timer is down to zero, step view transit to next one.
 */
@property (nonatomic) NSTimeInterval countDown;

/**
 * @brief During timer countdown, counts down the last few seconds with voice
 *
 * Default value is NO.
 */
@property (nonatomic) BOOL speakCountDown;


/**
 * @brief Whether to start the count down timer automatically on step start, or click button to start. 
 * 
 * Default value is NO.
 */
@property (nonatomic) BOOL clickButtonToStartTimer;

/**
 * @brief Make buzz sound from device speaker on step start.
 *
 * Default value is NO.
 */
@property (nonatomic) BOOL buzz;

/**
 * @brief Enable device vibrating alert on step start.
 *
 * Default value is NO.
 */
@property (nonatomic) BOOL vibration;

/**
 * @brief Caption text to be displayed on the screen.
 */
@property (nonatomic, copy) NSString *caption;

/**
 * @brief Instructional text to be displayed on the screen.
 */
@property (nonatomic, copy) NSString *text;

/**
 * @brief Instruction voice prompt.
 *
 * Instructional speech begins at the beginning of the step.
 */
@property (nonatomic, copy) NSString *voicePrompt;


/**
 * @brief Recorder configurations.
 *
 * Recorder configurations define recorders to be used during step.
 * Recorder instances are generated from these configurations.
 * Each recorder instance starts collecting data at beginning of the step and stops at the end of step.
 *
 * @attention All items within this array have to confirm to RKRecorderConfiguration protocol.
 * @seealso RKRecorder.h
 */
@property (nonatomic, copy) NSArray *recorderConfigurations; // <RKRecorderConfiguration>

/**
 * @brief Convenience methods.
 */
- (BOOL)hasCountDown;
- (BOOL)hasCaption;
- (BOOL)hasText;
- (BOOL)hasVoice;

@end
