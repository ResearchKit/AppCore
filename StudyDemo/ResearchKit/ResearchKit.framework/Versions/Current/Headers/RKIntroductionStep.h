//
//  RKIntroductionStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

/**
 * @brief An introduction step is to summarize the study to be presented, motivate a participant to complete the task.
 */
@interface RKIntroductionStep : RKStep

/**
 * @brief The caption content.
 */
@property (nonatomic, copy) NSString* caption;

/**
 * @brief The instruction content with bold font.
 */
@property (nonatomic, copy) NSString* instruction;

/**
 * @brief The explanation content below instruction.
 */
@property (nonatomic, copy) NSString* explanation;

@end
