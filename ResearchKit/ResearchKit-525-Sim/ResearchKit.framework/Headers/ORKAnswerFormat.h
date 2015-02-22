//
//  ORKAnswerFormat.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ResearchKit/ORKDefines.h>

typedef NS_ENUM(NSInteger, ORKQuestionType) {
    ORKQuestionTypeNone,                   // No question.
    ORKQuestionTypeScale,                  // Continuous rating scale, ask participant place a mark at an appropriate position on a continuous line.
    ORKQuestionTypeSingleChoice,           // Single choice questions are those where the participant can only pick a single predefined answer option.
    ORKQuestionTypeMultipleChoice,         // Multiple choice questions are those where the participant can pick one or more predefined answer options.
    ORKQuestionTypeDecimal,                // Decimal question type asks the participant to enter a decimal number.
    ORKQuestionTypeInteger,                // Integer question type asks the participant to enter a integer number.
    ORKQuestionTypeBoolean,                // Boolean type question collects a response of "Yes" or "No" from the participant.
    ORKQuestionTypeText,                   // Text question type collects multiple lines of text input.
    ORKQuestionTypeTimeOfDay,              // Time of day question type can be used to ask for a certain time in a day, can be chosen from a picker.
    ORKQuestionTypeDateAndTime,            // DateAndTime question type ask for a time or a combination of date and time, can be chosen from a picker.
    ORKQuestionTypeDate,                   // Date question type can be used to ask for a certain date, can be chosen from a picker.
    ORKQuestionTypeTimeInterval            // TimeInterval question type can be used to ask for a certain time span, can be chosen from a picker.
} ORK_ENUM_AVAILABLE;


typedef NS_ENUM(NSInteger, ORKChoiceAnswerStyle) {
    ORKChoiceAnswerStyleSingleChoice,           // Single choice questions are those where the participant can only pick a single predefined answer option.
    ORKChoiceAnswerStyleMultipleChoice          // Multiple choice questions are those where the participant can pick one or more predefined answer options.
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
 * @brief The ORKAnswerFormat class contains details about answer.
 *
 * ORKAnswerFormat contains the question type
 * Allow subclasses to add additional attributes which fit specific types of question.
 * @discussion
 */
ORK_CLASS_AVAILABLE
@interface ORKAnswerFormat : NSObject<NSSecureCoding, NSCopying>

@property (readonly) ORKQuestionType questionType;

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

+ (ORKNumericAnswerFormat *)decimalAnswerFormatWithUnit:(NSString *)unit;
+ (ORKNumericAnswerFormat *)integerAnswerFormatWithUnit:(NSString *)unit;

+ (ORKTimeOfDayAnswerFormat *)timeOfDayAnswerFormat;
+ (ORKTimeOfDayAnswerFormat *)timeOfDayAnswerFormatWithDefaultComponents:(NSDateComponents *)defaultComponents;

+ (ORKDateAnswerFormat *)dateTimeAnswerFormat;
+ (ORKDateAnswerFormat *)dateTimeAnswerFormatWithDefaultDate:(NSDate *)defaultDate
                                          minimumDate:(NSDate *)minimumDate
                                          maximumDate:(NSDate *)maximumDate
                                             calendar:(NSCalendar *)calendar;

+ (ORKDateAnswerFormat *)dateAnswerFormat;
+ (ORKDateAnswerFormat *)dateAnswerFormatWithDefaultDate:(NSDate *)defaultDate
                                      minimumDate:(NSDate *)minimumDate
                                      maximumDate:(NSDate *)maximumDate
                                         calendar:(NSCalendar *)calendar;

+ (ORKTextAnswerFormat *)textAnswerFormat;
+ (ORKTextAnswerFormat *)textAnswerFormatWithMaximumLength:(NSInteger)maximumLength;

+ (ORKTimeIntervalAnswerFormat *)timeIntervalAnswerFormat;
+ (ORKTimeIntervalAnswerFormat *)timeIntervalAnswerFormatWithDefaultInterval:(NSTimeInterval)defaultInterval step:(NSInteger)step;


/**
 * @brief Check its parameters and throw exceptions on invalid parameters.
 * @discussion This is called when there is a need to validate its parameters.
 */
- (void)validateParameters;

@end



/**
 * @brief The ORKScaleAnswerFormat class defines the attributes for a scale type answer.
 * Slider with markers spaced along the line at discrete integer values.
 * Produces ORKScaleQuestionResult.
 */
ORK_CLASS_AVAILABLE
@interface ORKScaleAnswerFormat : ORKAnswerFormat


- (instancetype)initWithMaximumValue:(NSInteger)maximumValue
                        minimumValue:(NSInteger)minimumValue
                                step:(NSInteger)step
                        defaultValue:(NSInteger)defaultValue NS_DESIGNATED_INITIALIZER;

/**
 * @brief Upper bound of the scale.
 */
@property (readonly) NSInteger maximum;

/**
 * @brief Lower bound of the scale.
 */
@property (readonly) NSInteger minimum;


/**
 * @brief The size of each discrete offset on the scale. Should be > 0.
 * Difference between maximumValue and minimumValue shoule be divisible by step value.
 */
@property (readonly) NSInteger step;

/**
 * @brief Default value for the slider.
 * If defaultValue < minimum or defaultValue > maximum, the slider will have no default.
 * Otherwise, the value will be rounded to the nearest valid step.
 */
@property (readonly) NSInteger defaultValue;

@end

/**
 * @brief The ORKContinuousScaleAnswerFormat class defines the attributes for a scale type answer.
 * Slider with no markers.
 * Produces ORKScaleQuestionResult with a real-valued result.
 */
ORK_CLASS_AVAILABLE
@interface ORKContinuousScaleAnswerFormat : ORKAnswerFormat


- (instancetype)initWithMaximumValue:(double)maximumValue
                        minimumValue:(double)minimumValue
                        defaultValue:(double)defaultValue
               maximumFractionDigits:(NSInteger)maximumFractionDigits NS_DESIGNATED_INITIALIZER;

/**
 * @brief Upper bound of the scale.
 */
@property (readonly) double maximum;

/**
 * @brief Lower bound of the scale.
 */
@property (readonly) double minimum;

/**
 * @brief Default value for the slider.
 * If defaultValue < minimum or defaultValue > maximum, the slider will have no default.
 */
@property (readonly) double defaultValue;

/**
 * @brief Maximum number of fractional digits to display
 */
@property (readonly) NSInteger maximumFractionDigits;

@end

/**
 * @brief Format for a value picker with a fixed set of text choices.
 * Reports its self to be single choice question. The participant can pick one value from a picker view.
 * Produces ORKChoiceQuestionResult.
 */
ORK_CLASS_AVAILABLE
@interface ORKValuePickerAnswerFormat : ORKAnswerFormat

/**
 * @brief Create a value picker answer format to select from a set of text choices.
 * @param textChoices         Array of ORKTextChoice.
 * @discussion ORKTextChoice's detailText is ignored, text needs to be short enough to fit in a UIPickerView.
 */
- (instancetype)initWithTextChoices:(NSArray *)textChoices NS_DESIGNATED_INITIALIZER;

@property (readonly, copy) NSArray *textChoices; // ORKTextChoice

@end

/**
 * @brief Format for single choice question with a fixed set of image choices.
 * Produces ORKChoiceQuestionResult.
 */
ORK_CLASS_AVAILABLE
@interface ORKImageChoiceAnswerFormat : ORKAnswerFormat

/**
 * @brief Create a choice answer format to select on an image scale.
 * @param choices             Array of ORKImageChoice
 */
- (instancetype)initWithImageChoices:(NSArray *)imageChoices NS_DESIGNATED_INITIALIZER;

@property (readonly, copy) NSArray *imageChoices; // ORKImageChoice

@end

/**
 * @brief Format for a multiple or single choice question with a fixed set of text choices.
 * Produces ORKChoiceQuestionResult.
 */
ORK_CLASS_AVAILABLE
@interface ORKTextChoiceAnswerFormat : ORKAnswerFormat

/**
 * @brief Create a choice answer format to select from a set of text choices.
 * @param style               Whether single or multiple-choice.
 * @param textChoices         Array of ORKTextChoice.
 */
- (instancetype)initWithStyle:(ORKChoiceAnswerStyle)style
                  textChoices:(NSArray *)textChoices NS_DESIGNATED_INITIALIZER;

@property (readonly) ORKChoiceAnswerStyle style;

@property (readonly, copy) NSArray *textChoices; // ORKTextChoice

@end

/**
 * @brief The ORKBooleanAnswerFormat class allow participant pick from Yes or No from answer options.
 * Produces ORKBooleanQuestionResult.
 */
ORK_CLASS_AVAILABLE
@interface ORKBooleanAnswerFormat : ORKAnswerFormat

@end

/**
 * @brief The ORKTextChoice class defines brief option text for a option which can be included within ORKTextChoiceAnswerFormat.
 */
ORK_CLASS_AVAILABLE
@interface ORKTextChoice : NSObject <NSSecureCoding, NSCopying, NSObject>

+ (instancetype)choiceWithText:(NSString *)text detailText:(NSString *)detailText value:(id<NSCopying, NSCoding, NSObject>)value;

+ (instancetype)choiceWithText:(NSString *)text value:(id<NSCopying, NSCoding, NSObject>)value;

- (instancetype)initWithText:(NSString *)text
                  detailText:(NSString *)detailText
                       value:(id<NSCopying, NSCoding, NSObject>)value NS_DESIGNATED_INITIALIZER;

/**
 * @brief Brief option text.
 */
@property (readonly, copy) NSString *text;

/**
 * @brief The value to be returned if this option is selected.
 *
 * Expected to be a scalar property list type, e.g. NSNumber or NSString.
 * If no value is provided, the index of the option in the ORKTextChoiceAnswerFormat options list is used.
 */
@property (readonly, copy) id<NSCopying, NSCoding, NSObject> value;

/**
  * @brief Detailed option text.
  */
@property (readonly, copy) NSString *detailText;

@end

/**
  * @brief The ORKAnswerImageOption class defines  brief/detailed option text for a option which can be included within ORKImageChoiceAnswerFormat.
 */
ORK_CLASS_AVAILABLE
@interface ORKImageChoice : NSObject <NSSecureCoding, NSCopying>

+ (instancetype)choiceWithNormalImage:(UIImage *)normal
                        selectedImage:(UIImage *)selected
                                 text:(NSString *)text
                                value:(id<NSCopying, NSCoding, NSObject>)value;

- (instancetype)initWithNormalImage:(UIImage *)normal
                      selectedImage:(UIImage *)selected
                               text:(NSString *)text
                              value:(id<NSCopying, NSCoding, NSObject>)value NS_DESIGNATED_INITIALIZER;

/**
 * @brief Image for when option is unselected.
 */
@property (readonly, strong) UIImage *normalStateImage;

/**
  * @brief Image for when option is selected.
  */
@property (readonly, strong) UIImage *selectedStateImage;

/**
 * @brief Optional text.
 */
@property (readonly, copy) NSString *text;

/**
 * @brief The value to be returned if this option is selected.
 *
 * Expected to be a scalar property list type, e.g. NSNumber or NSString.
 * If no value is provided, the index of the option in the ORKImageChoiceAnswerFormat options list will be used.
 */
@property (readonly, copy) id<NSCopying, NSCoding, NSObject> value;


@end


typedef NS_ENUM(NSInteger, ORKNumericAnswerStyle) {
    ORKNumericAnswerStyleDecimal,           // Decimal question type asks the participant to enter a decimal number.
    ORKNumericAnswerStyleInteger            // Integer question type asks the participant to enter a integer number.
} ORK_ENUM_AVAILABLE;

/**
 * @brief The ORKNumericAnswerFormat class defines the attributes for a numeric type answer.
 *
 * Numeric question type asks the participant to enter a numeric value.
 * Produces ORKNumericQuestionResult.
 */
ORK_CLASS_AVAILABLE
@interface ORKNumericAnswerFormat : ORKAnswerFormat

- (instancetype)initWithStyle:(ORKNumericAnswerStyle)style;
- (instancetype)initWithStyle:(ORKNumericAnswerStyle)style
                         unit:(NSString*)unit;
- (instancetype)initWithStyle:(ORKNumericAnswerStyle)style
                         unit:(NSString *)unit
                      minimum:(NSNumber *)minimum
                      maximum:(NSNumber *)maximum NS_DESIGNATED_INITIALIZER;

/**
 * @brief Style of numeric entry
 */
@property (readonly) ORKNumericAnswerStyle style;

/**
 * @brief Unit in text for the numeric value.
 * For example, days / lbs / times.
 * Unit string will be saved in ORKQuestionResult's userInfo under "ORKResultNumericAnswerUnitUserInfoKey"
 */
@property (readonly, copy) NSString *unit;

/**
 * @brief Minimum qualified value.
 */
@property (copy) NSNumber *minimum;

/**
 * @brief Maximum qualified value.
 */
@property (copy) NSNumber *maximum;



@end

/**
 * @brief The ORKDateAnswerFormat class defines the attributes for time of day type answer.
 *
 * Ask for a time in day, can be chosen from a picker.
 * Produces ORKTimeOfDayQuestionResult.
 */
ORK_CLASS_AVAILABLE
@interface ORKTimeOfDayAnswerFormat : ORKAnswerFormat

- (instancetype)init;
- (instancetype)initWithDefaultComponents:(NSDateComponents *)defaultComponents NS_DESIGNATED_INITIALIZER;


/**
 * @brief Default time of day value to be displayed.
 * Hour and minute are observed.
 * If nil, time of presentation is used.
 */
@property (nonatomic, readonly, copy) NSDateComponents *defaultComponents;

@end


typedef NS_ENUM(NSInteger, ORKDateAnswerStyle) {
    ORKDateAnswerStyleDateAndTime,            // DateAndTime question type ask for a time or a combination of date and time, can be chosen from a picker.
    ORKDateAnswerStyleDate                    // Date question type can be used to ask for a certain date, can be chosen from a picker.
} ORK_ENUM_AVAILABLE;

/**
 * @brief The ORKDateAnswerFormat class defines the attributes for a date/time type answer.
 *
 * Ask for a date or a combination of date and time, can be chosen from a picker.
 * Produces ORKDateQuestionResult.
 */
ORK_CLASS_AVAILABLE
@interface ORKDateAnswerFormat : ORKAnswerFormat


- (instancetype)initWithStyle:(ORKDateAnswerStyle)style;

- (instancetype)initWithStyle:(ORKDateAnswerStyle)style
                  defaultDate:(NSDate *)defaultDate
                  minimumDate:(NSDate *)minimumDate
                  maximumDate:(NSDate *)maximumDate
                     calendar:(NSCalendar *)calendar NS_DESIGNATED_INITIALIZER;

/**
 * @brief Style of date entry
 */
@property (readonly) ORKDateAnswerStyle style;

/**
 * @brief Date to use as the default.
 * Date will be displayed in the user's time zone.
 * If nil, time of presentation is used as the default.
 */
@property (readonly, copy) NSDate *defaultDate;

/**
 * @brief Minimum allowed date.
 * If nil, no limit.
 */
@property (readonly, copy) NSDate *minimumDate;

/**
 * @brief Maximum allowed date.
 * If nil, no limit.
 */
@property (readonly, copy) NSDate *maximumDate;

/**
 * @brief Calendar to use when selecting date and time.
 * If nil, use user's default calendar.
 */
@property (readonly, copy) NSCalendar *calendar;

@end


/**
 * @brief The ORKTextAnswerFormat class defines the attributes for a text type answer.
 *
 * Text question type collects text input.
 * Produces ORKTextQuestionResult.
 */
ORK_CLASS_AVAILABLE
@interface ORKTextAnswerFormat : ORKAnswerFormat

- (instancetype)initWithMaximumLength:(NSInteger)maximumLength NS_DESIGNATED_INITIALIZER;

/**
 * @brief  Maximum length of the text to be allowed. 
 * Default is 0, which does not apply a limit.
 */
@property (readonly) NSInteger maximumLength;

/**
 * @brief Whether to expect more than one line of input
 * Default is YES
 */
@property BOOL multipleLines;


@property UITextAutocapitalizationType autocapitalizationType; // default is UITextAutocapitalizationTypeSentences
@property UITextAutocorrectionType autocorrectionType;         // default is UITextAutocorrectionTypeDefault
@property UITextSpellCheckingType spellCheckingType;           // default is UITextSpellCheckingTypeDefault;


@end

/**
 * @brief The ORKTimeIntervalAnswerFormat class defines the attributes for a time interval type answer.
 *
 * Can be used to ask for a certain time span chosen from a picker.
 * Produces ORKTimeIntervalQuestionResult.
 */
ORK_CLASS_AVAILABLE
@interface ORKTimeIntervalAnswerFormat : ORKAnswerFormat

- (instancetype)initWithDefaultInterval:(NSTimeInterval)defaultInterval
                                   step:(NSInteger)step NS_DESIGNATED_INITIALIZER;


/**
 * @brief Initial position of the time interval picker.
 */
@property (readonly) NSTimeInterval defaultInterval;

/**
 * @brief Step in the interval in minutes.
 * Default is 1; min is 1, max is 30.
 */
@property (readonly) NSInteger step;

@end
