//
//  RKStepViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RKStep;
@class RKResult;
@class RKStepViewController;
@class RKTaskViewController;

typedef NS_ENUM(NSInteger, RKStepViewControllerNavigationDirection) {
    RKStepViewControllerNavigationDirectionForward,
    RKStepViewControllerNavigationDirectionReverse
};


/**
 *  @brief The RKStepViewControllerDelegate protocol defines methods that allow you to receive events from RKStepViewController.
 *
 *  The methods of this protocol are all optional.
 */

@protocol RKStepViewControllerDelegate <NSObject>

@optional
/**
 * @brief Tells the delegate that the stepViewController is about to be displayed.
 */
- (void)stepViewControllerWillBePresented:(RKStepViewController *)viewController;

/**
 * @brief Tells the delegate that the step was completed, would like to navigate forward/backward.
 */
- (void)stepViewControllerDidFinish:(RKStepViewController *)stepViewController navigationDirection:(RKStepViewControllerNavigationDirection)direction;
/**
 * @brief Tells the delegate that the step was failed.
 */
- (void)stepViewControllerDidFail:(RKStepViewController *)stepViewController withError:(NSError*)error;

/**
 * @brief Tells the delegate that the step was canceled.
 */
- (void)stepViewControllerDidCancel:(RKStepViewController *)stepViewController;

@end

@protocol RKResultCollector <NSObject>

/**
 * @brief Tells the collector that the step's result has changed.
 */
-(void)didChangeResult:(RKResult *)result forStep:(RKStep *)step;

/**
 * @brief Tells the collector that the step's result has been produced.
 */
-(void)didProduceResult:(RKResult *)result forStep:(RKStep *)step;

@end

/**
 * @brief The RKStepViewController class defines the attributes and behavior of a step view controller.
 * Managed by RKTaskViewController, do not try to present this view controller alone.
 */

@interface RKStepViewController : UIViewController

/**
 * @brief Designated initializer
 * @param step    The step to be presented.
 */
- (instancetype)initWithStep:(RKStep*)step;

@property (nonatomic, strong, readonly) RKStep* step;

/**
 *  @note By default, RKTaskViewController should be the delegate to ensure its effective management.
 */
@property (nonatomic, weak) id<RKStepViewControllerDelegate> delegate;

/**
 *  @note By default, RKTaskViewController is the resultCollector, all results except survey results will be handed over to RKTaskViewController's delegate via (taskViewController:didProduceResult:) immediately, survey results will be kept until TaskViewController reach completion.
 *  Don't point the resultCollector to other instance unless developer want to capture all survey answer input events, e.g. participant choose option A then choose option B in the same question.
 */
@property (nonatomic, weak) id<RKResultCollector> resultCollector;

/**
 * @brief Control buttons
 */
@property (nonatomic, strong) UIBarButtonItem* nextButton;
@property (nonatomic, strong) UIBarButtonItem* learnMoreButton;
@property (nonatomic, strong) UIBarButtonItem* backButton;
@property (nonatomic, strong) UIBarButtonItem* quitButton;

/**
 * @brief Methods tell if next/prevous step is available
 */
- (BOOL)previousStepAvailable;
- (BOOL)nextStepAvailable;

/**
 * @brief Method access to the presenting task view controller.
 */
- (RKTaskViewController*)taskViewController;

/**
 * @brief Stop running step.
 */
- (void)suspend;

/**
 * @brief Make step start running after suspended.
 */
- (void)resume;

/**
 * @brief Go to next step pragmatically.
 */
- (void)goToNextStep;

/**
 * @brief Go to previous step pragmatically.
 */
- (void)goToPreviousStep;

@end
