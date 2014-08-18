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



@end
