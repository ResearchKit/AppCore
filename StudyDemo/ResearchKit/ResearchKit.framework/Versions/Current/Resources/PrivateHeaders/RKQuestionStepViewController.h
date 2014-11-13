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


@interface RKQuestionStepViewController : RKStepViewController

/**
 * @brief Convenience initializer
 * @param step    The step to be presented.
 * @param result    Previously generated result, to be used for presenting a default value.
 */
- (instancetype)initWithQuestionStep:(RKQuestionStep*)step result:(RKQuestionResult*)result;


@end
