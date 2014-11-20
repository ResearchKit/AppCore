//
//  RKSTQuestionStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import "RKSTStep.h"
#import "RKSTAnswerFormat.h"

/**
 * @brief The RKSTQuestionStep class defines the attributes of a question step.
 *
 * Question step usually defines question and the format or answer.
 */
@interface RKSTQuestionStep : RKSTStep

/**
 * @brief Designated convenience constructor
 * @param identifier    Step's unique indentifier.
 * @param question      Text of the question.
 * @param answerFormat  AnswerFormat object contains details about answer.
 */

+ (instancetype)questionStepWithIdentifier:(NSString *)identifier
                                     title:(NSString *)title
                                    answer:(RKSTAnswerFormat *)answerFormat;

/**
 * @brief AnswerFormat object contains detailed information about an answer.
 * e.g. type, constraints, and choices.
 */
@property (nonatomic, strong) RKSTAnswerFormat *answerFormat;

/**
 * @brief Convenience method to get questionType from answerFormat object.
 */
- (RKSurveyQuestionType)questionType;

@end
