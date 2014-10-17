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

/**
 *  @brief The RKTaskViewControllerDelegate protocol defines methods that allow you to receive events from RKTaskViewController. 
 *  
 *  The methods of this protocol are all optional.
 */
@protocol RKTaskViewControllerDelegate <NSObject>

@optional
/**
 * @brief Tells the delegate that the task completed.
 */
- (void)taskViewControllerDidComplete: (RKTaskViewController *)taskViewController;

/**
 * @brief Tells the delegate that the task failed.
 */
- (void)taskViewController: (RKTaskViewController *)taskViewController didFailWithError:(NSError*)error;

/**
 * @brief Tells the delegate that the task was cancelled by participant or the developer.
 */
- (void)taskViewControllerDidCancel:(RKTaskViewController *)taskViewController;

/**
 * @brief Asks the delegate should display a more info button at the bottom of a step view.
 *
 * The learn more button would not show through the task if this delegate method is not implemented.
 */
- (BOOL)taskViewController:(RKTaskViewController *)taskViewController shouldShowMoreInfoOnStep:(RKStep *)step;

/**
 * @brief Tells the delegate that the learn more button was tapped.
 */
- (void)taskViewController:(RKTaskViewController *)taskViewController didReceiveLearnMoreEventFromStepViewController:(RKStepViewController *)stepViewController;

/**
 * @brief Ask the delegate to supply a view controller of a given step.
 * 
 * The delegate should provide a step view controller implementation for any custom steps. 
 * If the delegate provides a controller for RKStepViewController's default mapping, return nil.
 */
- (RKStepViewController*)taskViewController:(RKTaskViewController *)taskViewController
                      viewControllerForStep:(RKStep*)step;

/**
 * @brief Asks the delegate should present a step.
 *
 * Provides an opportunity to stop leaving current step.
 */
- (BOOL)taskViewController:(RKTaskViewController *)taskViewController shouldPresentStep:(RKStep*)step;

/**
 * @brief Tells the delegate that a stepViewController is about to be displayed.
 *
 * Provides an opportunity to modify the step view controller before presentation.
 */
- (void)taskViewController:(RKTaskViewController *)taskViewController
willPresentStepViewController:(RKStepViewController *)stepViewController;

/**
 * @brief Tells the delegate that a result object has been produced.
 *
 * The result could then be saved, or serialized and uploaded. For example, the serialized data could be sent via the study's RKUploader.
 */
- (void)taskViewController:(RKTaskViewController *)taskViewController didProduceResult:(RKResult*)result;

@end

@protocol RKTaskDefaultResultProvider;


/**
 * @brief The RKTaskViewController class defines the attributes and behavior of a task view controller.
 * @note RKStepViewController objects are managed by RKTaskViewController, 
 */
@interface RKTaskViewController : UINavigationController


/**
 * @brief Designated initializer
 * @param task    The task to be presented.
 * @param taskInstanceUUID The UUID of this instance of the task
 */
-(instancetype)initWithTask:(id<RKLogicalTask>)task  taskInstanceUUID:(NSUUID*)taskInstanceUUID;

/**
 * @brief The object that acts as view controller's delegate.
 */
@property (nonatomic, weak) id<RKTaskViewControllerDelegate> taskDelegate;

/**
 * @brief Task data source
 * 
 * It is an error to change the task after presenting the RKTaskViewController.
 */
@property (nonatomic, strong) id<RKLogicalTask> task;

/**
 * @brief "Default" result provider
 *
 * This provider can provide "default" results, perhaps based on previous runs of
 * the same task.
 */
@property (nonatomic, strong) id<RKTaskDefaultResultProvider> defaultResultProvider;

/**
 * @brief Task instance UUID
 * 
 * Unique identifier for this run of the task controller. All results produced by this
 * instance will be tagged with this UUID.
 *
 * It is an error to set the taskInstanceUUID after the first time the task VC is presented.
 */
@property (nonatomic, copy) NSUUID *taskInstanceUUID;


/**
 * @brief Survey question results received by RKTaskViewController
 *
 * RKQuestionResult objects in the order the questions were completed.
 * If the user uses the back button to go back through the steps, the
 * results forward of the current position are not included in this array.
 */
@property (nonatomic, copy, readonly) NSArray *surveyResults;


/**
 * @brief Controls whether progress is shown in the navigation bar
 *
 * Defaults to YES. Set to NO to disable showing progress in the navigation bar.
 */
@property (nonatomic, assign) BOOL showsProgressInNavigationBar;

/**
 * @brief Stop current running step.
 */
- (void)suspend;

/**
 * @brief Make current step start running after suspended.
 */
- (void)resume;

@end


