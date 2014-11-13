//
//  RKQuestionStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import "RKStep.h"
#import "RKAnswerFormat.h"

/**
 * @brief The RKQuestionStep class defines the attributes of a question step.
 *
 * Question step usually defines question and the format or answer.
 */
@interface RKQuestionStep : RKStep

/**
 * @brief Designated convenience constructor
 * @param identifier    Step's unique indentifier.
 * @param question      Text of the question.
 * @param answerFormat  AnswerFormat object contains details about answer.
 */

+ (instancetype)questionStepWithIdentifier:(NSString *)identifier
                                     title:(NSString *)title
                                    answer:(RKAnswerFormat *)answerFormat;
/**
 * @brief Allow user to skip current step with no answer.
 * @note Default value is YES.
 */
@property (nonatomic,getter=isOptional) BOOL optional;

/**
 * @brief Primary text of the question.
 */
@property (nonatomic, copy) NSString *title;

/**
 * @brief Additional instructional text for the question.
 */
@property (nonatomic, copy) NSString *text;

/**
 * @brief AnswerFormat object contains detailed information about an answer.
 * e.g. type, constraints, and choices.
 */
@property (nonatomic, strong) RKAnswerFormat *answerFormat;

/**
 * @brief Convenience method to get questionType from answerFormat object.
 */
- (RKSurveyQuestionType)questionType;

@end
