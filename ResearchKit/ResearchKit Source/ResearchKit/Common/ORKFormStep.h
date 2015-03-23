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


#import <ResearchKit/ORKStep.h>

ORK_ASSUME_NONNULL_BEGIN

@class ORKAnswerFormat;

/**
 `ORKFormStep` is a concrete `ORKStep` subclass for presenting multiple questions
 on a single scrollable page.
 
 To use `ORKFormStep`, instantiate it, fill in its properties, and include it
 in a task. Then create a task view controller for that task, and present it.
 When the task completes, the user's answers will be encoded in the result hierarchy
 on the task view controller.
 
 Each question to be asked in the form is represented by an `ORKFormItem`. The form
 can be broken into sections by including an `ORKFormItem` with just a section title.
 
 The result of an `ORKFormStep` is an `ORKStepResult` with a child `ORKQuestionResult`
 for each form item.
 */

ORK_CLASS_AVAILABLE
@interface ORKFormStep : ORKStep

/**
 Convenience initializer.
 
 @param identifier    The step identifier (see `ORKStep`).
 @param title         The title of the form (see `ORKStep`).
 @param text          The text shown immediately below the title (see `ORKStep`).
 
 @return Returns an instance of `ORKFormStep`.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(ORK_NULLABLE NSString *)title
                              text:(ORK_NULLABLE NSString *)text;

/**
 The array of items in the form.
 
 A form step with no items is considered invalid and an exception will be thrown
 if it is presented.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSArray/* <ORKFormItem> */ *formItems;

@end

/**
 The `ORKFormItem` class represents a single item in an `ORKFormStep`, and typically
 represents a question.
 
 To use an `ORKFormItem`, instantiate it, fill in its properties, and incorporate
 it in an `ORKFormStep`.
 
 An `ORKFormItem` usually corresponds to either a row or a section header in a form, but
 if the answer format is a choice answer format, it may correspond to an entire
 section.
 
 Each `ORKFormItem` generates one `ORKQuestionResult` as a child of its step's
 `ORKStepResult`.
 */
ORK_CLASS_AVAILABLE
@interface ORKFormItem : NSObject <NSSecureCoding, NSCopying>

/**
 Convenience initializer for a form item representing a question to ask in the
 form.
 
 @param identifier    The identifier for this item. Should be unique within the form item.
 @param text          The text shown as a prompt for this particular question.
 @param answerFormat  The answer format for this item.
 
 @return Returns an instance of `ORKFormItem`.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                              text:(ORK_NULLABLE NSString *)text
                      answerFormat:(ORK_NULLABLE ORKAnswerFormat *)answerFormat;

/**
 Convenience initializer for a form item representing a section header in a form.
 
 @param sectionTitle   The title of the section.
 
 @return Returns an instance of `ORKFormItem.`
 */
- (instancetype)initWithSectionTitle:(ORK_NULLABLE NSString *)sectionTitle;

/**
 The identifier for this form item.
 
 The identifier should be unique within the `ORKFormStep` containing this form
 item. The identifier is reproduced on the `ORKQuestionResult` object
 generated for this item.
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 A text string describing this form item.
 
 If this text is sufficiently short, can be presented as a prompt next to the item.
 If it is too long, it may be presented above the item.
 
 This text should be localized to the current language.
 */
@property (nonatomic, copy, readonly, ORK_NULLABLE) NSString *text;

/**
 A placeholder to be shown in a text field or text area when there is no answer yet.
 
 Not applicable for choice based answer formats.
 
 This text should be localized to the current language.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *placeholder;

/**
 The answer format specifies what type of answer is expected, as well as any
 constraints on valid answers.
 
 The answer format should be left `nil` if this form item represents a section
 header, since no answer is needed.
 */
@property (nonatomic, copy, readonly, ORK_NULLABLE) ORKAnswerFormat *answerFormat;

@end

ORK_ASSUME_NONNULL_END
