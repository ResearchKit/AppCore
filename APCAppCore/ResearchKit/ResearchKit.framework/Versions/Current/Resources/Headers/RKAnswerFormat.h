//
//  RKAnswerFormat.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ResearchKit/RKDefines.h>

typedef NS_ENUM(NSInteger, RKQuestionType) {
    RKQuestionTypeNone,                   // No question.
    RKQuestionTypeScale,                  // Continuous rating scale, ask participant place a mark at an appropriate position on a continuous line.
    RKQuestionTypeSingleChoice,           // Single choice questions are those where the participant can only pick a single predefined answer option.
    RKQuestionTypeMultipleChoice,         // Multiple choice questions are those where the participant can pick one or more predefined answer options.
    RKQuestionTypeDecimal,                // Decimal question type asks the participant to enter a decimal number.
    RKQuestionTypeInteger,                // Integer question type asks the participant to enter a integer number.
    RKQuestionTypeBoolean,                // Boolean type question collects a response of "Yes" or "No" from the participant.
    RKQuestionTypeText,                   // Text question type collects multiple lines of text input.
    RKQuestionTypeTimeOfDay,              // Time of day question type can be used to ask for a certain time in a day, can be chosen from a picker.
    RKQuestionTypeDateAndTime,            // DateAndTime question type ask for a time or a combination of date and time, can be chosen from a picker.
    RKQuestionTypeDate,                   // Date question type can be used to ask for a certain date, can be chosen from a picker.
    RKQuestionTypeTimeInterval            // TimeInterval question type can be used to ask for a certain time span, can be chosen from a picker.
} RK_ENUM_AVAILABLE_IOS(8_3);


typedef NS_ENUM(NSInteger, RKChoiceAnswerStyle) {
    RKChoiceAnswerStyleSingleChoice,           // Single choice questions are those where the participant can only pick a single predefined answer option.
    RKChoiceAnswerStyleMultipleChoice          // Multiple choice questions are those where the participant can pick one or more predefined answer options.
} RK_ENUM_AVAILABLE_IOS(8_3);


@class RKScaleAnswerFormat;
@class RKImageChoiceAnswerFormat;
@class RKTextChoiceAnswerFormat;
@class RKBooleanAnswerFormat;
@class RKNumericAnswerFormat;
@class RKTimeOfDayAnswerFormat;
@class RKDateAnswerFormat;
@class RKTextAnswerFormat;
@class RKTimeIntervalAnswerFormat;

/**
 * @brief The RKAnswerFormat class contains details about answer.
 *
 * RKAnswerFormat contains the question type
 * Allow subclasses to add additional attributes which fit specific types of question.
 * @discussion
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKAnswerFormat : NSObject<NSSecureCoding, NSCopying>

@property (readonly) RKQuestionType questionType;

+ (RKScaleAnswerFormat *)scaleAnswerFormatWithMaxValue:(NSInteger)scaleMax
                                              minValue:(NSInteger)scaleMin
                                                  step:(NSInteger)step
                                          defaultValue:(NSInteger)defaultValue;

+ (RKBooleanAnswerFormat *)booleanAnswerFormat;

+ (RKImageChoiceAnswerFormat *)choiceAnswerFormatWithStyle:(RKChoiceAnswerStyle)style
                                        imageChoices:(NSArray *)imageChoices;

+ (RKTextChoiceAnswerFormat *)choiceAnswerFormatWithStyle:(RKChoiceAnswerStyle)style
                                        textChoices:(NSArray *)textChoices;

+ (RKNumericAnswerFormat *)decimalAnswerFormatWithUnit:(NSString *)unit;
+ (RKNumericAnswerFormat *)integerAnswerFormatWithUnit:(NSString *)unit;

+ (RKTimeOfDayAnswerFormat *)timeOfDayAnswerFormat;
+ (RKTimeOfDayAnswerFormat *)timeOfDayAnswerFormatWithDefaultComponents:(NSDateComponents *)defaultComponents;

+ (RKDateAnswerFormat *)dateTimeAnswerFormat;
+ (RKDateAnswerFormat *)dateTimeAnswerFormatWithDefaultDate:(NSDate *)defaultDate
                                          minimumDate:(NSDate *)minimumDate
                                          maximumDate:(NSDate *)maximumDate
                                             calendar:(NSCalendar *)calendar;

+ (RKDateAnswerFormat *)dateAnswerFormat;
+ (RKDateAnswerFormat *)dateAnswerFormatWithDefaultDate:(NSDate *)defaultDate
                                      minimumDate:(NSDate *)minimumDate
                                      maximumDate:(NSDate *)maximumDate
                                         calendar:(NSCalendar *)calendar;

+ (RKTextAnswerFormat *)textAnswerFormat;
+ (RKTextAnswerFormat *)textAnswerFormatWithMaximumLength:(NSInteger)maximumLength;

+ (RKTimeIntervalAnswerFormat *)timeIntervalAnswerFormat;
+ (RKTimeIntervalAnswerFormat *)timeIntervalAnswerFormatWithDefaultInterval:(NSTimeInterval)defaultInterval step:(NSInteger)step;


@end



/**
 * @brief The RKScaleAnswerFormat class defines the attributes for a scale type answer.
 * Slider with markers spaced along the line at discrete integer values.
 * Produces RKScaleQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKScaleAnswerFormat : RKAnswerFormat


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
 * @brief Format for a multiple or single choice question with a fixed set of image choices.
 * Produces RKChoiceQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKImageChoiceAnswerFormat : RKAnswerFormat

/**
 * @brief Create a choice answer format to select on an image scale.
 * @param choices             Array of RKImageChoice
 * @param style               Whether single or multiple-choice.
 */
- (instancetype)initWithStyle:(RKChoiceAnswerStyle)style
                 imageChoices:(NSArray *)imageChoices NS_DESIGNATED_INITIALIZER;

@property (readonly) RKChoiceAnswerStyle style;

@property (readonly, copy) NSArray *imageChoices; // RKImageChoice

@end

/**
 * @brief Format for a multiple or single choice question with a fixed set of text choices.
 * Produces RKChoiceQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKTextChoiceAnswerFormat : RKAnswerFormat

/**
 * @brief Create a choice answer format to select from a set of text choices.
 * @param style               Whether single or multiple-choice.
 * @param textChoices         Array of RKTextChoice.
 */
- (instancetype)initWithStyle:(RKChoiceAnswerStyle)style
                  textChoices:(NSArray *)textChoices NS_DESIGNATED_INITIALIZER;

@property (readonly) RKChoiceAnswerStyle style;

@property (readonly, copy) NSArray *textChoices; // RKTextChoice

@end

/**
 * @brief The RKBooleanAnswerFormat class allow participant pick from Yes or No from answer options.
 * Produces RKBooleanQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKBooleanAnswerFormat : RKAnswerFormat

@end

/**
 * @brief The RKTextChoice class defines brief option text for a option which can be included within RKTextChoiceAnswerFormat.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKTextChoice : NSObject <NSSecureCoding, NSCopying, NSObject>

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
 * If no value is provided, the index of the option in the RKTextChoiceAnswerFormat options list is used.
 */
@property (readonly, copy) id<NSCopying, NSCoding, NSObject> value;

/**
  * @brief Detailed option text.
  */
@property (readonly, copy) NSString *detailText;

@end

/**
  * @brief The RKAnswerImageOption class defines  brief/detailed option text for a option which can be included within RKImageChoiceAnswerFormat.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKImageChoice : NSObject <NSSecureCoding, NSCopying>

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
 * If no value is provided, the index of the option in the RKImageChoiceAnswerFormat options list will be used.
 */
@property (readonly, copy) id<NSCopying, NSCoding, NSObject> value;


@end


typedef NS_ENUM(NSInteger, RKNumericAnswerStyle) {
    RKNumericAnswerStyleDecimal,           // Decimal question type asks the participant to enter a decimal number.
    RKNumericAnswerStyleInteger            // Integer question type asks the participant to enter a integer number.
} RK_ENUM_AVAILABLE_IOS(8_3);

/**
 * @brief The RKNumericAnswerFormat class defines the attributes for a numeric type answer.
 *
 * Numeric question type asks the participant to enter a numeric value.
 * Produces RKNumericQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKNumericAnswerFormat : RKAnswerFormat

- (instancetype)initWithStyle:(RKNumericAnswerStyle)style;
- (instancetype)initWithStyle:(RKNumericAnswerStyle)style
                         unit:(NSString*)unit;
- (instancetype)initWithStyle:(RKNumericAnswerStyle)style
                         unit:(NSString *)unit
                      minimum:(NSNumber *)minimum
                      maximum:(NSNumber *)maximum NS_DESIGNATED_INITIALIZER;

/**
 * @brief Style of numeric entry
 */
@property (readonly) RKNumericAnswerStyle style;

/**
 * @brief Unit in text for the numeric value.
 * For example, days / lbs / times.
 * Unit string will be saved in RKQuestionResult's userInfo under "RKResultNumericAnswerUnitUserInfoKey"
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
 * @brief The RKDateAnswerFormat class defines the attributes for time of day type answer.
 *
 * Ask for a time in day, can be chosen from a picker.
 * Produces RKTimeOfDayQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKTimeOfDayAnswerFormat : RKAnswerFormat

- (instancetype)init;
- (instancetype)initWithDefaultComponents:(NSDateComponents *)defaultComponents NS_DESIGNATED_INITIALIZER;


/**
 * @brief Default time of day value to be displayed.
 * Hour and minute are observed.
 * If nil, time of presentation is used.
 */
@property (nonatomic, readonly, copy) NSDateComponents *defaultComponents;

@end


typedef NS_ENUM(NSInteger, RKDateAnswerStyle) {
    RKDateAnswerStyleDateAndTime,            // DateAndTime question type ask for a time or a combination of date and time, can be chosen from a picker.
    RKDateAnswerStyleDate                    // Date question type can be used to ask for a certain date, can be chosen from a picker.
} RK_ENUM_AVAILABLE_IOS(8_3);

/**
 * @brief The RKDateAnswerFormat class defines the attributes for a date/time type answer.
 *
 * Ask for a date or a combination of date and time, can be chosen from a picker.
 * Produces RKDateQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKDateAnswerFormat : RKAnswerFormat


- (instancetype)initWithStyle:(RKDateAnswerStyle)style;

- (instancetype)initWithStyle:(RKDateAnswerStyle)style
                  defaultDate:(NSDate *)defaultDate
                  minimumDate:(NSDate *)minimumDate
                  maximumDate:(NSDate *)maximumDate
                     calendar:(NSCalendar *)calendar NS_DESIGNATED_INITIALIZER;

/**
 * @brief Style of date entry
 */
@property (readonly) RKDateAnswerStyle style;

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
 * @brief The RKTextAnswerFormat class defines the attributes for a text type answer.
 *
 * Text question type collects text input.
 * Produces RKTextQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKTextAnswerFormat : RKAnswerFormat

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
 * @brief The RKTimeIntervalAnswerFormat class defines the attributes for a time interval type answer.
 *
 * Can be used to ask for a certain time span chosen from a picker.
 * Produces RKTimeIntervalQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKTimeIntervalAnswerFormat : RKAnswerFormat

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
