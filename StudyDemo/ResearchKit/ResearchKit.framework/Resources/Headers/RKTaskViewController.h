//
//  RKTaskViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ResearchKit/RKTask.h>

@class RKStep;
@class RKStepViewController;
@class RKResult;
@class RKTaskViewController;


@protocol RKTaskViewControllerDelegate <NSObject>

@optional
/**
 * @brief Successful completion of a step that has no steps after it.
 */
- (void)taskViewControllerDidComplete:(RKTaskViewController *)taskViewController;

/**
 * @brief Reports an error during the task.
 */
- (void)taskViewController:(RKTaskViewController *)taskViewController didFailWithError:(NSError *)error;

/**
 * @brief The task was cancelled by participant or the developer.
 */
- (void)taskViewControllerDidCancel:(RKTaskViewController *)taskViewController;

/**
 * @brief Check whether there is "Learn More" content for this step
 * @return NO if there is no additional content to display.
 */
- (BOOL)taskViewController:(RKTaskViewController *)taskViewController hasLearnMoreForStep:(RKStep *)step;

/**
 * @brief The user has tapped the "Learn More" button no the step.
 * @discussion Present a dialog or modal view controller containing the
 * "Learn More" content for this step.
 */
- (void)taskViewController:(RKTaskViewController *)taskViewController learnMoreForStep:(RKStepViewController *)stepViewController;

/**
 * @brief Supply a custom view controller for a given step.
 * @discussion The delegate should provide a step view controller implementation for any custom step.
 * @return A custom view controller, or nil to use the default step controller for this step.
 */
- (RKStepViewController*)taskViewController:(RKTaskViewController *)taskViewController viewControllerForStep:(RKStep *)step;

/**
 * @brief Control whether the task controller proceeds to the next or previous step.
 * @return YES, if navigation can proceed to the specified step.
 */
- (BOOL)taskViewController:(RKTaskViewController *)taskViewController shouldPresentStep:(RKStep *)step;

/**
 * @brief Tells the delegate that a stepViewController is about to be displayed.
 * @discussion Provides an opportunity to modify the step view controller before presentation.
 */
- (void)taskViewController:(RKTaskViewController *)taskViewController stepViewControllerWillAppear:(RKStepViewController *)stepViewController;

/**
 * @brief Tells the delegate that a result object has been produced.
 * @discussion Results from data recording during "active" steps are "produced"
 * immediately when the step completes. Editable results (from survey questions)
 * are composed into a single RKSurveyResult which is "produced" at the end of
 * the task.
 */
- (void)taskViewController:(RKTaskViewController *)taskViewController didProduceResult:(RKResult *)result;

@end

@protocol RKSurveyResultProvider;


/**
 * @brief View controller that can "play" an RKTask or RKLogicalTask.
 * @disucssion A task is composed of a sequence of steps that the user must complete.
 * This is intended for modal presentation, so the user can cancel participation in
 * the task at any time.
 */
@interface RKTaskViewController : UINavigationController


/**
 * @brief Designated initializer
 * @param task             The task to be presented.
 * @param taskInstanceUUID The UUID of this instance of the task
 */
-(instancetype)initWithTask:(id<RKLogicalTask>)task taskInstanceUUID:(NSUUID *)taskInstanceUUID;

@property (nonatomic, weak) id<RKTaskViewControllerDelegate> taskDelegate;

/**
 * @brief Task data source
 * 
 * It is an error to change the task after presenting the RKTaskViewController.
 */
@property (nonatomic, strong) id<RKLogicalTask> task;

/**
 * @brief "Default" result provider
 * @discussion This provider can provide "default" results, perhaps based on previous runs of
 * the same task, which will be used to pre-fill Question and Form items.
 */
@property (nonatomic, strong) id<RKSurveyResultProvider> defaultResultProvider;

/**
 * @brief Task instance UUID
 * 
 * @discussion Unique identifier for this run of the task controller. All results produced by this
 * instance will be tagged with this UUID.
 *
 * @note It is an error to set the taskInstanceUUID after the first time the task VC is presented.
 */
@property (nonatomic, copy) NSUUID *taskInstanceUUID;


/**
 * @brief Current state of survey results
 *
 * @discussion If the user uses the back button to go back through the steps, the
 * results forward of the current position are not included.
 */
- (id<RKSurveyResultProvider>)currentSurveyResults;


/**
 * @brief Controls whether progress is shown in the navigation bar.
 *
 * @note Defaults to YES. Set to NO to disable showing progress in the navigation bar.
 */
@property (nonatomic, assign) BOOL showsProgressInNavigationBar;

/**
 * @brief Current presented step view controller.
 */
@property (nonatomic, strong, readonly) RKStepViewController *currentStepViewController;

/**
 * @brief Force navigation to next step.
 */
- (void)goForward;

/**
 * @brief Force navigation to previous step.
 */
- (void)goBackward;


@end

@interface RKTaskViewController(ActiveTaskSupport)

/**
 * @brief Stop current running step.
 */
- (void)suspend;

/**
 * @brief Make current step resume running after suspended.
 */
- (void)resume;

@end


