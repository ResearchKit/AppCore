//
//  RKQuestionStepViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/RKStepViewController.h>

@class RKQuestionResult;
@class RKQuestionStep;
@class RKQuestionStepCustomView;

/**
 * @brief The RKQuestionStepViewController class defines the attributes and behavior of a question step view controller.
 */
@interface RKQuestionStepViewController : RKStepViewController

/**
 * @brief Designated initializer
 * @param step    The step to be presented.
 * @param result    Previously generated result, used to recover existing answer.
 */
- (instancetype)initWithQuestionStep:(RKQuestionStep*)step result:(RKQuestionResult*)result;

/**
 * @brief Provide a custom question view
 * If a question requires a custom control for data entry, provide a suitable
 * custom step view. This view should provide sizeThatFits: or autolayout
 * constraints which determine the vertical space required.
 */
@property (nonatomic, strong) RKQuestionStepCustomView *customQuestionView;


/**
 * @brief Customizable footer view at the bottom
 */
@property (nonatomic, strong) UIView* footerView;

@end
