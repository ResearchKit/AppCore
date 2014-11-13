//
//  RKFormStepViewController.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ResearchKit/ResearchKit.h>

/**
 * @brief The RKFormStepViewController class defines the behavior of a form step view controller.
 */
@interface RKFormStepViewController : RKStepViewController

/**
 * @brief Designated initializer
 * @param step    The step to be presented.
 * @param result    Previously generated result, used to recover existing answer.
 */
- (instancetype)initWithFormStep:(RKFormStep *)step result:(RKFormResult *)result;

@end
