//
//  RKActiveStepViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/RKStepViewController.h>

/**
 * @brief The RKActiveStepViewController class defines the attributes and behavior of a active step view controller.
 */
@interface RKActiveStepViewController : RKStepViewController


/**
 * Add a custom view to the custom view container. The customViewContainer
 * will expand to fit this custom view.
 *
 */
@property (nonatomic, strong) UIView *customView;

/**
 * @brief A image view in customViewContainer.
 *
 * This view is created on demand. If present the image view will be added
 * to the custom view container, which will expand to accommodate it.
 */
@property (nonatomic, strong, readonly) UIImageView* imageView;

/**
 * If the step is marked finished, Continue is enabled and Skip
 * is hidden. When not finished, Continue is disabled and Skip
 * is visible.
 *
 */
@property (nonatomic, assign, getter=isFinished, readonly) BOOL finished;

/**
 * Override point for subclasses, called when the step has finished.
 *
 * The default implementation does nothing except for steps with countdown
 * enabled, where it will continue automatically to the next step.
 */
- (void)stepDidFinish;



@end
