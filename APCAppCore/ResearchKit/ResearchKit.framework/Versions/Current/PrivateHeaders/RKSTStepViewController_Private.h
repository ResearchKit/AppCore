//
//  RKSTStepViewController_Internal.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/ResearchKit_Private.h>

@interface RKSTStepViewController(ActiveTaskSupport)

/**
 * @brief Stop running step.
 */
- (void)suspend;

/**
 * @brief Make step start running after suspended.
 */
- (void)resume;


@end
