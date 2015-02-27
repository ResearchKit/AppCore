//
//  ORKInstructionStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

/**
 * @brief An Instruction step is to give the participant instructions for the
 * task.
 *
 * This could be used for an introduction, or for instructions in the middle
 * of a task, or for a final message at the completion of a task to suggest
 * next steps.
 */
ORK_CLASS_AVAILABLE
@interface ORKInstructionStep : ORKStep

/**
 * @brief Any detailed explanation for the instruction.
 */
@property (nonatomic, copy) NSString *detailText;

/**
 * @brief An image providing visual context to the instruction.
 */
@property (nonatomic, copy) UIImage *image;

@end
