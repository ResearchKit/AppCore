//
//  RKAnswerFormat.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKSerialization.h>

typedef NS_ENUM(NSInteger, RKSurveyQuestionType) {
    RKSurveyQuestionTypeScale,                  // Continuous rating scale, ask participant place a mark at an appropriate position on a continuous line.
    RKSurveyQuestionTypeSingleChoice,           // Single choice questions are those where the participant can only pick a single predefined answer option.
    RKSurveyQuestionTypeMultipleChoice,         // Multiple choice questions are those where the participant can pick one or more predefined answer options.
    RKSurveyQuestionTypeDecimal,                // Decimal question type asks the participant to enter a decimal number.
    RKSurveyQuestionTypeInteger,                // Integer question type asks the participant to enter a integer number.
    RKSurveyQuestionTypeBoolean,                // Boolean type question collects a response of "Yes" or "No" from the participant.
    RKSurveyQuestionTypeText,                   // Text question type collects multiple lines of text input.
    RKSurveyQuestionTypeDateAndTime,            // DateAndTime question type ask for a time or a combination of date and time, can be chosen from a picker.
    RKSurveyQuestionTypeTime,                   // Time question type can be used to ask for a certain time, can be chosen from a picker.
    RKSurveyQuestionTypeDate,                   // Date question type can be used to ask for a certain date, can be chosen from a picker.
    RKSurveyQuestionTypeTimeInterval,           // TimeInterval question type can be used to ask for a certain time span, can be chosen from a picker.
    RKSurveyQuestionTypeCustom                  // Other types not defined in the framework.
};

/**
 * @brief The RKAnswerFormat class contains details about answer.
 *
 * RKAnswerFormat contains the question type
 * Allow subclasses to add additional attributes which fit specific types of question.
 * @discussion
 */
@interface RKAnswerFormat : NSObject<RKSerialization>

- (RKSurveyQuestionType) questionType;

@end

/**
 * @brief The RKScaleAnswerFormat class defines the attributes for a scale type answer.
 * Continuous rating scale, ask participant place a mark at an appropriate position on a continuous line.
 */
@interface RKScaleAnswerFormat : RKAnswerFormat

/**
 * @brief Convenience constructor.
 */
+ (instancetype)scaleAnswerWithMaxValue:(double)scaleMax
                               minValue:(double)scaleMin;

/**
 * @brief Upper bound of the scale.
 */
@property (nonatomic, readonly) double scaleMax;

/**
 * @brief Lower bound of the scale.
 */
@property (nonatomic, readonly) double scaleMin;

@end

typedef NS_ENUM(NSInteger, RKChoiceAnswerStyle) {
    RKChoiceAnswerStyleSingleChoice,           // Single choice questions are those where the participant can only pick a single predefined answer option.
    RKChoiceAnswerStyleMultipleChoice          // Multiple choice questions are those where the participant can pick one or more predefined answer options.
};

/**
 * @brief The RKChoiceAnswerFormat class defines predefined answer options for a choice type answer.
 * Choice question type are those where the participant can pick from predefined answer options.
 */
@interface RKChoiceAnswerFormat : RKAnswerFormat

/**
 * @brief Designated convenience constructor
 * @param options             A list of predefined options.
 * @param style               Answer style of the multiple-choice question
 */
+ (instancetype)choiceAnswerWithOptions:(NSArray *)options style:(RKChoiceAnswerStyle)style;

/**
 * @brief Style of answer desired
 */
@property (nonatomic, readonly) RKChoiceAnswerStyle style;

/**
 * @brief An list of RKAnswerOption objects.
 */
@property (nonatomic, readonly, copy) NSArray *options;

@end

/**
 * @brief The RKAnswerOption class defines  brief/detailed option text for a option which can be included within RKChoiceAnswerFormat.
 */
@interface RKAnswerOption : NSObject<RKSerialization>

/**
 * @brief Designated convenience constructor
 */
+ (instancetype)optionWithShortText:(NSString*)shortText longText:(NSString*)longText;

/**
 * @brief Brief option text.
 */
@property (nonatomic, readonly, copy) NSString* shortText;

/**
 * @brief Detailed option text.
 */
@property (nonatomic, readonly, copy) NSString* longText;

@end



typedef NS_ENUM(NSInteger, RKNumericAnswerStyle) {
    RKNumericAnswerStyleDecimal,           // Decimal question type asks the participant to enter a decimal number.
    RKNumericAnswerStyleInteger            // Integer question type asks the participant to enter a integer number.
};

/**
 * @brief The RKNumericAnswerFormat class defines the attributes for a numeric type answer.
 *
 * Numeric question type asks the participant to enter a numeric value.
 */
@interface RKNumericAnswerFormat : RKAnswerFormat

/**
 * @brief Convenience constructor for time decimal type answer.
 */
+ (instancetype)decimalAnswerWithUnit:(NSString*)unit;

/**
 * @brief Convenience constructor for time integer type answer.
 */
+ (instancetype)integerAnswerWithUnit:(NSString*)unit;

/**
 * @brief Style of numeric entry
 */
@property (nonatomic, readonly) RKNumericAnswerStyle style;

/**
 * @brief Unit in text for the numeric value.
 * For example, days / lbs / times.
 */
@property (nonatomic, readonly, copy) NSString *unit;

/**
 * @brief Minimum qualified value.
 */
@property (copy) NSNumber *minimum;

/**
 * @brief Maximum qualified value.
 */
@property (copy) NSNumber *maximum;

/**
 * @brief Rounding mode.
 * Default value is NSNumberFormatterRoundHalfEven
 */
@property NSNumberFormatterRoundingMode roundingMode;

/**
 * @brief Rounding increment.
 * Default value is nil, rounding will not be applied.
 */
@property (nonatomic, copy) NSNumber *roundingIncrement;

/**
 * @brief Manage the number of fraction digits.
 * Default value is nil, 0 will be used in actual formatting.
 */
@property (nonatomic, copy) NSNumber *minimumFractionDigits;

/**
 * @brief Manage the number of fraction digits.
 * Default value is nil, 42 will be used in actual formatting.
 */
@property (nonatomic, copy) NSNumber *maximumFractionDigits;


@end


typedef NS_ENUM(NSInteger, RKDateAnswerStyle) {
    RKDateAnswerStyleDateAndTime,            // DateAndTime question type ask for a time or a combination of date and time, can be chosen from a picker.
    RKDateAnswerStyleTime,                   // Time question type can be used to ask for a certain time, can be chosen from a picker.
    RKDateAnswerStyleDate                    // Date question type can be used to ask for a certain date, can be chosen from a picker.
};

/**
 * @brief The RKDateAnswerFormat class defines the attributes for a date/time type answer.
 *
 * Ask for a time or a date or a combination of date and time, can be chosen from a picker.
 */
@interface RKDateAnswerFormat : RKAnswerFormat

/**
 * @brief Convenience constructor for DateAndTime type.
 */
+ (instancetype)dateTimeAnswer;

/**
 * @brief Convenience constructor for Date type.
 */
+ (instancetype)dateAnswer;

/**
 * @brief Convenience constructor for Time type.
 */
+ (instancetype)timeAnswer;

/**
 * @brief Style of date entry
 */
@property (nonatomic, readonly) RKDateAnswerStyle style;

@end


/**
 * @brief The RKTextAnswerFormat class defines the attributes for a text type answer.
 *
 * Text question type collects multiple lines of text input.
 */
@interface RKTextAnswerFormat : RKAnswerFormat

/**
 * @brief Convenience constructor.
 */
+ (instancetype)textAnswer;

@end

/**
 * @brief The RKTimeIntervalAnswerFormat class defines the attributes for a time interval type answer.
 *
 * Can be used to ask for a certain time span chosen from a picker.
 */
@interface RKTimeIntervalAnswerFormat : RKAnswerFormat

/**
 * @brief Convenience constructor.
 */
+ (instancetype)timeIntervalAnswer;

@end
