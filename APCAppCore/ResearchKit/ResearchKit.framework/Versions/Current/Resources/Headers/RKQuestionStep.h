//
//  RKQuestionStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/RKDefines.h>
#import <ResearchKit/RKStep.h>
#import <ResearchKit/RKAnswerFormat.h>

/**
 * @brief The RKQuestionStep class defines the attributes of a question step.
 *
 * Question step usually defines question and the format or answer.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKQuestionStep : RKStep

/**
 * @param identifier    Step's unique indentifier.
 * @param question      Text of the question.
 * @param answerFormat  AnswerFormat object contains details about answer.
 */

+ (instancetype)questionStepWithIdentifier:(NSString *)identifier
                                     title:(NSString *)title
                                    answer:(RKAnswerFormat *)answerFormat;

/**
 * @brief The answer format contains detailed information about an answer.
 * For example, type, constraints, and choices.
 */
@property (nonatomic, strong) RKAnswerFormat *answerFormat;

/**
 * @brief The question type (derived from the answer format).
 */
@property (nonatomic, readonly) RKQuestionType questionType;

/**
 * @brief Place holder for its field.
 * @warning Only applicable to RKNumericAnswerFormat and RKTextAnswerFormat.
 */
@property (nonatomic, copy) NSString *placeholder;

@end
