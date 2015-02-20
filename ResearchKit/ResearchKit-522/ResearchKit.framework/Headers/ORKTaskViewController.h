//
//  ORKTaskViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ResearchKit/ORKTask.h>
#import <ResearchKit/ORKStepViewController.h>

@class ORKStep;
@class ORKStepViewController;
@class ORKResult;
@class ORKTaskResult;
@class ORKTaskViewController;
@protocol ORKTaskResultSource;


/**
 * @enum       ORKTaskViewControllerResult
 * @constant   ORKTaskViewControllerResultSaved         The task was cancelled by participant or the developer, and asked to save current result.
 * @constant   ORKTaskViewControllerResultDiscarded     The task was cancelled by participant or the developer, and asked to discard current result.
 * @constant   ORKTaskViewControllerResultCompleted     Successful completion of the task that has no steps after it.
 * @constant   ORKTaskViewControllerResultFailed        The task failed due to an error.
 */

typedef NS_ENUM(NSInteger, ORKTaskViewControllerResult) {
    ORKTaskViewControllerResultSaved,
    ORKTaskViewControllerResultDiscarded,
    ORKTaskViewControllerResultCompleted,
    ORKTaskViewControllerResultFailed
};

@protocol ORKTaskViewControllerDelegate <NSObject>

/**
 * @brief    Delegate callback which is called upon task finished.
 * @param      taskViewController     The ORKTaskViewController instance which is returning the result.
 * @param      result                 ORKTaskViewControllerResult indicating how the user chose to complete the composition process.
 * @param      error                  NSError indicating the failure reason if failure did occur.  This will be <tt>nil</tt> if
 * result did not indicate failure.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithResult:(ORKTaskViewControllerResult)result error:(NSError *)error;

@optional

/**
 * @brief Whether support saving the states of current uncompleted task and present it to user later.
 * @discussion If this is not being implemented, task viewController will assume save and restore is not supported.
 */
- (BOOL)taskViewControllerSupportsSaveAndRestore:(ORKTaskViewController *)taskViewController;

/**
 * @brief Check whether there is "Learn More" content for this step
 * @return NO if there is no additional content to display.
 */
- (BOOL)taskViewController:(ORKTaskViewController *)taskViewController hasLearnMoreForStep:(ORKStep *)step;

/**
 * @brief The user has tapped the "Learn More" button no the step.
 * @discussion Present a dialog or modal view controller containing the
 * "Learn More" content for this step.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController learnMoreForStep:(ORKStepViewController *)stepViewController;

/**
 * @brief Supply a custom view controller for a given step.
 * @discussion The delegate should provide a step view controller implementation for any custom step.
 * @return A custom view controller, or nil to use the default step controller for this step.
 */
- (ORKStepViewController *)taskViewController:(ORKTaskViewController *)taskViewController viewControllerForStep:(ORKStep *)step;

/**
 * @brief Control whether the task controller proceeds to the next or previous step.
 * @return YES, if navigation can proceed to the specified step.
 */
- (BOOL)taskViewController:(ORKTaskViewController *)taskViewController shouldPresentStep:(ORKStep *)step;

/**
 * @brief Tells the delegate that a stepViewController is about to be displayed.
 * @discussion Provides an opportunity to modify the step view controller before presentation.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController stepViewControllerWillAppear:(ORKStepViewController *)stepViewController;

/**
 * @brief Tells the delegate that task result object has changed.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController didChangeResult:(ORKTaskResult *)result;

@end



/**
 * @brief View controller that can "play" an ORKTask or ORKOrderedTask.
 * @disucssion A task is composed of a sequence of steps that the user must complete.
 * This is intended for modal presentation, so the user can cancel participation in
 * the task at any time.
 */
ORK_CLASS_AVAILABLE
@interface ORKTaskViewController : UIViewController<ORKStepViewControllerDelegate, UIViewControllerRestoration>


/**
 * @brief Create a new task view controller
 * @param task             The task to be presented.
 * @param taskRunUUID The UUID of this instance of the task
 */
-(instancetype)initWithTask:(id<ORKTask>)task taskRunUUID:(NSUUID *)taskRunUUID  NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;

/**
 * @brief Create a new task view controller from restoration data
 * @param task      The task to be presented.
 * @param data      Data obtained from instance API (restorationData) .
 */
- (instancetype)initWithTask:(id<ORKTask>)task restorationData:(NSData *)data;

@property (nonatomic, weak) id<ORKTaskViewControllerDelegate> delegate;

/**
 * @brief Task data source
 * 
 * It is an error to change the task after presenting the ORKTaskViewController.
 */
@property (nonatomic, strong) id<ORKTask> task;

/**
 * @brief "Default" result provider
 * @discussion This provider can provide "default" results, perhaps based on previous runs of
 * the same task, which will be used to pre-fill Question and Form items.
 */
@property (nonatomic, strong) id<ORKTaskResultSource> defaultResultSource;

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
@property (nonatomic, copy, readonly) ORKTaskResult* result;

/**
 * @brief ViewController's snapshot to be used for future restoration.
 * @discussion Use (initWithTask:restorationData:) to create a new ViewController with current state.
 */
@property (nonatomic, copy, readonly) NSData *restorationData;

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
@property (nonatomic, strong, readonly) ORKStepViewController *currentStepViewController;

/**
 * @brief Force navigation to next step.
 */
- (void)goForward;

/**
 * @brief Force navigation to previous step.
 */
- (void)goBackward;

@property (nonatomic, getter=isNavigationBarHidden) BOOL navigationBarHidden;
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;
@property (nonatomic, readonly) UINavigationBar *navigationBar;

@end


