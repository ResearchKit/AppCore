//
//  RKSTStepViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ResearchKit/RKSTDefines.h>

@class RKSTStep;
@class RKSTResult;
@class RKSTEditableResult;
@class RKSTStepViewController;
@class RKSTTaskViewController;
@class RKSTStepResult;

typedef NS_ENUM(NSInteger, RKSTStepViewControllerNavigationDirection) {
    RKSTStepViewControllerNavigationDirectionForward,
    RKSTStepViewControllerNavigationDirectionReverse
} RK_ENUM_AVAILABLE_IOS(8_3);


@protocol RKSTStepViewControllerDelegate <NSObject>

@required

/**
 * @brief Indicates the step has completed, and the desired direction of navigation.
 */
- (void)stepViewController:(RKSTStepViewController *)stepViewController didFinishWithNavigationDirection:(RKSTStepViewControllerNavigationDirection)direction;

/**
 * @brief Result changed.
 * Subclasses should override -result to provide the current result.
 */
- (void)stepViewControllerResultDidChange:(RKSTStepViewController *)stepViewController;

/**
 * @brief An error has been detected during the step.
 */
- (void)stepViewControllerDidFail:(RKSTStepViewController *)stepViewController withError:(NSError *)error;


@optional

/**
 * @brief The stepViewController is about to be displayed.
 */
- (void)stepViewControllerWillAppear:(RKSTStepViewController *)viewController;

/**
 * @brief Controls behavior of the Back button.
 * Return YES if the back button should be visible (because there is a previous step in the task)
 * If not implemented, defaults to NO.
 */
- (BOOL)stepViewControllerHasPreviousStep:(RKSTStepViewController *)stepViewController;

/**
 * @brief Controls behavior of the Continue button.
 * Return YES for Continue, or NO for Done.
 * If not implemented, defaults to NO.
 */
- (BOOL)stepViewControllerHasNextStep:(RKSTStepViewController *)stepViewController;

@end

/**
 * @brief Base class for view controllers for steps in a task.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTStepViewController : UIViewController

/**
 * @brief Initialize a step view controller
 * @param step    The step to be presented.
 */
- (instancetype)initWithStep:(RKSTStep *)step NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;

/**
 * @brief The step to be presented.
 * 
 * @note Setting the step after the controller has been presented is an error.
 * Modifying the step after the controller has been presented is an error and
 * may have undefined results.
 */
@property (nonatomic, strong) RKSTStep *step;

@property (nonatomic, weak) id<RKSTStepViewControllerDelegate> delegate;


/**
 * @brief Modify the title of continue button, skip button, or learn more button
 */
@property (nonatomic, copy) NSString *continueButtonTitle;
@property (nonatomic, copy) NSString *learnMoreButtonTitle;
@property (nonatomic, copy) NSString *skipButtonTitle;

/**
 * @brief Back button and Cancel button
 * If the item is nil, the corresponding button will not be displayed.
 * If the item is present, the title, target, and action will be used. Other
 * properties are ignored (style is obtained globally, from the appearance of classes
 * defined in RKSTAppearance).
 *
 * These are updated during view loading or when the step is set, but are safe to
 * override in the taskViewController:stepViewControllerWillAppear: delegate callback.
 *
 * Subclasses can safely modify these after calling [super viewWillAppear:]
 */
@property (nonatomic, strong) UIBarButtonItem *backButtonItem;
@property (nonatomic, strong) UIBarButtonItem *cancelButtonItem;

/**
 * @brief Current state of result
 */
@property (nonatomic, copy, readonly) RKSTStepResult *result;


- (BOOL)hasPreviousStep;
- (BOOL)hasNextStep;

/**
 * @brief Method access to the presenting task view controller.
 */
@property (nonatomic, strong, readonly) RKSTTaskViewController *taskViewController;

/**
 * @brief Go to next step.
 */
- (void)goForward;

/**
 * @brief Go to previous step.
 */
- (void)goBackward;


@end



