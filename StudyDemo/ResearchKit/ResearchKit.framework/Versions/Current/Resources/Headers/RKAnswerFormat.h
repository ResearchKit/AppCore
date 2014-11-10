//
//  RKAnswerFormat.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
@interface RKAnswerFormat : NSObject<NSSecureCoding>

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
+ (instancetype)choiceAnswerWithOptions:(NSArray /* <RKAnswerOption> */ *)options style:(RKChoiceAnswerStyle)style;

/**
 * @brief Style of answer desired
 */
@property (nonatomic, readonly) RKChoiceAnswerStyle style;

/**
 * @brief An list of <RKAnswerOption> objects.
 */
@property (nonatomic, readonly, copy) NSArray *options;

@end

/**
 * @brief The RKBooleanAnswerFormat class allow participant pick from Yes or No from answer options.
 */
@interface RKBooleanAnswerFormat : RKAnswerFormat


@end

/**
 * @brief The RKAnswerOption protocol defines brief option text for a option which can be included within RKChoiceAnswerFormat.
 */
@protocol RKAnswerOption <NSObject>

/**
 * @brief Brief option text.
 */
- (NSString*)text;

/**
 * @brief The value to be returned if this option is selected.
 *
 * Expected to be a scalar type serializable to JSON, e.g. NSNumber or NSString.
 * If no value is provided, the index of the option in the RKChoiceAnswerFormat options list will be used.
 */
- (id)value;

@end

/**
 * @brief The RKTextAnswerOption class defines brief option text for a option which can be included within RKChoiceAnswerFormat.
 */
@interface RKTextAnswerOption : NSObject <RKAnswerOption, NSSecureCoding>

/**
 * @brief Designated convenience constructor
 */
+ (instancetype)optionWithText:(NSString*)text detailText:(NSString*)detailText value:(id)value;

/**
 * @brief Designated convenience constructor
 */
+ (instancetype)optionWithText:(NSString*)text value:(id)value;

/**
  * @brief Detailed option text.
  */
@property (nonatomic, readonly, copy) NSString* detailText;

@end

/**
  * @brief The RKAnswerImageOption class defines  brief/detailed option text for a option which can be included within RKChoiceAnswerFormat.
  */
@interface RKImageAnswerOption : NSObject <RKAnswerOption, NSSecureCoding>

/**
 * @brief Designated convenience constructor
 */
+ (instancetype)optionWithNormalImage:(UIImage*)normal selectedImage:(UIImage*)selected text:(NSString*)text value:(id)value;
/**
 * @brief Image for when option is unselected.
 */
@property (nonatomic, readonly, strong) UIImage* normalStateImage;

/**
  * @brief Image for when option is selected.
  */
@property (nonatomic, readonly, strong) UIImage* selectedStateImage;


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

+ (instancetype)dateTimeAnswer;
+ (instancetype)dateAnswer;
+ (instancetype)timeAnswer;

/**
 * @brief Convenience constructor for DateAndTime type.
 * @param defaultDate Date components. Year, month, day, hour, minute, and second are observed.
 *     Any components not provided will be replaced with components for the "relativeDate".
 * @param relativeDate Date that default components are applied relative to. Defaults to time of presentation.
 * @param minimum Date components for the beginning of the allowable range. If nil, no limit.
 * @param maximum Date components for the end of the allowable range. If nil, no limit.
 */
+ (instancetype)dateTimeAnswerWithDefault:(NSDateComponents *)defaultDate relativeToDate:(NSDate *)relativeDate minimum:(NSDateComponents *)minimum maximum:(NSDateComponents *)maximum;

/**
 * @brief Convenience constructor for Date type.
 * @param defaultDate Date components. Year, month, and day are observed.
 *     Any components not provided will be replaced with components for the "relativeDate".
 * @param relativeDate Date that default components are applied relative to. Defaults to time of presentation.
 * @param minimum Date components for the beginning of the allowable range. If nil, no limit.
 * @param maximum Date components for the end of the allowable range. If nil, no limit.
 */
+ (instancetype)dateAnswerWithDefault:(NSDateComponents *)defaultDate relativeToDate:(NSDate *)relativeDate minimum:(NSDateComponents *)minimum maximum:(NSDateComponents *)maximum;

/**
 * @brief Convenience constructor for Time type.
 * @param defaultDate Date components for the default value. Hour, minute, and second are observed.
 *     Any components not provided will be replaced with components for the "relativeDate".
 * @param relativeDate Date that default components are applied relative to. Defaults to time of presentation.
 * @param minimum Date components for the beginning of the allowable range. If nil, no limit.
 * @param maximum Date components for the end of the allowable range. If nil, no limit.
 */
+ (instancetype)timeAnswerWithDefault:(NSDateComponents *)defaultTime relativeToDate:(NSDate *)relativeDate minimum:(NSDateComponents *)minimum maximum:(NSDateComponents *)maximum;

/**
 * @brief Style of date entry
 */
@property (nonatomic, readonly) RKDateAnswerStyle style;

@property (nonatomic, readonly, copy) NSDateComponents *defaultComponents;
@property (nonatomic, readonly, copy) NSDateComponents *minimum;
@property (nonatomic, readonly, copy) NSDateComponents *maximum;
@property (nonatomic, readonly, copy) NSDate *relativeToDate;

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

+ (instancetype)textAnswerWithMaximumLength:(NSNumber*)maximumLength;

/**
 * @brief  Maximum length of the text to be allowed. 
 *  Default is nil, not limited.
 */
@property (nonatomic, readonly, copy) NSNumber *maximumLength;

@end

/**
 * @brief The RKTimeIntervalAnswerFormat class defines the attributes for a time interval type answer.
 *
 * Can be used to ask for a certain time span chosen from a picker.
 */
@interface RKTimeIntervalAnswerFormat : RKAnswerFormat

+ (instancetype)timeIntervalAnswer;

/**
 * @brief Convenience constructor.
 * @param defaultInterval The initial position of the time interval picker.
 * @param maximumInterval The maximum selectable interval. The minimum is always 0.
 * @param step The step in the interval.
 */
+ (instancetype)timeIntervalAnswerWithDefault:(NSTimeInterval)defaultInterval maximum:(NSTimeInterval)maximumInterval step:(NSTimeInterval)step;

@property (nonatomic, readonly) NSTimeInterval maximumInterval;
@property (nonatomic, readonly) NSTimeInterval defaultInterval;
@property (nonatomic, readonly) NSTimeInterval step;

@end
