//
//  RKSTTaskViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ResearchKit/RKSTTask.h>
#import <ResearchKit/RKSTStepViewController.h>

@class RKSTStep;
@class RKSTStepViewController;
@class RKSTResult;
@class RKSTTaskResult;
@class RKSTTaskViewController;
@protocol RKSTTaskResultSource;


@protocol RKSTTaskViewControllerDelegate <NSObject>

/**
 * @brief Successful completion of a step that has no steps after it.
 */
- (void)taskViewControllerDidComplete:(RKSTTaskViewController *)taskViewController;

/**
 * @brief Reports an error during the task.
 */
- (void)taskViewController:(RKSTTaskViewController *)taskViewController didFailOnStep:(RKSTStep *)step withError:(NSError *)error;

/**
 * @brief The task was cancelled by participant or the developer.
 */
- (void)taskViewControllerDidCancel:(RKSTTaskViewController *)taskViewController;

@optional
/**
 * @brief Check whether there is "Learn More" content for this step
 * @return NO if there is no additional content to display.
 */
- (BOOL)taskViewController:(RKSTTaskViewController *)taskViewController hasLearnMoreForStep:(RKSTStep *)step;

/**
 * @brief The user has tapped the "Learn More" button no the step.
 * @discussion Present a dialog or modal view controller containing the
 * "Learn More" content for this step.
 */
- (void)taskViewController:(RKSTTaskViewController *)taskViewController learnMoreForStep:(RKSTStepViewController *)stepViewController;

/**
 * @brief Supply a custom view controller for a given step.
 * @discussion The delegate should provide a step view controller implementation for any custom step.
 * @return A custom view controller, or nil to use the default step controller for this step.
 */
- (RKSTStepViewController *)taskViewController:(RKSTTaskViewController *)taskViewController viewControllerForStep:(RKSTStep *)step;

/**
 * @brief Control whether the task controller proceeds to the next or previous step.
 * @return YES, if navigation can proceed to the specified step.
 */
- (BOOL)taskViewController:(RKSTTaskViewController *)taskViewController shouldPresentStep:(RKSTStep *)step;

/**
 * @brief Tells the delegate that a stepViewController is about to be displayed.
 * @discussion Provides an opportunity to modify the step view controller before presentation.
 */
- (void)taskViewController:(RKSTTaskViewController *)taskViewController stepViewControllerWillAppear:(RKSTStepViewController *)stepViewController;

/**
 * @brief Tells the delegate that task result object has changed.
 */
- (void)taskViewController:(RKSTTaskViewController *)taskViewController didChangeResult:(RKSTTaskResult *)result;

@end



/**
 * @brief View controller that can "play" an RKSTTask or RKSTOrderedTask.
 * @disucssion A task is composed of a sequence of steps that the user must complete.
 * This is intended for modal presentation, so the user can cancel participation in
 * the task at any time.
 */
@interface RKSTTaskViewController : UINavigationController<RKSTStepViewControllerDelegate>


/**
 * @brief Designated initializer
 * @param task             The task to be presented.
 * @param taskRunUUID The UUID of this instance of the task
 */
-(instancetype)initWithTask:(id<RKSTTask>)task taskRunUUID:(NSUUID *)taskRunUUID;

@property (nonatomic, weak) id<RKSTTaskViewControllerDelegate> taskDelegate;

/**
 * @brief Task data source
 * 
 * It is an error to change the task after presenting the RKSTTaskViewController.
 */
@property (nonatomic, strong) id<RKSTTask> task;

/**
 * @brief "Default" result provider
 * @discussion This provider can provide "default" results, perhaps based on previous runs of
 * the same task, which will be used to pre-fill Question and Form items.
 */
@property (nonatomic, strong) id<RKSTTaskResultSource> defaultResultSource;

/**
 * @brief Task instance UUID
 * 
 * @discussion Unique identifier for this run of the task controller. All results produced by this
 * instance will be tagged with this UUID.
 *
 * @note It is an error to set the taskRunUUID after the first time the task VC is presented.
 */
@property (nonatomic, copy) NSUUID *taskRunUUID;


/**
 * @brief Current state of result
 *
 * @discussion If the user uses the back button to go back through the steps, the
 * results forward of the current position are not included.
 */
@property (nonatomic, copy, readonly) RKSTTaskResult* result;

/**
 * @brief Path to the directoty to store generated data files.
 * @discussion Before presenting the view controller, use outputDirectory to assign a designated path to store result data file. 
 */
@property (nonatomic, copy) NSURL *outputDirectory;

/**
 * @brief Controls whether progress is shown in the navigation bar.
 *
 * @note Defaults to YES. Set to NO to disable showing progress in the navigation bar.
 */
@property (nonatomic, assign) BOOL showsProgressInNavigationBar;

/**
 * @brief Current presented step view controller.
 */
@property (nonatomic, strong, readonly) RKSTStepViewController *currentStepViewController;

/**
 * @brief Force navigation to next step.
 */
- (void)goForward;

/**
 * @brief Force navigation to previous step.
 */
- (void)goBackward;


@end


