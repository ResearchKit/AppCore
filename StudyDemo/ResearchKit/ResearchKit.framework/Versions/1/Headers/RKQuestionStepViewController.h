//
//  RKQuestionStepViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/RKStepViewController.h>

@class RKQuestionResult;
@class RKQuestionStep;

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
 * @brief Question label
 * @discussion Its own properties are read/write. Use these properties primarily to configure the font or layout of the question.
 */
@property (nonatomic, readonly) UILabel *questionLabel;

/**
 * @brief Prompt label
 * @discussion Its own properties are read/write. Use these properties primarily to configure the font or layout of the question.
 */
@property (nonatomic, readonly) UILabel *promptLabel;

/**
 * @brief Height of the container view of questionLabel and questionLabel
 */
@property (nonatomic) CGFloat labelContainerViewHeight;

/**
 * @brief Customizable footer view at the bottom
 */
@property (nonatomic) UIView* footerView;

@end
