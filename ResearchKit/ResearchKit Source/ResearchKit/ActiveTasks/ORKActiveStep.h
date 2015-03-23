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
#import <UIKit/UIKit.h>

ORK_ASSUME_NONNULL_BEGIN

/**
 The `ORKActiveStep` class is the base class for steps in active tasks, which
 are steps that collect sensor data in a semi-controlled environment, as opposed
 to the purely passive data collection of HealthKit, or the more subjective data
 collected with surveys.
 
 In addition to the behaviors of an `ORKStep`, active steps have a concept of
 lifecycle, with a defined "start" and a defined "finish".
 
 Active steps can play voice prompts, speak a countdown, and can have a
 defined duration, all using built-in behaviors.
 
 But almost all active steps involve subclassing `ORKActiveStep` and
 `ORKActiveStepViewController`, in order to present custom UI and custom
 prompts. For example, see `ORKSpatialSpanMemoryStep` or `ORKFitnessStep`.
 Active steps may also need `ORKResult` subclasses to record their results
 if these don't come purely from recorders.
 
 If you are developing a new active step subclass, consider contributing your
 code back to ResearchKit in order to make it available for others to use in
 their studies.
 
 See also: `ORKActiveStepViewController`
 */
ORK_CLASS_AVAILABLE
@interface ORKActiveStep : ORKStep

/**
 The duration of the step in seconds.
 
 If the step duration is greater than zero, a built-in timer starts when the
 step starts. If `shouldStartTimerAutomatically` is set, then the timer will
 start when the step's view appears. When the timer expires, a sound or
 vibration may be played. If `shouldContinueOnFinish` is set, then the step
 will automatically navigate forward when the timer expires.
 
 The default value is 0, which disables the built-in timer.
 
 See also: `ORKActiveStepViewController`
 */
@property (nonatomic) NSTimeInterval stepDuration;

/**
 A boolean value indicating whether to show a view with a default timer.
 
 The default timer UI is not used in any of the current pre-defined tasks,
 but can be displayed in a simple active task which does not require custom
 UI and only needs a count-down timer on screen during data collection.
 
 This property defaults to `YES`. This property is ignored if `stepDuration` is 0.
 */
@property (nonatomic) BOOL shouldShowDefaultTimer;

/**
 A boolean value indicating whether to count down the last few seconds of the step
 duration out loud on a timed step.
 
 Uses `AVSpeechSynthesizer` to synthesize the countdown. This property is ignored
 if VoiceOver is enabled.
 
 This property defaults to `NO`.
 */
@property (nonatomic) BOOL shouldSpeakCountDown;


/**
 A boolean value indicating whether to start the count down timer automatically on step start, or
 require the user to take some explicit action, such as tapping a button, to start.
 
 Usually the explicit action would need to come from custom UI in an
 `ORKActiveStepViewController` subclass.
 
 This property defaults to `NO`.
 */
@property (nonatomic) BOOL shouldStartTimerAutomatically;

/**
 A boolean value indicating whether to play a default sound on step start.
 
 This property defaults to `NO`.
 */
@property (nonatomic) BOOL shouldPlaySoundOnStart;

/**
 A boolean value indicating whether to play a default sound on step finish.
 
 This property defaults to `NO`.
 */
@property (nonatomic) BOOL shouldPlaySoundOnFinish;

/**
 A boolean value indicating whether to vibrate when the step starts.
 
 This property defaults to `NO`.
 */
@property (nonatomic) BOOL shouldVibrateOnStart;

/**
 A boolean value indicating whether to vibrate when the step finishes.
 
 This property defaults to `NO`.
 */
@property (nonatomic) BOOL shouldVibrateOnFinish;

/**
 A boolean value indicating whether the Next button should double as a "skip" action before
 the step finishes.
 
 Hides the skip button, and makes the Next button function as a "skip" button
 when the step has not yet finished.
 
 This property defaults to `NO`.
 */
@property (nonatomic) BOOL shouldUseNextAsSkipButton;

/**
 A boolean value indicating whether to transition automatically when the step finishes.
 
 If `YES`, the active step view controller will automatically perform the
 "continue" action when the `[ORKActiveStepViewController finish]` method 
 is called.
 
 This property defaults to `NO`.
 */
@property (nonatomic) BOOL shouldContinueOnFinish;

/**
 Localized text for an instructional voice prompt.
 
 Instructional speech begins when the step starts. If VoiceOver is active,
 the instruction is spoken with VoiceOver.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *spokenInstruction;

/**
 An image to be displayed below the instructions for the step.
 
 This image may be stretched to fit the available space. When choosing a size
 for this asset, do take into account variation in device form factors.
 */
@property (nonatomic, strong, ORK_NULLABLE) UIImage *image;

/**
 Recorder configurations define the parameters for recorders to be
 run during a step to collect sensor or other data.
 
 If you wish to collect data from sensors while this step is in progress,
 attach one or more recorder configurations here. The active step view
 controller will instantiate recorders, and collate their results as children
 of the step result.
 
 The set of recorder configurations is scanned when populating the
 `requestedHealthKitTypesForReading` and `requestedPermissions` properties.
 
 See also: `ORKRecorderConfiguration` and `ORKRecorder`.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSArray *recorderConfigurations;


/**
 The set of HealthKit types requested for reading (read-only property).
 
 The task view controller uses this set of types when constructing a list of
 all the HealthKit types required by all the steps in a task, so that it can
 present the HealthKit access dialog just once during that task.
 
 The default implementation scans the recorders and collates the HealthKit
 types the recorders require. Subclasses may override this method.
 */
@property (nonatomic, readonly, ORK_NULLABLE) NSSet *requestedHealthKitTypesForReading;

/**
 The set of access permissions required for this step (read-only property).
 
 The permission mask is used by the task view controller to decide what
 access to request from users when they complete the initial instruction steps
 in a task. If your step requires access to APIs which limit access, include
 the permissions you require in this mask.
 
 The default implementation scans the recorders and collates the permissions
 required by the recorders. Subclasses may override this method.
 */
@property (nonatomic, readonly) ORKPermissionMask requestedPermissions;


@end

ORK_ASSUME_NONNULL_END
