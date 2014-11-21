//
//  RKStepViewController_Internal.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>


@interface RKTaskViewController(ActiveTaskSupport)

/**
 * @brief Stop current running step.
 */
- (void)suspend;

/**
 * @brief Make current step resume running after suspended.
 */
- (void)resume;

@end

