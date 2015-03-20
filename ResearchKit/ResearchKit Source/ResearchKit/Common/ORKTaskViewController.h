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
#import <ResearchKit/ORKTask.h>
#import <ResearchKit/ORKStepViewController.h>
#import <ResearchKit/ORKRecorder.h>

ORK_ASSUME_NONNULL_BEGIN

@class ORKStep;
@class ORKStepViewController;
@class ORKResult;
@class ORKTaskResult;
@class ORKTaskViewController;
@protocol ORKTaskResultSource;


/**
 `ORKTaskViewControllerResult` indicates how the task view controller has finished
 the task.
 */
typedef NS_ENUM(NSInteger, ORKTaskViewControllerResult) {
    
    /// The task was cancelled by participant or the developer, and the participant asked to save current result.
    ORKTaskViewControllerResultSaved,
    
    /// The task was cancelled by participant or the developer, and the participant asked to discard current result.
    ORKTaskViewControllerResultDiscarded,
    
    /// Successful completion of the task, because all steps have been completed.
    ORKTaskViewControllerResultCompleted,
    
    /// An error was detected during the current step.
    ORKTaskViewControllerResultFailed
};

/**
 The delegate of the `ORKTaskViewController`.
 
 The delegate of `ORKTaskViewController` is responsible for processing the results
 of the task, has some control over how the controller behaves, and can provide
 auxiliary content as needed.
 */
@protocol ORKTaskViewControllerDelegate <NSObject>

/**
 Delegate callback which is called when the task has finished.
 
 The task view controller calls this method when an unrecoverable error occurs,
 when the user has cancelled the task (with or without saving), or when the user
 completes the last step in the task.
 
 In most circumstances, the receiver should dismiss the task view controller
 in response to this method, and may also need to collect and process the results
 of the task.

 @param      taskViewController     The `ORKTaskViewController `instance which is returning the result.
 @param      result                 `ORKTaskViewControllerResult` indicating how the user chose to complete the task process.
 @param      error                  `NSError` indicating the failure reason if failure did occur.  This will be `nil` if
 result did not indicate failure.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithResult:(ORKTaskViewControllerResult)result error:(ORK_NULLABLE NSError *)error;

@optional

/**
 Signals that an error has been detected by a recorder.
 
 Recorder errors can occur during active steps, usually due to
 unavailability of sensor data or disk space to record results.
 Developer can use this opportunity to respond to the error, for example, log and ignore it.
 
 @param      taskViewController     The calling `ORKTaskViewController` instance.
 @param      recorder               The recorder that detected the error. `ORKStep` and `ORKRecorderConfiguration` can be found on the recorder instance.
 @param      error                  The error detected.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController recorder:(ORKRecorder *)recorder didFailWithError:(NSError *)error;

/**
 Return a Boolean indicating whether the receiver supports saving the state of the current uncompleted task.
 
 The task view controller calls this method when determining whether to offer
 a "save" option when the user attempts to cancel a task that is in progress.
 
 If this is not being implemented, task view controller will assume save and restore is not supported.
 If returning `YES`, copy the value of the `restorationData` property of the
 `taskViewController` and pass that data to `initWithTask:restorationData:` when it is time
 to create a new task view controller to continue from where the user left off.
 
 @param      taskViewController     The calling `ORKTaskViewController` instance.
 @return Returns `YES`, if save and restore should be supported. `NO`, otherwise.
 */
- (BOOL)taskViewControllerSupportsSaveAndRestore:(ORKTaskViewController *)taskViewController;

/**
 Return a Boolean indicating whether there is "Learn More" content for this step.
 
 The task view controller calls this method when determining whether a 
 "Learn More" button should be displayed for the step.
 
 The standard templates in ResearchKit for all types of steps include a button
 labelled "Learn More" (or some variant of that). In the consent steps this is internal to
 the implementation of the step and step view controller; but in all other steps,
 the task view controller asks its delegate to determine if content is available,
 and to request that it be displayed.
 
 @param      taskViewController     The calling `ORKTaskViewController` instance.
 @param      step                   The step for which the task view controller needs to know if there is "Learn More" content.
 @return Returns `NO` if there is no additional content to display.
 */
- (BOOL)taskViewController:(ORKTaskViewController *)taskViewController hasLearnMoreForStep:(ORKStep *)step;

/**
 Indicates to the receiver that the user has tapped the "Learn More" button on the step.
 
 The task view controller calls this method when the user taps on "Learn More".
 
 The standard templates in ResearchKit for all types of steps include a button
 labelled "Learn More" (or some variant of that). In the consent steps this is internal to
 the implementation of the step and step view controller; but in all other steps,
 the task view controller asks its delegate to determine if content is available.
 
 This method is only called if the delegate has returned YES to
 taskViewController:hasLearnMoreForStep: for the current step, and the user
 subsequently taps on the "Learn More" button.
 
 When this method is called, the app should respond to the "Learn More" action by
 presenting a dialog or other view, possibly modal, containing the extra content.
 
 @param      taskViewController     The calling `ORKTaskViewController` instance.
 @param      stepViewController     The `ORKStepViewController` which reported the "Learn More" event to the task view controller.
 
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController learnMoreForStep:(ORKStepViewController *)stepViewController;

/**
 Return a custom view controller for a given step.
 
 The task view controller calls this method, if implemented, to obtain a
 step view controller for a step.
 
 In most circumstances, for the steps in ResearchKit, the task view controller
 can determine what view controller to instantiate. However, in certain circumstances
 it may be helpful to be able to provide a specific view controller instance. This
 delegate method allows you to provide a custom view controller.
 
 The delegate should provide a step view controller implementation for any custom step.
 
 @param      taskViewController     The calling `ORKTaskViewController` instance.
 @param      step                   The step for which a view controller is requested.
 @return Return a custom view controller, or `nil` to request the default step controller for this step.
 */
- (ORK_NULLABLE ORKStepViewController *)taskViewController:(ORKTaskViewController *)taskViewController viewControllerForStep:(ORKStep *)step;

/**
 Return a Boolean indicating whether the task controller should proceed to a step.
 
 The task view controller calls this method just before creating a step view
 controller for the next or previous step.
 
 Generally, if a step is available, the task view controller will present it when
 the user taps a forward or backward navigation button. In some circumstances this
 may not be appropriate, perhaps depending on the results entered. In those
 circumstances, implement this delegate method and return NO.
 
 If returning NO, it would normally be appropriate to present a dialog or take
 some other UI action to explain why navigation was denied.
 
 @param      taskViewController     The calling `ORKTaskViewController` instance.
 @param      step                   The step for which presentation is requested.
 @return Return `YES`, if navigation should proceed to the specified step; `NO` if navigation
  should not proceed.
 */
- (BOOL)taskViewController:(ORKTaskViewController *)taskViewController shouldPresentStep:(ORKStep *)step;

/**
 Indicates to the receiver that a step view controller is about to be displayed.
 
 The task view controller calls this method just before presenting the step
 view controller.
 
 Provides an opportunity to modify the step view controller before presentation.
 Possible uses include to modify the learnMoreButtonTitle or continueButtonTitle
 properties, or to modify other button state. Another possibility is if a particular
 step view controller requires other specific setup before presentation.
 
 @param      taskViewController     The calling `ORKTaskViewController` instance.
 @param      stepViewController     The `ORKStepViewController` which is about to be displayed.
 
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController stepViewControllerWillAppear:(ORKStepViewController *)stepViewController;

/**
 Indicates to the receiver that the result has substantively changed.
 
 The task view controller calls this method when steps start or finish, or if an answer has
 changed in the current step due to editing or other user interaction.
 
 @param      taskViewController     The calling `ORKTaskViewController` instance.
 @param      result                 The current value of the result.
 
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController didChangeResult:(ORKTaskResult *)result;

@end



/**
 The `ORKTaskViewController` class is the primary entry point for presentation of
 ResearchKit UI. It accepts any object that implements ORKTask, but in most cases
 this will be an `ORKOrderedTask` instance.
 
 The task view controller is intended for modal presentation, so the user can
 cancel participation in the task at any time. When displayed, the task view
 controller normally includes a navigation bar, and conducts right-to-left
 navigation for each step as the user progresses through the task.
 
 The task view controller supports UI state restoration. Simply set the restoration
 identifier, and take appropriate action to restore the task view controller on
 app startup time, and users will be able to restore to wherever they were in
 a long survey.
 
 The task view controller supports saving in the middle of a task. To support
 this in your app, implement `[ORKTaskViewControllerDelegate taskViewControllerSupportsSaveAndRestore:]` in your
 task view controller delegate, and return YES. If the task completes with
 status `ORKTaskViewControllerResultSaved`, copy and store the value of the
 `restorationData` property. When the user wishes to resume the task, create a
 new task view controller using the `initWithTask:restorationData:` initializer,
 and present it.
 
 It is possible to configure the task view controller to "pre-fill" surveys with
 data from another source, for instance, from a previous run of the same task.
 Set a `defaultResultSource` to use this feature.

 When conducting active tasks which may produce file results, always to set the
 `outputDirectory` property. Files generated during active steps are written to
 the `outputDirectory`, and references to these files are returned via `ORKFileResult`
 objects in the hierarchy beneath the `result`.
 */
ORK_CLASS_AVAILABLE
@interface ORKTaskViewController : UIViewController <ORKStepViewControllerDelegate, UIViewControllerRestoration>


/**
 Primary designated initializer.

 @param task             The task to be presented.
 @param taskRunUUID      The UUID of this instance of the task. If nil, a new UUID
    is generated.
 @return Returns a new task view controller.
 */
- (instancetype)initWithTask:(ORK_NULLABLE id<ORKTask>)task taskRunUUID:(ORK_NULLABLE NSUUID *)taskRunUUID  NS_DESIGNATED_INITIALIZER;


/**
 Designated initializer.
 
 Provided to allow instantiating from a Storyboard. Use with storyboards is
 certainly not typical, but if it is part of your workflow then it should work.
 
 @param aDecoder             Coder from which to initialize.
 @return Returns a new task view controller.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 Designated initializer.
 
 @param nibNameOrNil             Name of the nib from which to instantiate.
 @param nibBundleOrNil           Name of the bundle in which to find the nib.
 @return Returns a new task view controller.
 */
- (instancetype)initWithNibName:(ORK_NULLABLE NSString *)nibNameOrNil bundle:(ORK_NULLABLE NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;

/**
 Create a new task view controller from restoration data.
 
 Call this method to restart a task when you have restoration data stored for a
 previous run of this task, in which the user cancelled and selected "save".
 
 This should restore the presentation of the task to where the user left off.
 If the restoration data is not valid, an exception may be thrown.
 
 @param task      The task to be presented.
 @param data      Data obtained from the `restorationData` property of a previous
    task view controller instance.
 @return New task view controller.
 */
- (instancetype)initWithTask:(ORK_NULLABLE id<ORKTask>)task restorationData:(NSData *)data;

/**
 The delegate for the task view controller.
 
 There are many optional methods, but the one thing the delegate must support is
 completion. When the task view controller completes its task, it is the developer's
 responsibility to dismiss it.
 
 See also: `[ORKTaskViewControllerDelegate taskViewController:didFinishWithResult:error:]`
 */
@property (nonatomic, weak, ORK_NULLABLE) id<ORKTaskViewControllerDelegate> delegate;

/**
 The task for this task view controller.
 
 The task functions as the data source for an ORKTaskViewController, providing
 the steps that the user must complete in order to complete the task.
 It is an error to change the task after presenting the ORKTaskViewController.
 */
@property (nonatomic, strong, ORK_NULLABLE) id<ORKTask> task;

/**
 A source that the task view controller can consult to obtain default answers
 for questions in question and form steps.
 
 This provider can provide default answers, perhaps based on previous runs of
 the same task, which will be used to pre-fill Question and Form items.
 For example, an `ORKTaskResult` from a previous run of the task can function as
 an `ORKTaskResultSource`, because `ORKTaskResult` implements the protocol.
 */
@property (nonatomic, strong, ORK_NULLABLE) id<ORKTaskResultSource> defaultResultSource;

/**
 An unique identifier (UUID) for this presentation of the task.
 
 The task run UUID is a unique identifier for this run of the task controller.
 All results produced by this instance will be tagged with this UUID.
 
 The task run UUID is preserved across UI state restoration, or across task
 save and restore.
 
 @note It is an error to set the taskRunUUID after the first time the task VC
 is presented.
 */
@property (nonatomic, copy) NSUUID *taskRunUUID;


/**
 The current state of the task result (read-only).
 
 Use this property to obtain or inspect the results of the task. The results
 are hierarchical; the children of `result` are `ORKStepResult` instances,
 one for each step that was visited during the task.
 
 If the user uses the back button to go back through the steps, the
 results forward of steps "right" of the currently visible step are not included
 in the result.
 */
@property (nonatomic, copy, readonly) ORKTaskResult *result;

/**
 Snapshot data that can be used for future restoration.
 
 When the user taps "Cancel" during a task, and they select the "Save" option,
 the `[ORKTaskViewControllerDelegate taskViewController:didFinishWithResult:error:]`
 method is called with `ORKTaskViewControllerResultSaved`. When that happens,
 use this property to obtain restoration data that can be used to restore
 the task at a later date.
 
 Use `initWithTask:restorationData:` to create a new task view controller that
 restores the current state.
 */
@property (nonatomic, copy, readonly, ORK_NULLABLE) NSData *restorationData;

/**
 File URL to the directory to store generated data files.
 
 Active steps with recorders, and potentially other steps, may wish to save data
 to files during the progress of the task. This directory specifies where such
 data should be written. If no output directory is specified, active steps
 which require writing data to disk, such as those with recorders, will typically
 fail at runtime.
 
 In general use, you should set this after instantiating the task view
 controller, and before presenting it.
 
 Before presenting the view controller, set an outputDirectory to define a
 path where files should be written when an ORKFileResult must be returned for
 a step.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSURL *outputDirectory;

/**
 A Boolean value indicating whether progress should be shown in the navigation bar.
 
 Even if this property is `YES`, no progress will be shown if the progress
 method of `ORKTask` is not implemented.
 
 Defaults to `YES`. Set to `NO` to disable showing progress in the navigation bar.
 */
@property (nonatomic, assign) BOOL showsProgressInNavigationBar;

/**
 The current step view controller.
 
 The task view controller instantiates and presents a series of step view
 controllers. The current step view controller is the one that is currently
 visible on screen.
 
 This may be `nil`, if the task view controller has not yet been presented.
 */
@property (nonatomic, strong, readonly, ORK_NULLABLE) ORKStepViewController *currentStepViewController;

/**
 Forces navigation to the next step.
 
 Call this method to force onward navigation. This may be called by the framework
 if the user takes an action that requires navigation, or if the step is timed
 and the timer completes.
 */
- (void)goForward;

/**
 Forces navigation to the previous step.
 
 Call this method to force backward navigation. This may be called by the framework
 if the user takes an action that requires navigation.
 */
- (void)goBackward;

/**
 A Boolean value indicating whether the navigation bar should be hidden.
 
 The task view controller includes a navigation bar. By default, this navigation
 bar is visible. To disable it, set this property to `NO`.
 */
@property (nonatomic, getter=isNavigationBarHidden) BOOL navigationBarHidden;


/**
 Sets whether the navigation bar should be hidden.
 
 @param hidden     Whether the navigation bar should be hidden.
 @param animated   Whether the show or hide operation should be animated.
 */
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;

/**
 The navigation bar for the task view controller (read-only).
 
 The navigation bar of the task view controller is exposed in order to facilitate
 appearance customization.
 */
@property (nonatomic, readonly) UINavigationBar *navigationBar;

@end

ORK_ASSUME_NONNULL_END

