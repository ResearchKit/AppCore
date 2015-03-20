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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ResearchKit/ORKDefines.h>


ORK_ASSUME_NONNULL_BEGIN

/// An enumeration of the different types of question supported by ResearchKit.
typedef NS_ENUM(NSInteger, ORKQuestionType) {
    /// No question.
    ORKQuestionTypeNone,
    
    /// The scale question type asks participants to place a mark at an appropriate position on a continuous or discrete line.
    ORKQuestionTypeScale,
    
    /// The Single choice questions are those where the participant can only pick a single predefined option.
    ORKQuestionTypeSingleChoice,
    
    /// The Multiple choice questions are those where the participant can pick one or more predefined options.
    ORKQuestionTypeMultipleChoice,
    
    /// The Decimal question type asks the participant to enter a decimal number.
    ORKQuestionTypeDecimal,
    
    /// The Integer question type asks the participant to enter an integer number.
    ORKQuestionTypeInteger,
    
    /// The Boolean type question collects a response of "Yes" or "No" from the participant.
    ORKQuestionTypeBoolean,
    
    /// The Text question type collects multiple lines of text input.
    ORKQuestionTypeText,
    
    /// The Time of Day question type can be used to ask for a certain time in a day, which can be chosen from a picker.
    ORKQuestionTypeTimeOfDay,
    
    /// The DateAndTime question type asks for a time or a combination of date and time, which can be chosen from a picker.
    ORKQuestionTypeDateAndTime,
    
    /// The Date question type can be used to ask for a certain date, can be chosen from a picker.
    ORKQuestionTypeDate,
    
    /// The TimeInterval question type can be used to ask for a certain time span, can be chosen from a picker.
    ORKQuestionTypeTimeInterval
} ORK_ENUM_AVAILABLE;

/// The types of choice answer available.
typedef NS_ENUM(NSInteger, ORKChoiceAnswerStyle) {
    /// Single choice questions are those where the participant can only pick a single predefined answer option.
    ORKChoiceAnswerStyleSingleChoice,
    
    /// Multiple choice questions are those where the participant can pick one or more predefined answer options.
    ORKChoiceAnswerStyleMultipleChoice
} ORK_ENUM_AVAILABLE;



@class ORKScaleAnswerFormat;
@class ORKContinuousScaleAnswerFormat;
@class ORKValuePickerAnswerFormat;
@class ORKImageChoiceAnswerFormat;
@class ORKTextChoiceAnswerFormat;
@class ORKBooleanAnswerFormat;
@class ORKNumericAnswerFormat;
@class ORKTimeOfDayAnswerFormat;
@class ORKDateAnswerFormat;
@class ORKTextAnswerFormat;
@class ORKTimeIntervalAnswerFormat;

/**
 The `ORKAnswerFormat` class is the abstract base class for classes that describe the
 format in which a survey question or form item should be answered. ResearchKit uses
 `ORKQuestionStep` and `ORKFormItem` to represent questions to ask the user. Each
 of these must have an answer format.
 
 To use an answer format, instantiate the appropriate answer format subclass and
 attach it to a question step or form item. Then incorporate the resulting step
 in a task, and present the task with a task view controller.
 
 Answer formats are validated whenever their owning steps are validated.
 
 Some answer formats may be built in terms of other answer formats. In this
 case, they can implement the internal method `_impliedAnswerFormat`, to return
 the answer format that is implied. For example, a boolean answer format
 is presented in the same way as a single-select answer format with the
 choices "Yes" and "No" mapping respectively to `@(YES)` and `@(NO)`.
 */
ORK_CLASS_AVAILABLE
@interface ORKAnswerFormat : NSObject <NSSecureCoding, NSCopying>

/// @name Properties

/**
 The type of question (read-only).
 
 This enumerated value is used to help Objective-C code needing to switch on
 a rough approximation of the type of question being asked.
 
 Answer format subclasses override the getter to return the appropriate question
 type.
 */
@property (readonly) ORKQuestionType questionType;


/// @name Factory methods

+ (ORKScaleAnswerFormat *)scaleAnswerFormatWithMaxValue:(NSInteger)scaleMax
                                               minValue:(NSInteger)scaleMin
                                                   step:(NSInteger)step
                                           defaultValue:(NSInteger)defaultValue;

+ (ORKContinuousScaleAnswerFormat *)continuousScaleAnswerFormatWithMaxValue:(double)scaleMax
                                                                   minValue:(double)scaleMin
                                                               defaultValue:(double)defaultValue
                                                      maximumFractionDigits:(NSInteger)maximumFractionDigits;

+ (ORKBooleanAnswerFormat *)booleanAnswerFormat;

+ (ORKValuePickerAnswerFormat *)valuePickerAnswerFormatWithTextChoices:(NSArray *)textChoices;

+ (ORKImageChoiceAnswerFormat *)choiceAnswerFormatWithImageChoices:(NSArray *)imageChoices;

+ (ORKTextChoiceAnswerFormat *)choiceAnswerFormatWithStyle:(ORKChoiceAnswerStyle)style
                                               textChoices:(NSArray *)textChoices;

+ (ORKNumericAnswerFormat *)decimalAnswerFormatWithUnit:(ORK_NULLABLE NSString *)unit;
+ (ORKNumericAnswerFormat *)integerAnswerFormatWithUnit:(ORK_NULLABLE NSString *)unit;

+ (ORKTimeOfDayAnswerFormat *)timeOfDayAnswerFormat;
+ (ORKTimeOfDayAnswerFormat *)timeOfDayAnswerFormatWithDefaultComponents:(ORK_NULLABLE NSDateComponents *)defaultComponents;

+ (ORKDateAnswerFormat *)dateTimeAnswerFormat;
+ (ORKDateAnswerFormat *)dateTimeAnswerFormatWithDefaultDate:(ORK_NULLABLE NSDate *)defaultDate
                                                 minimumDate:(ORK_NULLABLE NSDate *)minimumDate
                                                 maximumDate:(ORK_NULLABLE NSDate *)maximumDate
                                                    calendar:(ORK_NULLABLE NSCalendar *)calendar;

+ (ORKDateAnswerFormat *)dateAnswerFormat;
+ (ORKDateAnswerFormat *)dateAnswerFormatWithDefaultDate:(ORK_NULLABLE NSDate *)defaultDate
                                             minimumDate:(ORK_NULLABLE NSDate *)minimumDate
                                             maximumDate:(ORK_NULLABLE NSDate *)maximumDate
                                                calendar:(ORK_NULLABLE NSCalendar *)calendar;

+ (ORKTextAnswerFormat *)textAnswerFormat;
+ (ORKTextAnswerFormat *)textAnswerFormatWithMaximumLength:(NSInteger)maximumLength;

+ (ORKTimeIntervalAnswerFormat *)timeIntervalAnswerFormat;
+ (ORKTimeIntervalAnswerFormat *)timeIntervalAnswerFormatWithDefaultInterval:(NSTimeInterval)defaultInterval step:(NSInteger)step;

/// @name Validation


/**
 Should validate the parameters of the answer format to verify they are
 displayable.
 
 This is typically called by owning objects' validation methods, which are
 themselves called when a step view controller containing this answer format is
 about to be displayed.
 */
- (void)validateParameters;

@end



/**
 The `ORKScaleAnswerFormat `class represents an answer format with a slider that
 has several markers spaced along a line.
 
 This answer format produces an `ORKScaleQuestionResult` with an integer valued
 answer that lies between the minimumValue and maximumValue, and lies on one
 of those quantized step values.
 */
ORK_CLASS_AVAILABLE
@interface ORKScaleAnswerFormat : ORKAnswerFormat

/**
 Designated initializer.
 
 @param maximumValue   The upper bound of the scale
 @param minimumValue   The lower bound of the scale.
 @param step  The size of each discrete offset on the scale.
 @param defaultValue   The default value. An out of range default means the slider starts with no value set.
 @return Returns a new instance.
 */
- (instancetype)initWithMaximumValue:(NSInteger)maximumValue
                        minimumValue:(NSInteger)minimumValue
                                step:(NSInteger)step
                        defaultValue:(NSInteger)defaultValue NS_DESIGNATED_INITIALIZER;

/**
 The upper bound of the scale (read-only).
 */
@property (readonly) NSInteger maximum;

/**
 The lower bound of the scale (read-only).
 */
@property (readonly) NSInteger minimum;


/**
 The size of each discrete offset on the scale (read-only).
 
 The step should be greater than zero.
 The difference between `maximumValue` and `minimumValue` should be divisible
 by the step value.
 */
@property (readonly) NSInteger step;

/**
 Default value for the slider (read-only).
 
 If `defaultValue < minimum` or `defaultValue > maximum`, the slider will have no default.
 Otherwise, the value will be rounded to the nearest valid step.
 */
@property (readonly) NSInteger defaultValue;

@end

/**
 The `ORKContinuousScaleAnswerFormat` class represents an answer format involving
 selecting a value on a continuous scale.
 
 This answer format produces an `ORKScaleQuestionResult` with a real-valued answer.
 */
ORK_CLASS_AVAILABLE
@interface ORKContinuousScaleAnswerFormat : ORKAnswerFormat


- (instancetype)initWithMaximumValue:(double)maximumValue
                        minimumValue:(double)minimumValue
                        defaultValue:(double)defaultValue
               maximumFractionDigits:(NSInteger)maximumFractionDigits NS_DESIGNATED_INITIALIZER;

/**
 The upper bound of the scale (read-only).
 */
@property (readonly) double maximum;

/**
 The lower bound of the scale (read-only).
 */
@property (readonly) double minimum;

/**
 The default value for the slider (read-only).
 
 If `defaultValue < minimum` or `defaultValue > maximum`, the slider will have no default.
 */
@property (readonly) double defaultValue;

/**
 The maximum number of fractional digits to display (read-only).
 */
@property (readonly) NSInteger maximumFractionDigits;

@end

/**
 `ORKValuePickerAnswerFormat` is an answer format for displaying a value picker with a fixed
 set of text choices, from which one answer should be selected.
 
 When the number of choices is relatively large, and/or the text of the choices
 is short, this may be preferable to `ORKTextChoiceAnswerFormat`. In cases
 where there is more text on each choice, or there are only a very small number
 of choices, `ORKTextChoiceAnswerFormat` would be preferred instead.
 
 This answer format reports itself as being of single choice question type.
 Produces an `ORKChoiceQuestionResult`.
 */
ORK_CLASS_AVAILABLE
@interface ORKValuePickerAnswerFormat : ORKAnswerFormat

/**
 Create a value picker answer format to select from a set of text choices.
 
 The `detailText` property of the choices is ignored. The text for each choice needs to be
 short enough to fit in a `UIPickerView`.
 
 @param textChoices         Array of `ORKTextChoice`.
 */
- (instancetype)initWithTextChoices:(NSArray *)textChoices NS_DESIGNATED_INITIALIZER;

/**
 An array of `ORKTextChoice` representing the options to be offered in the picker (read-only).
 
 The `detailText` of the choices is ignored. The text for each choice needs to be
 short enough to fit in a `UIPickerView`.
 */
@property (readonly, copy) NSArray *textChoices;

@end

/**
 `ORKImageChoiceAnswerFormat` is an answer format representing a single choice
 question with a fixed set of image choices.
 
 For example, this might represent a range of moods ranging from very sad
 to very happy.
 
 This produces an `ORKChoiceQuestionResult`, just as for a single-select answer
 format.
 */
ORK_CLASS_AVAILABLE
@interface ORKImageChoiceAnswerFormat : ORKAnswerFormat

/**
 Convenience initializer.
 
 @param imageChoices             Array of `ORKImageChoice`
 */
- (instancetype)initWithImageChoices:(NSArray *)imageChoices NS_DESIGNATED_INITIALIZER;


/**
 An array of `ORKImageChoice` representing the choices available (read-only).
 
 The text of the currently selected choice is displayed on screen. The text for
 each choice is spoken by VoiceOver when an image is highlighted.
 */
@property (readonly, copy) NSArray *imageChoices;

@end

/**
 The `ORKTextChoiceAnswerFormat` answer format represents a multiple or single
 choice question with a fixed set of text choices.
 
 These choices are presented as a table view, with one row for each answer.
 The text for each answer is given more prominence than the `detailText`, but
 both are shown.
 
 This produces an `ORKChoiceQuestionResult`.
 */
ORK_CLASS_AVAILABLE
@interface ORKTextChoiceAnswerFormat : ORKAnswerFormat

/**
 Creates a choice answer format to select from a set of text choices.
 
 @param style               Whether single or multiple-choice.
 @param textChoices         Array of ORKTextChoice.
 */
- (instancetype)initWithStyle:(ORKChoiceAnswerStyle)style
                  textChoices:(NSArray *)textChoices NS_DESIGNATED_INITIALIZER;

/**
 An enumerated value indicating whether the question is single or multiple choice.
 */
@property (readonly) ORKChoiceAnswerStyle style;

/**
 An array of `ORKTextChoice`, representing the options that are available
 to choose from.
 
 These choices are presented as a table view, with one row for each answer.
 The text for each answer is given more prominence than the `detailText`, but
 both are shown.
 */
@property (readonly, copy) NSArray *textChoices;

@end

/**
 The `ORKBooleanAnswerFormat` class behaves like an `ORKTextChoiceAnswerFormat`,
 but is pre-configured to have just two answers: "Yes" and "No".
 
 This produces an `ORKBooleanQuestionResult`.
 */
ORK_CLASS_AVAILABLE
@interface ORKBooleanAnswerFormat : ORKAnswerFormat

@end

/**
 The `ORKTextChoice` class defines the text for an option in answer formats such
 as `ORKTextChoiceAnswerFormat` and `ORKValuePickerAnswerFormat`.
 
 The value that will be recorded in results when this item is chosen
 is specified in the `value` property.
 */
ORK_CLASS_AVAILABLE
@interface ORKTextChoice : NSObject <NSSecureCoding, NSCopying, NSObject>

/**
 Convenience factory method.
 
 @param text        Primary text.
 @param detailText  Detail text to show below the primary text.
 @param value       The value to record in a result object when this item is selected.
 
 @return Returns a new instance.
 */
+ (instancetype)choiceWithText:(NSString *)text detailText:(ORK_NULLABLE NSString *)detailText value:(id<NSCopying, NSCoding, NSObject>)value;

/**
 Convenience factory method.
 
 @param text        Primary text.
 @param value       The value to record in a result object when this item is selected.
 
 @return Returns a new instance.
 */
+ (instancetype)choiceWithText:(NSString *)text value:(id<NSCopying, NSCoding, NSObject>)value;

/**
 Designated initializer.
 
 @param text        Primary text.
 @param detailText  Detail text to show below the primary text.
 @param value       The value to record in a result object when this item is selected.
 
 @return Returns a new instance.
 */
- (instancetype)initWithText:(NSString *)text
                  detailText:(ORK_NULLABLE NSString *)detailText
                       value:(id<NSCopying, NSCoding, NSObject>)value NS_DESIGNATED_INITIALIZER;

/**
 Brief text describing the option.
 
 Ideally this should not stretch to more than one line.
 
 This text should be localized to the current language.
 */
@property (readonly, copy) NSString *text;

/**
 The value to be returned if this option is selected.
 
 Expected to be a scalar property list type, such as `NSNumber` or `NSString`.
 If no value is provided, the index of the option in the options list on the
 answer format is used.
 */
@property (readonly, copy) id<NSCopying, NSCoding, NSObject> value;

/**
 Extended text describing the option.
 
 This text may stretch to multiple lines. This is ignored by `ORKValuePickerAnswerFormat`.
 
 This text should be localized to the current language.
 */
@property (readonly, copy, ORK_NULLABLE) NSString *detailText;

@end

/**
 The ORKImageChoice class defines an option which can
 be included in ORKImageChoiceAnswerFormat.
 
 The options are normally displayed in a horizontal row, so when five options
 will be displayed in an ORKImageChoiceAnswerFormat, image sizes around 45 to
 60 points are appropriate for applications that will be deployed across the
 full range of iPhones.
 
 The text for image choice options should be kept reasonably short, although
 wrapping to more than one line is supported, since only the text for the
 currently selected image choice is actually displayed.
 */
ORK_CLASS_AVAILABLE
@interface ORKImageChoice : NSObject <NSSecureCoding, NSCopying>

/**
 Convenience factory method.
 
 @param normal      Image to display in the un-selected ("normal") state.
 @param selected    Image to display in selected state.
 @param text        Text to display when the image is selected.
 @param value       The value to record in a result object when this item is selected.
 
 @return Returns a new instance.
 */
+ (instancetype)choiceWithNormalImage:(ORK_NULLABLE UIImage *)normal
                        selectedImage:(ORK_NULLABLE UIImage *)selected
                                 text:(ORK_NULLABLE NSString *)text
                                value:(id<NSCopying, NSCoding, NSObject>)value;

/**
 Designated initializer.
 
 @param normal      Image to display in the un-selected ("normal") state.
 @param selected    Image to display in selected state.
 @param text        Text to display when the image is selected.
 @param value       The value to record in a result object when this item is selected.
 
 @return Returns a new instance.
 */
- (instancetype)initWithNormalImage:(ORK_NULLABLE UIImage *)normal
                      selectedImage:(ORK_NULLABLE UIImage *)selected
                               text:(ORK_NULLABLE NSString *)text
                              value:(id<NSCopying, NSCoding, NSObject>)value NS_DESIGNATED_INITIALIZER;

/**
 The image to display when this option is not selected(read-only).
 
 The size of this image will depend on the number of choices being used. As a
 rule of thumb, we recommend starting with 44 by 44 points, and adjusting as
 needed.
 */
@property (readonly, strong) UIImage *normalStateImage;

/**
 The image to display when this option is selected(read-only).
 
 For best results, this image should be the same size as the `normalStateImage`.
 If this image is not specified, the default `UIButton` behavior is used to
 indicate the selection state.
 */
@property (readonly, strong, ORK_NULLABLE) UIImage *selectedStateImage;

/**
 The text to display when this item is selected(read-only).
 
 Note that this text may be spoken by VoiceOver even if the item is not selected,
 as it is made available to the Accessibility framework.
 
 This text should be localized to the current language.
 */
@property (readonly, copy, ORK_NULLABLE) NSString *text;

/**
 The value to be returned if this option is selected (read-only).
 
 This is expected to be a scalar property list type, e.g. NSNumber or NSString.
 If no value is provided, the index of the option in the ORKImageChoiceAnswerFormat
 options list will be used.
 */
@property (readonly, copy) id<NSCopying, NSCoding, NSObject> value;


@end

/// Style of answer for `ORKNumericAnswerFormat`. Controls the keyboard that is presented during numeric entry.
typedef NS_ENUM(NSInteger, ORKNumericAnswerStyle) {
    /// Decimal question type asks the participant to enter a decimal number.
    ORKNumericAnswerStyleDecimal,
    
    /// Integer question type asks the participant to enter a integer number.
    ORKNumericAnswerStyleInteger
    
} ORK_ENUM_AVAILABLE;


/**
 The `ORKNumericAnswerFormat` class defines the attributes for a numeric
 answer format which will be entered using a numeric keyboard.
 
 If a maximum or minimum are specified, and the user enters a value outside the
 acceptable range, the question step view controller does not allow navigation
 until the value is back in the valid range.
 
 Questions or form items with this answer format produce an
 `ORKNumericQuestionResult`.
 */
ORK_CLASS_AVAILABLE
@interface ORKNumericAnswerFormat : ORKAnswerFormat

/**
 Convenience initializer.
 
 @param style       Style of numeric answer (decimal or integer).
 
 @return Returns a new instance.
 */
- (instancetype)initWithStyle:(ORKNumericAnswerStyle)style;

/**
 Convenience initializer.
 
 @param style       Style of numeric answer (decimal or integer).
 @param unit        Localized unit string to display.
 
 @return Returns a new instance.
 */
- (instancetype)initWithStyle:(ORKNumericAnswerStyle)style
                         unit:(ORK_NULLABLE NSString *)unit;

/**
 Designated initializer.
 
 @param style       Style of numeric answer (decimal or integer).
 @param unit        Localized unit string to display.
 @param minimum     Minimum value to apply, or `nil` if none.
 @param maximum     Maximum value to apply, or `nil` if none.
 
 @return Returns a new instance.
 */
- (instancetype)initWithStyle:(ORKNumericAnswerStyle)style
                         unit:(ORK_NULLABLE NSString *)unit
                      minimum:(ORK_NULLABLE NSNumber *)minimum
                      maximum:(ORK_NULLABLE NSNumber *)maximum NS_DESIGNATED_INITIALIZER;

/**
 Style of numeric entry (decimal or integer) (read-only).
 */
@property (readonly) ORKNumericAnswerStyle style;

/**
 Localized unit string to display next to the numeric value (read-only).
 
 For example, days / lbs / times.
 The unit string is included in the `ORKNumericQuestionResult`.
 
 This text should be localized to the current language.
 */
@property (readonly, copy, ORK_NULLABLE) NSString *unit;

/**
 Minimum allowed value.
 
 If `nil`, no minimum is applied.
 */
@property (copy, ORK_NULLABLE) NSNumber *minimum;

/**
 Maximum allowed value.
 
 If `nil`, no maximum is applied.
 */
@property (copy, ORK_NULLABLE) NSNumber *maximum;



@end

/**
 The `ORKTimeOfDayAnswerFormat` class is used for questions which require the user
 to enter a time of day.
 
 Produces `ORKTimeOfDayQuestionResult`.
 */
ORK_CLASS_AVAILABLE
@interface ORKTimeOfDayAnswerFormat : ORKAnswerFormat

- (instancetype)init;

/**
 Designated initializer.
 
 @param defaultComponents   The default value onto which to configure the picker.
 
 @return Returns a new instance.
 */
- (instancetype)initWithDefaultComponents:(ORK_NULLABLE NSDateComponents *)defaultComponents NS_DESIGNATED_INITIALIZER;


/**
 Default time of day value to be displayed (read-only).
 
 The hour and minute components are observed. If nil, the picker defaults to
 the current time of day.
 */
@property (nonatomic, readonly, copy, ORK_NULLABLE) NSDateComponents *defaultComponents;

@end

/// The style of date picker to be shown in an `ORKDateAnswerFormat`.
typedef NS_ENUM(NSInteger, ORKDateAnswerStyle) {
    /// DateAndTime question type ask for a time or a combination of date and time, can be chosen from a picker.
    ORKDateAnswerStyleDateAndTime,
    
    /// Date question type can be used to ask for a certain date, can be chosen from a picker.
    ORKDateAnswerStyleDate
} ORK_ENUM_AVAILABLE;

/**
 The `ORKDateAnswerFormat` class is used for questions which require the user
 to enter a date, or a date and time.
 
 Produces an `ORKDateQuestionResult`.
 */
ORK_CLASS_AVAILABLE
@interface ORKDateAnswerFormat : ORKAnswerFormat

/**
 Convenience initializer.
 
 @param style       Style of date answer (date, or date and time).
 
 @return Returns a new instance.
 */
- (instancetype)initWithStyle:(ORKDateAnswerStyle)style;

/**
 Designated initializer.
 
 @param style       Style of date answer (date, or date and time).
 @param defaultDate Default date (if `nil`, the picker will default to the time of presentation).
 @param minimumDate The minimum date which is permitted in the picker. If `nil`, no limit.
 @param maximumDate The maximum date which is permitted in the picker. If `nil`, no limit.
 @param calendar    An explicit calendar to use. If `nil`, the locale's default calendar is used.
 
 @return Returns a new instance.
 */
- (instancetype)initWithStyle:(ORKDateAnswerStyle)style
                  defaultDate:(ORK_NULLABLE NSDate *)defaultDate
                  minimumDate:(ORK_NULLABLE NSDate *)minimumDate
                  maximumDate:(ORK_NULLABLE NSDate *)maximumDate
                     calendar:(ORK_NULLABLE NSCalendar *)calendar NS_DESIGNATED_INITIALIZER;

/**
 The style of date entry.
 */
@property (readonly) ORKDateAnswerStyle style;

/**
 The date to use as the default.
 
 The date will be displayed in the user's time zone.
 If `nil`, time of presentation is used as the starting point.
 */
@property (readonly, copy, ORK_NULLABLE) NSDate *defaultDate;

/**
 The minimum allowed date.
 
 If `nil`, no limit.
 */
@property (readonly, copy, ORK_NULLABLE) NSDate *minimumDate;

/**
 The maximum allowed date.
 
 If `nil`, no limit.
 */
@property (readonly, copy, ORK_NULLABLE) NSDate *maximumDate;

/**
 Calendar to use when selecting date and time.
 
 If nil, uses the user's default calendar.
 */
@property (readonly, copy, ORK_NULLABLE) NSCalendar *calendar;

@end


/**
 The `ORKTextAnswerFormat` class is used for questions which collect a text response
 from the user.
 
 Produces `ORKTextQuestionResult`.
 */
ORK_CLASS_AVAILABLE
@interface ORKTextAnswerFormat : ORKAnswerFormat

/**
 Designated initializer.
 
 @param maximumLength       Maximum number of characters to accept. If 0, no limit is applied.
 
 @return Returns a new instance.
 */
- (instancetype)initWithMaximumLength:(NSInteger)maximumLength NS_DESIGNATED_INITIALIZER;

/**
 The maximum length of the text to be allowed (read-only).
 
 A maximum length of 0 does not apply a limit.
 */
@property (readonly) NSInteger maximumLength;

/**
 A boolean value indicating whether to expect more than one line of input.
 
 The default is YES.
 */
@property BOOL multipleLines;

/**
 The autocapitalization type.
 
 The default is `UITextAutocapitalizationTypeSentences`.
 */
@property UITextAutocapitalizationType autocapitalizationType;

/**
 The autocorrection type.
 
 The default is `UITextAutocorrectionTypeDefault`.
 */
@property UITextAutocorrectionType autocorrectionType;

/**
 The spell checking type.
 
 The default is `ITextSpellCheckingTypeDefault`.
 */
@property UITextSpellCheckingType spellCheckingType;


@end

/**
 The `ORKTimeIntervalAnswerFormat` class is used for questions in which the user
 needs to specify a time interval.
 
 This is suitable for time intervals up to 24 hours. Beyond that, other methods
 such as an ORKValuePickerAnswerFormat should be used.
 
 Note that it is not possible currently to select 0 using this answer format.
 
 Produces ORKTimeIntervalQuestionResult.
 */
ORK_CLASS_AVAILABLE
@interface ORKTimeIntervalAnswerFormat : ORKAnswerFormat

/**
 Designated initializer.
 
 @param defaultInterval     The default value that should be shown on the picker.
 @param step                The step in the interval, in minutes. The step must be
                            between 1 and 30.
 
 @return Returns a new instance.
 */
- (instancetype)initWithDefaultInterval:(NSTimeInterval)defaultInterval
                                   step:(NSInteger)step NS_DESIGNATED_INITIALIZER;


/**
 Initial position of the time interval picker.
 */
@property (readonly) NSTimeInterval defaultInterval;

/**
 Allowed step in the interval, in minutes.
 
 The default step is 1; minimum is 1, maximum is 30.
 */
@property (readonly) NSInteger step;

@end


ORK_ASSUME_NONNULL_END
