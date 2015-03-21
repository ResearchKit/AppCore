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


#import <UIKit/UIKit.h>
#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKRecorder.h>

ORK_ASSUME_NONNULL_BEGIN

@class ORKStep;
@class ORKResult;
@class ORKEditableResult;
@class ORKStepViewController;
@class ORKTaskViewController;
@class ORKStepResult;

/**
 Used in `ORKStepViewControllerDelegate` to indicate the direction of navigation
 requested by the participant.
 */
typedef NS_ENUM(NSInteger, ORKStepViewControllerNavigationDirection) {
    
    /// Forward navigation. Indicates that the user tapped the "Continue" or "Next" button.
    ORKStepViewControllerNavigationDirectionForward,
    
    /// Backward navigation. Indicates that the user tapped the "Back" button.
    ORKStepViewControllerNavigationDirectionReverse
} ORK_ENUM_AVAILABLE;


/**
 The primary implementer of the `ORKStepViewControllerDelegate` protocol is
 `ORKTaskViewController`. The task view controller observes these messages in order
 to correctly update its result property, and in order to control navigation
 through the task.
 
 If presenting step view controllers outside of an `ORKTaskViewController`, it
 may be helpful to implement this protocol to facilitate navigation and
 results collection.
 */
@protocol ORKStepViewControllerDelegate <NSObject>

@required

/**
 Called when the user has done something that requires navigation, such as
 tap the back button, tap the "Next" button, or enter a response to a non-optional
 survey question.
 
 @param stepViewController     The step view controller providing the callback.
 @param direction              Direct of navigation requested.
 */
- (void)stepViewController:(ORKStepViewController *)stepViewController didFinishWithNavigationDirection:(ORKStepViewControllerNavigationDirection)direction;

/**
 Called when a substantial change has occurred to the result.
 
 The result is continuously available on the step view controller. The timestamps
 on the result property are different each time it is called while the step
 view controller is active, so in some sense the result is continuously changing.
 In contrast, this delegate method is called only when a substantive change
 to the result occurs, such as when the user enters a survey answer or completes
 an active step.
 
 In this delegate method, collect the `result` from the step view controller.
 
 @param stepViewController     The step view controller providing the callback.
 */
- (void)stepViewControllerResultDidChange:(ORKStepViewController *)stepViewController;

/**
 Called when a step fails due to an error.
 
 This can be used by a step view controller to report its failure to the task view controller.
 The task view controller will send the error to its delegate indicating that the task has failed (`ORKTaskViewControllerResultFailed`).
 Recorder errors are reported through [`ORKStepViewControllerDelegate stepViewController:recorder:didFailWithError:`].
 
 @param stepViewController     The step view controller providing the callback.
 @param error                  The error detected.
 */
- (void)stepViewControllerDidFail:(ORKStepViewController *)stepViewController withError:(ORK_NULLABLE NSError *)error;


/**
 Called when a recorder error has been detected during the step.
 
 Recorder errors can occur during active steps, usually due to 
 unavailability of sensor data or disk space to record results.
 
 @param stepViewController     The step view controller providing the callback.
 @param recorder               The recorder that detected the error.
 @param error                  The error detected.
 */
- (void)stepViewController:(ORKStepViewController *)stepViewController recorder:(ORKRecorder *)recorder didFailWithError:(NSError *)error;

@optional

/**
 Called from the step view controller's `viewWillAppear:` method.
 
 This gives an opportunity to customize the appearance of the step view
 controller without subclassing.
 
 @param stepViewController          The step view controller providing the callback.
*/
- (void)stepViewControllerWillAppear:(ORKStepViewController *)stepViewController;

/**
 The step view controller asks its delegate whether there is a "previous" step.
 
 If there is a previous step, the step view controller adds a back button to its
 navigationItem.
 
 If not implemented, no back button is added to the navigationItem.
 
 @param stepViewController     The step view controller providing the callback.
 
 @return Returns `YES`, if a back button should be visible. `NO`, otherwise.
 */
- (BOOL)stepViewControllerHasPreviousStep:(ORKStepViewController *)stepViewController;

/**
 The step view controller asks its delegate whether there is a "next" step.
 
 Based on the result, the step view controller adjusts the language for the
 "Next" button.
 
 @param stepViewController     The step view controller providing the callback.
 
 @return Returns `YES`, if there is a step following this one.
 */
- (BOOL)stepViewControllerHasNextStep:(ORKStepViewController *)stepViewController;

@end

/**
 The `ORKStepViewController` class is a base class for view controllers that are
 presented by `ORKTaskViewController` for the steps in an `ORKTask`.
 
 In ResearchKit, each step collects some information or data from the user. 
 The step view controller is normally instantiated by the task view controller
 just before presenting the next step (`ORKStep`) in the task.
 
 When creating a new type of step, it is usually necessary to subclass
 `ORKStepViewController`. For example, see `ORKQuestionStepViewController`, or
 `ORKFormStepViewController`. Active steps have additional lifecycle, so their
 view controllers typically subclass `ORKActiveStepViewController` instead, in
 parallel with the step class hierarchy below `ORKActiveStep`.
 
 If merely trying to change some of the runtime behaviors of `ORKStepViewController`,
 it is usually not necessary to subclass. Instead, implement the
 [ORKTaskViewControllerDelegate taskViewController:stepViewControllerWillAppear:] method in
 the `ORKTaskViewControllerDelegate` protocol, and modify the appropriate properties
 of the step view controller. For example, to change the title of the "Learn More"
 or "Next" button, simply set the `learnMoreButtonTitle` or `continueButtonTitle`
 properties in your implementation of this delegate method.
 */
ORK_CLASS_AVAILABLE
@interface ORKStepViewController : UIViewController

/**
 Convenience initializer.
 
 @param step    The step to be presented.
 @return Returns a new instance.
 */
- (instancetype)initWithStep:(ORK_NULLABLE ORKStep *)step;

/**
 The step to be presented.
 
 If loading from a storyboard, such that `initWithStep:` cannot be called, set
 the step property directly before the step view controller is presented.
 
 Setting the step after the controller has been presented is an error and will
 generate an exception.
 Modifying the step after the controller has been presented is an error and
 will have undefined results.
 
 Subclasses which override the setter must base-call.
 */
@property (nonatomic, strong, ORK_NULLABLE) ORKStep *step;

/**
 The delegate of the step view controller.
 
 The delegate is normally the `ORKTaskViewController` presenting the step view
 controller. If it is necessary to intercept these delegate methods, it is acceptable
 to assign a "man in the middle" object as delegate and forward the messages
 to the task view controller.
 */
@property (nonatomic, weak, ORK_NULLABLE) id<ORKStepViewControllerDelegate> delegate;


/**
 The title to use for the Continue button.
 
 Most steps have a button used for forward navigation. This can have titles
 such as "Next", "Continue", or "Done". Use this property to override that
 button title for a particular step.
 
 Set the continue button title with a localizable string to override the
 title of the continue button.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *continueButtonTitle;


/**
 The title to use for the "Learn More" button.
 
 Many steps have a button used when there is more information about that
 step than can fit on the page. Use this property to override the title
 of that button for this step.
 
 Set the learn more button title with a localizable string to override the
 title of the learn more button.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *learnMoreButtonTitle;


/**
 The title of the Skip button.
 
 Many steps are optional and can be skipped. Set this property to override
 the title of the skip button for this step.
 
 Set the skip button title with a localizable string to override the
 title of the skip button. This has no effect if the skip button is not
 visible, such as in a non-optional question step.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *skipButtonTitle;

/**
 The back button item.
 
 The back button item controls the back button shown in the navigation bar while
 this step view controller is current.
 This property allows runtime control of the appearance and target of the
 back button.
 
 If set to `nil`, the button is not displayed. If non-`nil`, the title, target
 and action on the back button item are used. Other properties of `UIBarButtonItem`
 are ignored.
 
 The back button item is updated during view loading and when the step property
 is changed, but are safe to
 override in the `taskViewController:stepViewControllerWillAppear:` delegate callback.
 
 Subclasses can safely modify this any time after base-calling `viewWillAppear:`.
 */
@property (nonatomic, strong, ORK_NULLABLE) UIBarButtonItem *backButtonItem;

/**
 Cancel button item.
 
 The cancel button item controls the cancel button shown in the navigation bar
 while this step view controller is current.
 This property allows runtime control of the appearance and target of the
 cancel button.
 
 If set to nil, the button is not displayed. If non-nil, the title, target
 and action on the back button item are used. Other properties of UIBarButtonItem
 are ignored.
 
 The cancel button item is updated during view loading and when the step property
 is changed, but are safe to
 override in the `taskViewController:stepViewControllerWillAppear:` delegate callback.
 
 Subclasses can safely modify this any time after base-calling `viewWillAppear:`.
 */
@property (nonatomic, strong, ORK_NULLABLE) UIBarButtonItem *cancelButtonItem;

/**
 The current state of the result (read-only).
 
 The task view controller calls this property to obtain the results for this
 step, to collate into the task result.
 
 The current step result and any subsidiary results representing data collected
 so far are available from this property. Significant changes to the result,
 such as when the user enters a new answer, are detectable with the
 `stepViewControllerResultDidChange:` delegate callback.
 
 Subclasses *must* implement this method to return the current results.
 This method may be called multiple times. Subclasses *may* base-call to obtain
 a clean, empty result object appropriate for this step, to which it can 
 attach appropriate child results.
 
 The implementations of this method in ResearchKit currently create a new
 result object on every call, so do not call this method unless it is
 actually necessary.
 */
@property (nonatomic, copy, readonly, ORK_NULLABLE) ORKStepResult *result;

/**
 Convenience accessor for subclasses to call to make a delegate callback to
 determine whether a previous step exists.
 
 See the `stepViewControllerHasPreviousStep:` delegate method.
 
 If the step view controller should always behave as if back-navigation is
 disabled, this is also a suitable override point for subclasses.
 
 @return Returns `YES` if there is a previous step.
 */
- (BOOL)hasPreviousStep;


/**
 Convenience method for subclasses to call to make a delegate callback to
 determine whether a next step exists.
 
 See the `stepViewControllerHasNextStep:` delegate method.
 
 @return Returns `YES` if there is a next step.
 */
- (BOOL)hasNextStep;

/**
 The presenting task view controller (read-only).
 */
@property (nonatomic, weak, readonly, ORK_NULLABLE) ORKTaskViewController *taskViewController;

/**
 Navigates forward to the next step.
 
 Taps of the "next" button pass through this method. This is useful as an override
 point or target action for subclasses.
 */
- (void)goForward;

/**
 Navigates backward to the previous step.
 
 Taps of the "back" button pass through this method. This is useful as an override
 point or target action for subclasses.
 */
- (void)goBackward;


@end

ORK_ASSUME_NONNULL_END


