//
//  ORKQuestionStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKStep.h>
#import <ResearchKit/ORKAnswerFormat.h>

/**
 * @brief The ORKQuestionStep class defines the attributes of a question step.
 *
 * Question step usually defines question and the format or answer.
 */
ORK_CLASS_AVAILABLE
@interface ORKQuestionStep : ORKStep

/**
 * @param identifier    Step's unique indentifier.
 * @param question      Text of the question.
 * @param answerFormat  AnswerFormat object contains details about answer.
 */

+ (instancetype)questionStepWithIdentifier:(NSString *)identifier
                                     title:(NSString *)title
                                    answer:(ORKAnswerFormat *)answerFormat;

/**
 * @brief The answer format contains detailed information about an answer.
 * For example, type, constraints, and choices.
 */
@property (nonatomic, strong) ORKAnswerFormat *answerFormat;

/**
 * @brief The question type (derived from the answer format).
 */
@property (nonatomic, readonly) ORKQuestionType questionType;

/**
 * @brief Place holder for its field.
 * @warning Only applicable to ORKNumericAnswerFormat and ORKTextAnswerFormat.
 */
@property (nonatomic, copy) NSString *placeholder;

@end
