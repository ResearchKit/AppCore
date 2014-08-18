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
 * The customViewContainer allows custom view to be its subview.
 * @note When RKTouchRecorder is present, its gesture recognizer attaches to customViewContainer.
 */
@property (nonatomic, strong, readonly) UIView* customViewContainer;

/**
 * @brief A image view in customViewContainer.
 */
@property (nonatomic, strong, readonly) UIImageView* imageView;

/**
 * The instructionLabel displays step's intruction text
 */
@property (nonatomic, strong, readonly) UILabel* instructionLabel;

@end
