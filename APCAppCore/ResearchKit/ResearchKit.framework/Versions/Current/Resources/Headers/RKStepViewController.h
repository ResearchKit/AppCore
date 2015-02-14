//
//  RKStepViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ResearchKit/RKDefines.h>

@class RKStep;
@class RKResult;
@class RKEditableResult;
@class RKStepViewController;
@class RKTaskViewController;
@class RKStepResult;

typedef NS_ENUM(NSInteger, RKStepViewControllerNavigationDirection) {
    RKStepViewControllerNavigationDirectionForward,
    RKStepViewControllerNavigationDirectionReverse
} RK_ENUM_AVAILABLE_IOS(8_3);


@protocol RKStepViewControllerDelegate <NSObject>

@required

/**
 * @brief Indicates the step has completed, and the desired direction of navigation.
 */
- (void)stepViewController:(RKStepViewController *)stepViewController didFinishWithNavigationDirection:(RKStepViewControllerNavigationDirection)direction;

/**
 * @brief Result changed.
 * Subclasses should override -result to provide the current result.
 */
- (void)stepViewControllerResultDidChange:(RKStepViewController *)stepViewController;

/**
 * @brief An error has been detected during the step.
 */
- (void)stepViewControllerDidFail:(RKStepViewController *)stepViewController withError:(NSError *)error;


@optional

/**
 * @brief The stepViewController is about to be displayed.
 */
- (void)stepViewControllerWillAppear:(RKStepViewController *)viewController;

/**
 * @brief Controls behavior of the Back button.
 * Return YES if the back button should be visible (because there is a previous step in the task)
 * If not implemented, defaults to NO.
 */
- (BOOL)stepViewControllerHasPreviousStep:(RKStepViewController *)stepViewController;

/**
 * @brief Controls behavior of the Continue button.
 * Return YES for Continue, or NO for Done.
 * If not implemented, defaults to NO.
 */
- (BOOL)stepViewControllerHasNextStep:(RKStepViewController *)stepViewController;

@end

/**
 * @brief Base class for view controllers for steps in a task.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKStepViewController : UIViewController

/**
 * @brief Initialize a step view controller
 * @param step    The step to be presented.
 */
- (instancetype)initWithStep:(RKStep *)step NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;

/**
 * @brief The step to be presented.
 * 
 * @note Setting the step after the controller has been presented is an error.
 * Modifying the step after the controller has been presented is an error and
 * may have undefined results.
 */
@property (nonatomic, strong) RKStep *step;

@property (nonatomic, weak) id<RKStepViewControllerDelegate> delegate;


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
 * defined in RKAppearance).
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
@property (nonatomic, copy, readonly) RKStepResult *result;


- (BOOL)hasPreviousStep;
- (BOOL)hasNextStep;

/**
 * @brief Method access to the presenting task view controller.
 */
@property (nonatomic, strong, readonly) RKTaskViewController *taskViewController;

/**
 * @brief Go to next step.
 */
- (void)goForward;

/**
 * @brief Go to previous step.
 */
- (void)goBackward;


@end



