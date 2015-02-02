//
//  RKSTTask.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKSTDefines.h>
#import <ResearchKit/RKSTStep.h>
#import <ResearchKit/RKSTResult.h>


typedef struct _RKSTTaskProgress {
    NSUInteger current;
    NSUInteger total;
} RKSTTaskProgress RKST_AVAILABLE_IOS(8_3);

RKSTTaskProgress RKSTTaskProgressMake(NSUInteger current, NSUInteger total) RKST_AVAILABLE_IOS(8_3);

/**
 * @brief The RKSTTask protocol defines a task to be carried out by a participant
 *   in a research study.
 *
 * @note Implement this protocol to enable dynamic selection of the steps for a given task.
 *   For simple sequential tasks, RKSTOrderedTask implements this protocol.
 */
RKST_AVAILABLE_IOS(8_3)
@protocol RKSTTask <NSObject>

@required
/**
 * @brief Task identifier.
 * @discussion This should be a short string which identifies the task. It will be composed
 * with the step's identifier in "." separated format (<taskId>.<stepId>) when producing
 * an identifier for the results of a step.
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 * @brief Supply the step after a step, if there is any.
 * @param step             Reference step.
 * @param result   Snapshot of the current set of results, for context.
 * @discussion Use the result to determine the next step.
 * @return The step after the reference step, or nil if none.
 */
- (RKSTStep *)stepAfterStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result;

/**
 * @brief Supply the step before a step.
 * @param step             Reference step.
 * @param result   Snapshot of the current set of results, for context.
 * @discussion Returning nil can prevent user to revisit previous step.
 * @return The step before the reference step, or nil if none.
 */
- (RKSTStep *)stepBeforeStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result;

@optional

/**
 * @brief Supply the step matching the provided identifier.
 * @param identifier  The identifier of the step to return.
 * @discussion Implementing this method allows state restoration of a task
 * to the particular step. Without this, RKSTTaskViewController will restore
 * to the first step of the task.
 * @return The step matching the provided identifier.
 */
- (RKSTStep *)stepWithIdentifier:(NSString *)identifier;

/**
 * @brief Progress of current step.
 * @param step            Reference step.
 * @param result  Snapshot of the current set of results, for context.
 * @discussion If this method is not implemented, the progress label will not show. If the returned progress has a count of 0, progress will not be displayed.
 * @return Current step's index and total number of steps.
 */
- (RKSTTaskProgress)progressOfCurrentStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result;

/**
 * @brief Set of HKObjectType to request for reading from HealthKit during this task.
 */
@property (nonatomic, copy, readonly) NSSet *requestedHealthKitTypesForReading;


@end


/**
 * @brief Simple implementation of RKSTTask, where all steps are presented in order.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTOrderedTask : NSObject <RKSTTask, NSSecureCoding, NSCopying>

/**
 * @brief Initialize a task
 * @param identifier  Task's unique indentifier.
 * @param steps       An array of steps in fixed order.
 */

- (instancetype)initWithIdentifier:(NSString *)identifier
                             steps:(NSArray *)steps NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, readonly) NSArray *steps;

@end




typedef NS_OPTIONS(NSUInteger, RKPredefinedTaskOption) {
    RKPredefinedTaskOptionNone = 0,
    
    RKPredefinedTaskOptionExcludeInstructions = (1 << 0),
    RKPredefinedTaskOptionExcludeConclusion = (1 << 1),
    
    RKPredefinedTaskOptionExcludeAccelerometer = (1 << 2),
    RKPredefinedTaskOptionExcludeDeviceMotion = (1 << 3),
    RKPredefinedTaskOptionExcludePedometer = (1 << 4),
    RKPredefinedTaskOptionExcludeLocation = (1 << 5),
    RKPredefinedTaskOptionExcludeHeartRate = (1 << 6),
    RKPredefinedTaskOptionExcludeAudio = (1 << 7)
} RK_ENUM_AVAILABLE_IOS(8_3);


@interface RKSTOrderedTask(Predefined)

/**
 @brief Predefined task - fitness check
 
 @discussion In this task, the participant is asked to walk for a specified
 duration (typically several minutes). During this period various sensor data
 will be collected and returned via the task view controller's delegate. This
 would include accelerometer, device motion, pedometer, location, and heart rate
 data where available.
 
 At the conclusion of the walk, if heart rate data is available, the participant
 is asked to sit down and rest for a period. Data collection continues during this
 period.
 
 By default, the task includes an instruction step which explains what to do
 during the task, but this can be excluded with `RKPredefinedTaskOptionExcludeInstructions`.
 
 Data collected from this task can be used to compute measures of general fitness.
 
 @param identifier   Task identifier to use for this task, appropriate to the study
 @param intendedUse  Localized string describing the intended use of the data collected.
 If nil, the default text will be displayed.
 @param walkDuration Duration the participant should be asked to walk. (max: 10 minutes)
 @param restDuration Duration the participant should be asked to rest after the walk.
 @param options      Options affecting the features of the predefined task.
 @return An active task which can be presented with RKSTTaskViewController.
 
 */
+ (RKSTOrderedTask *)fitnessCheckTaskWithIdentifier:(NSString *)identifier
                    intendedUseDescription:(NSString *)intendedUseDescription
                              walkDuration:(NSTimeInterval)walkDuration
                              restDuration:(NSTimeInterval)restDuration
                                   options:(RKPredefinedTaskOption)options;

/**
 @brief Predefined task - short walk
 
 @discussion In this task, the participant is asked to walk a short distance,
 which may be indoors. Typical uses of the data may be to assess stride length,
 smoothness, sway, or other aspects of the participant's walking.
 
 The presentation of the short walk differs from the fitness check in that
 distance is replaced by the number of steps taken, and the walk is split into
 a series of legs. After each leg, the user is asked to turn and reverse direction.
 
 Data collected: accelerometer, device motion, pedometer.
 
 @param identifier    Task identifier to use for this task, appropriate to the study
 
 @param intendedUseDescription   Localized string describing the intended use of the data collected.
 If nil, the default text will be displayed.
 
 @param numberOfSteps Number of steps the participant should be asked to walk.
 On devices where pedometer is unavailable, a distance will be suggested
 and a suitable countdown timer is displayed instead for each leg.
 
 @param restDuration  If non-zero, when the turn sequence has been completed, the
 user is asked to stand still for a period in order to collect baseline data.
 
 @param options       Options affecting the features of the predefined task.
 
 @return An active task which can be presented with RKSTTaskViewController.
 
 */
+ (RKSTOrderedTask *)shortWalkTaskWithIdentifier:(NSString *)identifier
                        intendedUseDescription:(NSString *)intendedUseDescription
                           numberOfStepsPerLeg:(NSInteger)numberOfStepsPerLeg
                                  restDuration:(NSTimeInterval)restDuration
                                       options:(RKPredefinedTaskOption)options;


/**
 @brief Predefined task - Audio
 
 @discussion In this task, the participant is asked to make some kind of sound
 with their voice, and the audio data is collected.
 
 For example, this could be used to measure properties of their voice, such as
 frequency range, or ability to pronounce certain sounds.
 
 Data collected: audio.
 
 @param identifier        Task identifier to use for this task, appropriate to the study.
 @param intendedUse       Localized string describing the intended use of the data collected.
 @param speechInstruction Instruction describing what kind of sound to make.
 @param shortSpeechInstruction  Short instruction to be displayed while sound is being collected.
 @param duration          Length of the countdown timer while collecting audio data.
 @param recordingSettings See "AV Foundation Audio Settings Constants".
 @param options           Options affecting the features of the predefined task.
 @return An active task which can be presented with RKSTTaskViewController.
 
 */

+ (RKSTOrderedTask *)audioTaskWithIdentifier:(NSString *)identifier
                    intendedUseDescription:(NSString *)intendedUseDescription
                         speechInstruction:(NSString *)speechInstruction
                    shortSpeechInstruction:(NSString *)shortSpeechInstruction
                                  duration:(NSTimeInterval)duration
                         recordingSettings:(NSDictionary *)recordingSettings
                                   options:(RKPredefinedTaskOption)options;


/**
 @brief Predefined task - Two finger tapping
 
 @discussion In this task, the participant is asked to rhythmically, alternately,
 tap two targets on the touch screen.
 
 For example, data from this task can be used to assess basic motor
 capabilities including speed, accuracy, and rhythm.
 
 Data collected: touch activity, accelerometer.
 
 @param identifier        Task identifier to use for this task, appropriate to the study.
 @param intendedUse       Localized string describing the intended use of the data collected.
 @param duration          Length of the countdown timer while collecting touch data.
 @param options           Options affecting the features of the predefined task.
 @return An active task which can be presented with RKSTTaskViewController.
 
 */
+ (RKSTOrderedTask *)twoFingerTappingIntervalTaskWithIdentifier:(NSString *)identifier
                                       intendedUseDescription:(NSString *)intendedUseDescription
                                                     duration:(NSTimeInterval)duration
                                                      options:(RKPredefinedTaskOption)options;

/**
 @brief Predefined task - Spatial span memory
 
 @discussion The participant is asked to repeat pattern sequences of increasing
 length in a game-like environment.
 
 The "span" (length of the pattern sequence) is automatically varied during the
 task, increasing after successful completion and decreasing after failures, in
 the range [minimumSpan, maximumSpan].
 
 The speed of sequence playback is controllable, and the shape of the tap target is
 customizable.
 The game finishes when either maxTests tests have been completed, or the participant
 has made maxFailures errors.
 
 This task can be used to assess visuospatial memory and executive function.
 
 Data collected: RKSTSpatialSpanMemoryResult
 
 @param identifier        Task identifier to use for this task, appropriate to the study.
 @param intendedUse       Localized string describing the intended use of the data collected.
 @param initialSpan       Initial memory pattern sequence length.
 @param minSpan           Minimum pattern sequence length (sequences are never shorter than this).
 @param maxSpan           Maximum pattern sequence length (sequences are never longer than this).
 @param playSpeed         Time per sequence item (smaller value means faster sequence play).
 @param maxTests          Maximum number of rounds to conduct.
 @param maxConsecutiveFailures       Terminate task if user has this many consecutive failures.
 @param customTargetImage Image to use for the task instead of a flower. If nil, we use a flower.
 @param customTargetPluralName    Custom name to go with the customTargetImage, for example, @"flowers"
 @param requireReversal   Whether to require the user to tap the sequence in reverse order.
 @param options           Options affecting the features of the predefined task.
 @return An active task which can be presented with RKSTTaskViewController.
 */
+ (RKSTOrderedTask *)spatialSpanMemoryTaskWithIdentifier:(NSString *)identifier
                                intendedUseDescription:(NSString *)intendedUseDescription
                                           initialSpan:(NSInteger)initialSpan
                                           minimumSpan:(NSInteger)minimumSpan
                                           maximumSpan:(NSInteger)maximumSpan
                                             playSpeed:(NSTimeInterval)playSpeed
                                              maxTests:(NSInteger)maxTests
                                maxConsecutiveFailures:(NSInteger)maxConsecutiveFailures
                                     customTargetImage:(UIImage *)customTargetImage
                                customTargetPluralName:(NSString *)customTargetPluralName
                                       requireReversal:(BOOL)requireReversal
                                               options:(RKPredefinedTaskOption)options;


@end


