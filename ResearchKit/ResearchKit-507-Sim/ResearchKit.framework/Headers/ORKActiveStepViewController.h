//
//  ORKActiveStepViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ORKStepViewController.h>
#import <ResearchKit/ORKRecorder.h>

/**
 * @brief Step view controller for an ORKActiveStep.
 */
ORK_CLASS_AVAILABLE
@interface ORKActiveStepViewController : ORKStepViewController<ORKRecorderDelegate>


/**
 * @brief Attach a custom view.
 * @discussion Attach a custom view here, and implement sizeThatFits: or
 * use intrinsicContentSize or constraints to request the size needed for
 * the custom view within the active step's layout.
 *
 * Custom views can be used for visual instructions with animation,
 * or for acquiring interactive input.
 */
@property (nonatomic, strong) UIView *customView;

/**
 * @brief Image view.
 *
 * The image view is created on demand, and is a shortcut to display an image
 * in the custom area of an active task (rather than using a customView).
 */
@property (nonatomic, strong, readonly) UIImageView* imageView;

/**
 * @brief Active step completion state.
 *
 * @discussion If the step is marked finished, Continue is enabled and Skip
 * is hidden. When not finished, Continue is disabled and Skip
 * is visible.
 *
 */
@property (nonatomic, assign, getter=isFinished, readonly) BOOL finished;

/**
 * @brief The step has finished.
 *
 * @discussion Override point for subclasses, called when the step has finished.
 *
 * The default implementation does nothing except for steps with countdown
 * enabled, where it will continue automatically to the next step.
 */
- (void)stepDidFinish;

/**
 * @brief Recorders currently in use by the active step.
 *
 */
@property (nonatomic, strong, readonly) NSArray *recorders;

@property (nonatomic, assign) BOOL suspendIfInactive;

@property (nonatomic, assign, readonly, getter=isStarted) BOOL started;

- (void)start;
- (void)suspend;
- (void)resume;
- (void)finish;

/* Recorder lifecycle methods for use in subclasses */
- (void)recordersDidChange;
- (void)recordersWillStart;
- (void)recordersWillStop;

- (void)prepareStep; // Called just after loading or when step changes

@end
