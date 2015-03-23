/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKStep.h>
#import <ResearchKit/ORKAnswerFormat.h>

ORK_ASSUME_NONNULL_BEGIN

/**
 The `ORKQuestionStep` class is a concrete subclass of ORKStep which represents
 a step in which a single question is presented to the user.
 
 To use `ORKQuestionStep`, instantiate it, fill in its properties, and include it
 in a task. Then create a task view controller for that task, and present it.
 When the task completes, the user's answer will be encoded in the result hierarchy
 on the task view controller.
 
 When an `ORKQuestionStep` is being presented by a task view controller, it will
 instantiate an `ORKQuestionStepViewController` to present the step. The actual
 visual presentation then depends on the answer format.
 
 When more than one question needs to be presented together, it may be appropriate
 to use `ORKFormStep` instead.
 
 The result of an `ORKQuestionStep` is an `ORKStepResult` with a single child
 `ORKQuestionResult`.
 */
ORK_CLASS_AVAILABLE
@interface ORKQuestionStep : ORKStep

/**
 Convenience factory method.
 
 @param identifier    The step's indentifier. Should be unique within this task.
 @param title         The primary text of the question. This text should be localized to the user's current language.
 @param answerFormat  The format in which the answer is expected.
 */

+ (instancetype)questionStepWithIdentifier:(NSString *)identifier
                                     title:(ORK_NULLABLE NSString *)title
                                    answer:(ORK_NULLABLE ORKAnswerFormat *)answerFormat;

/**
 The answer format describes what type of answer is required.
 
 For example, this might include what type of data to collect, what constraints
 to place on the answer, or what the available choices are (in the case of single
 or multiple select questions).
 */
@property (nonatomic, strong, ORK_NULLABLE) ORKAnswerFormat *answerFormat;

/**
 The question type (read-only).
 
 This is a computed property, derived from the answer format.
 */
@property (nonatomic, readonly) ORKQuestionType questionType;

/**
 The placeholder text to display before an answer has been entered.
 
 For numeric and text-based answers, this placeholder is displayed in the
 text field or text area when an answer has not yet been entered.
 
 This text should be localized to the user's current language.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *placeholder;

@end

ORK_ASSUME_NONNULL_END
