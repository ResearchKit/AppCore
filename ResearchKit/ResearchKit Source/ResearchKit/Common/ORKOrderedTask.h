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

#import <ResearchKit/ORKTask.h>

ORK_ASSUME_NONNULL_BEGIN

/**
 `ORKOrderedTask` is an `ORKTask` which assumes a fixed order for its steps.
 In ResearchKit, any simple sequential task, such as a survey or an
 active task, can be represented as an `ORKOrderedTask`. This is the most
 straightforward way to use ResearchKit to present a task.
 
 `ORKOrderedTask` implements all the methods in the `ORKTask` protocol.
 
 Often, subclassing `ORKOrderedTask` and overriding certain `ORKTask`
 methods may be a better way to get conditional behaviors than implementing
 the `ORKTask` protocol directly. For example, adding behavior where a certain
 survey question is only shown if the previous question was answered "Yes"
 could be accomplished by overriding only `stepAfterStep:withResult:` and `stepBeforeStep:withResult:`
 and base calling for all except the couple of steps where specific
 conditional logic is required.
 */
ORK_CLASS_AVAILABLE
@interface ORKOrderedTask : NSObject <ORKTask, NSSecureCoding, NSCopying>

/// @name Initializers

/**
 Initialize a task.
 
 @param identifier  Unique indentifier for the task.
 @param steps       Array of `ORKStep`, in the order they should be presented.
 
 @return A new `ORKOrderedTask` instance.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                             steps:(ORK_NULLABLE NSArray *)steps NS_DESIGNATED_INITIALIZER;

/**
 Initialize a task.
 
 `ORKOrderedTask` can be serialized and deserialized with `NSKeyedArchiver`. Note
 that this serialization will include strings that might need to be
 localized.
 
 @param aDecoder    `NSCoder` object.
 
 @return A new `ORKOrderedTask` instance.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/// @name Properties

/**
 The array of steps in the task (read-only).
 
 Each element of the array must be a sub-class of `ORKStep`.
 An `ORKTaskViewController` given this task will present these steps in
 array order.
 */
@property (nonatomic, copy, readonly) NSArray *steps;

@end



/**
 `ORKPredefinedTaskOption` flags are used to exclude certain behaviors from
 the pre-defined active tasks in the Predefined category of `ORKOrderedTask`.
 
 The pre-defined tasks all include instructions and conclusion steps by default.
 They also may include one or more data collection recorder configurations. Not
 all the pre-defined tasks include all these data collection types; but these
 flags can be used to explicitly specify that they not be included.
 */

typedef NS_OPTIONS(NSUInteger, ORKPredefinedTaskOption) {
    /// Default behavior.
    ORKPredefinedTaskOptionNone = 0,
    
    /// Exclude the initial instruction steps.
    ORKPredefinedTaskOptionExcludeInstructions = (1 << 0),
    
    /// Exclude the conclusion step.
    ORKPredefinedTaskOptionExcludeConclusion = (1 << 1),
    
    /// Exclude accelerometer data collection.
    ORKPredefinedTaskOptionExcludeAccelerometer = (1 << 2),
    
    /// Exclude device motion data collection.
    ORKPredefinedTaskOptionExcludeDeviceMotion = (1 << 3),
    
    /// Exclude pedometer data collection using CoreMotion.
    ORKPredefinedTaskOptionExcludePedometer = (1 << 4),
    
    /// Exclude location data collection using CoreLoation.
    ORKPredefinedTaskOptionExcludeLocation = (1 << 5),
    
    /// Exclude heart rate data collection using HealthKit.
    ORKPredefinedTaskOptionExcludeHeartRate = (1 << 6),
    
    /// Exclude audio data collection using AVFoundation.
    ORKPredefinedTaskOptionExcludeAudio = (1 << 7)
} ORK_ENUM_AVAILABLE;


@interface ORKOrderedTask(PredefinedActiveTask)

/**
 Returns a fitness check pre-defined task.
 
 In this task, the participant is asked to walk for a specified
 duration (typically several minutes). During this period various sensor data
 will be collected and returned via the task view controller's delegate. This
 would include accelerometer, device motion, pedometer, location, and heart rate
 data where available.
 
 At the conclusion of the walk, if heart rate data is available, the participant
 is asked to sit down and rest for a period. Data collection continues during this
 period.
 
 By default, the task includes an instruction step which explains what to do
 during the task, but this can be excluded with `ORKPredefinedTaskOptionExcludeInstructions`.
 
 Data collected from this task can be used to compute measures of general fitness.
 
 @param identifier   Task identifier to use for this task, appropriate to the study
 @param intendedUseDescription  Localized string describing the intended use of the data collected.
 If `nil`, the default text will be displayed.
 @param walkDuration Duration the participant should be asked to walk. (max: 10 minutes)
 @param restDuration Duration the participant should be asked to rest after the walk.
 @param options      Options affecting the features of the predefined task.
 @return An active task which can be presented with `ORKTaskViewController`.
 */
+ (ORKOrderedTask *)fitnessCheckTaskWithIdentifier:(NSString *)identifier
                           intendedUseDescription:(ORK_NULLABLE NSString *)intendedUseDescription
                                     walkDuration:(NSTimeInterval)walkDuration
                                     restDuration:(NSTimeInterval)restDuration
                                          options:(ORKPredefinedTaskOption)options;

/**
 Returns a short walk pre-defined task.
 
 In this task, the participant is asked to walk a short distance,
 which may be indoors. Typical uses of the data may be to assess stride length,
 smoothness, sway, or other aspects of the participant's walking.
 
 The presentation of the short walk differs from the fitness check in that
 distance is replaced by the number of steps taken, and the walk is split into
 a series of legs. After each leg, the user is asked to turn and reverse direction.
 
 Data collected: accelerometer, device motion, pedometer.
 
 @param identifier    Task identifier to use for this task, appropriate to the study
 
 @param intendedUseDescription   Localized string describing the intended use of the data collected.
 If `nil`, the default localized text will be displayed.
 
 @param numberOfStepsPerLeg Number of steps the participant should be asked to walk.
 On devices where pedometer is unavailable, a distance will be suggested
 and a suitable countdown timer is displayed instead for each leg.
 
 @param restDuration  If non-zero, when the turn sequence has been completed, the
 user is asked to stand still for a period in order to collect baseline data.
 
 @param options       Options affecting the features of the predefined task.
 
 @return An active task which can be presented with `ORKTaskViewController`.
 
 */
+ (ORKOrderedTask *)shortWalkTaskWithIdentifier:(NSString *)identifier
                        intendedUseDescription:(ORK_NULLABLE NSString *)intendedUseDescription
                           numberOfStepsPerLeg:(NSInteger)numberOfStepsPerLeg
                                  restDuration:(NSTimeInterval)restDuration
                                       options:(ORKPredefinedTaskOption)options;


/**
 Returns an audio recording pre-defined task.
 
 In this task, the participant is asked to make some kind of sound
 with their voice, and the audio data is collected.
 
 For example, this could be used to measure properties of their voice, such as
 frequency range, or ability to pronounce certain sounds.
 
 Data collected: audio.
 
 @param identifier        Task identifier to use for this task, appropriate to the study.
 @param intendedUseDescription       Localized string describing the intended use of the data collected. If `nil`,
            default localized text is used.
 @param speechInstruction  Instruction describing what to do when recording begins. If `nil`,
            default localized text is used.
 @param shortSpeechInstruction Instruction shown during audio recording. If `nil`,
            default localized text is used.
 @param duration          Length of the countdown timer while collecting audio data.
 @param recordingSettings See "AV Foundation Audio Settings Constants".
 @param options           Options affecting the features of the predefined task.
 @return An active task which can be presented with `ORKTaskViewController`.
 
 */

+ (ORKOrderedTask *)audioTaskWithIdentifier:(NSString *)identifier
                    intendedUseDescription:(ORK_NULLABLE NSString *)intendedUseDescription
                         speechInstruction:(ORK_NULLABLE NSString *)speechInstruction
                    shortSpeechInstruction:(ORK_NULLABLE NSString *)shortSpeechInstruction
                                  duration:(NSTimeInterval)duration
                         recordingSettings:(ORK_NULLABLE NSDictionary *)recordingSettings
                                   options:(ORKPredefinedTaskOption)options;


/**
 Returns a two finger tapping pre-defined task.
 
 In this task, the participant is asked to rhythmically, alternately,
 tap two targets on the touch screen.
 
 For example, data from this task can be used to assess basic motor
 capabilities including speed, accuracy, and rhythm.
 
 Data collected: touch activity, accelerometer.
 
 @param identifier        Task identifier to use for this task, appropriate to the study.
 @param intendedUseDescription       Localized string describing the intended use of the data collected. If nil,
            the default localized text will be displayed.
 @param duration          Length of the countdown timer while collecting touch data.
 @param options           Options affecting the features of the predefined task.
 @return An active task which can be presented with `ORKTaskViewController`.
 
 */
+ (ORKOrderedTask *)twoFingerTappingIntervalTaskWithIdentifier:(NSString *)identifier
                                       intendedUseDescription:(ORK_NULLABLE NSString *)intendedUseDescription
                                                     duration:(NSTimeInterval)duration
                                                      options:(ORKPredefinedTaskOption)options;

/**
 Returns a spatial span memory pre-defined task.
 
 The participant is asked to repeat pattern sequences of increasing
 length in a game-like environment. In each round of the game, an array of
 targets (by default, flowers) are shown in a grid. The round consists of a
 demonstration phase, and an interactive phase. In the demonstration phase,
 a sequence of the flowers "light up" in the tint color. The user is asked to
 remember the demonstrated sequence, and tap the flowers in the same sequence
 during the interactive phase.
 
 The "span" (length of the pattern sequence) is automatically varied during the
 task, increasing after successful completion and decreasing after failures, in
 the range (`minimumSpan`, `maximumSpan`).
 
 The speed of sequence playback is controllable, and the shape of the tap target is
 customizable.
 The game finishes when either maxTests tests have been completed, or the participant
 has made maxFailures errors.
 
 This task can be used to assess visuospatial memory and executive function.
 
 Data collected: `ORKSpatialSpanMemoryResult`
 
 @param identifier        Task identifier to use for this task, appropriate to the study.
 @param intendedUseDescription       Localized string describing the intended use of the data collected. If `nil`,
            the default localized text will be displayed.
 @param initialSpan       Initial memory pattern sequence length.
 @param minimumSpan           Minimum pattern sequence length (sequences are never shorter than this).
 @param maximumSpan           Maximum pattern sequence length (sequences are never longer than this).
 @param playSpeed         Time per sequence item (smaller value means faster sequence play).
 @param maxTests          Maximum number of rounds to conduct.
 @param maxConsecutiveFailures       Terminate task if user has this many consecutive failures.
 @param customTargetImage Image to use for the task instead of a flower. If `nil`, we use a flower.
            The custom target image is rendered in template rendering mode, tinted
            to the UIKit tint color. Accordingly, only the alpha channel of the image is used.
 @param customTargetPluralName    Custom name to go with the `customTargetImage`, for example, @"flowers"
 @param requireReversal   Whether to require the user to tap the sequence in reverse order.
 @param options           Options affecting the features of the predefined task.
 @return An active task which can be presented with `ORKTaskViewController`.
 */
+ (ORKOrderedTask *)spatialSpanMemoryTaskWithIdentifier:(NSString *)identifier
                                intendedUseDescription:(ORK_NULLABLE NSString *)intendedUseDescription
                                           initialSpan:(NSInteger)initialSpan
                                           minimumSpan:(NSInteger)minimumSpan
                                           maximumSpan:(NSInteger)maximumSpan
                                             playSpeed:(NSTimeInterval)playSpeed
                                              maxTests:(NSInteger)maxTests
                                maxConsecutiveFailures:(NSInteger)maxConsecutiveFailures
                                     customTargetImage:(ORK_NULLABLE UIImage *)customTargetImage
                                customTargetPluralName:(ORK_NULLABLE NSString *)customTargetPluralName
                                       requireReversal:(BOOL)requireReversal
                                               options:(ORKPredefinedTaskOption)options;


@end


ORK_ASSUME_NONNULL_END

