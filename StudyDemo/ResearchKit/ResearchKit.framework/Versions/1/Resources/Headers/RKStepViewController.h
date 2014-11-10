//
//  RKStepViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RKStep;
@class RKResult;
@class RKEditableResult;
@class RKStepViewController;
@class RKTaskViewController;

typedef NS_ENUM(NSInteger, RKStepViewControllerNavigationDirection) {
    RKStepViewControllerNavigationDirectionForward,
    RKStepViewControllerNavigationDirectionReverse
};


@protocol RKStepViewControllerDelegate <NSObject>

@required

/**
 * @brief Indicates the step has completed, and the desired direction of navigation.
 */
- (void)stepViewControllerDidFinish:(RKStepViewController *)stepViewController navigationDirection:(RKStepViewControllerNavigationDirection)direction;

@optional

/**
 * @brief The stepViewController is about to be displayed.
 */
- (void)stepViewControllerWillAppear:(RKStepViewController *)viewController;

/**
 * @brief An error has been detected during the step.
 */
- (void)stepViewControllerDidFail:(RKStepViewController *)stepViewController withError:(NSError *)error;

/**
 * @brief The step was cancelled.
 */
- (void)stepViewControllerDidCancel:(RKStepViewController *)stepViewController;

@end

@protocol RKResultCollector <NSObject>

/**
 * @brief An editable result has been modified during this step.
 */
-(void)didEditResult:(RKEditableResult *)result forStep:(RKStep *)step;

/**
 * @brief A final version of a result has been produced during this step.
 */
-(void)didProduceResult:(RKResult *)result forStep:(RKStep *)step;

@end

/**
 * @brief Base class for view controllers for steps in a task.
 */
@interface RKStepViewController : UIViewController

/**
 * @brief Designated initializer
 * @param step    The step to be presented.
 */
- (instancetype)initWithStep:(RKStep*)step;

/**
 * @brief The step to be presented.
 * 
 * @note Setting the step after the controller has been presented is an error.
 * Modifying the step after the controller has been presented is an error and
 * may have undefined results.
 */
@property (nonatomic, strong) RKStep* step;

@property (nonatomic, weak) id<RKStepViewControllerDelegate> delegate;

@property (nonatomic, weak) id<RKResultCollector> resultCollector;

/**
 * @brief Control buttons
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
@property (nonatomic, strong) UIBarButtonItem *continueButton;
@property (nonatomic, strong) UIBarButtonItem *learnMoreButton;
@property (nonatomic, strong) UIBarButtonItem *skipButton;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;


- (BOOL)previousStepAvailable;
- (BOOL)nextStepAvailable;

/**
 * @brief Method access to the presenting task view controller.
 */
- (RKTaskViewController *)taskViewController;

/**
 * @brief Go to next step.
 */
- (void)goForward;

/**
 * @brief Go to previous step.
 */
- (void)goBackward;

@end

@interface RKStepViewController(ActiveTaskSupport)

/**
 * @brief Stop running step.
 */
- (void)suspend;

/**
 * @brief Make step start running after suspended.
 */
- (void)resume;


@end

