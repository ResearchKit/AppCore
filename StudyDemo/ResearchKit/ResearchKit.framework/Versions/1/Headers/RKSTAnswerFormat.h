//
//  RKSTAnswerFormat.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ResearchKit/RKSTDefines.h>

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


@class RKSTScaleAnswerFormat;
@class RKSTValuePickerAnswerFormat;
@class RKSTImageChoiceAnswerFormat;
@class RKSTTextChoiceAnswerFormat;
@class RKSTBooleanAnswerFormat;
@class RKSTNumericAnswerFormat;
@class RKSTTimeOfDayAnswerFormat;
@class RKSTDateAnswerFormat;
@class RKSTTextAnswerFormat;
@class RKSTTimeIntervalAnswerFormat;

/**
 * @brief The RKSTAnswerFormat class contains details about answer.
 *
 * RKSTAnswerFormat contains the question type
 * Allow subclasses to add additional attributes which fit specific types of question.
 * @discussion
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTAnswerFormat : NSObject<NSSecureCoding, NSCopying>

@property (readonly) RKQuestionType questionType;

+ (RKSTScaleAnswerFormat *)scaleAnswerFormatWithMaxValue:(NSInteger)scaleMax
                                              minValue:(NSInteger)scaleMin
                                                  step:(NSInteger)step
                                          defaultValue:(NSInteger)defaultValue;

+ (RKSTBooleanAnswerFormat *)booleanAnswerFormat;

+ (RKSTValuePickerAnswerFormat *)valuePickerAnswerFormatWithTextChoices:(NSArray *)textChoices;

+ (RKSTImageChoiceAnswerFormat *)choiceAnswerFormatWithImageChoices:(NSArray *)imageChoices;

+ (RKSTTextChoiceAnswerFormat *)choiceAnswerFormatWithStyle:(RKChoiceAnswerStyle)style
                                        textChoices:(NSArray *)textChoices;

+ (RKSTNumericAnswerFormat *)decimalAnswerFormatWithUnit:(NSString *)unit;
+ (RKSTNumericAnswerFormat *)integerAnswerFormatWithUnit:(NSString *)unit;

+ (RKSTTimeOfDayAnswerFormat *)timeOfDayAnswerFormat;
+ (RKSTTimeOfDayAnswerFormat *)timeOfDayAnswerFormatWithDefaultComponents:(NSDateComponents *)defaultComponents;

+ (RKSTDateAnswerFormat *)dateTimeAnswerFormat;
+ (RKSTDateAnswerFormat *)dateTimeAnswerFormatWithDefaultDate:(NSDate *)defaultDate
                                          minimumDate:(NSDate *)minimumDate
                                          maximumDate:(NSDate *)maximumDate
                                             calendar:(NSCalendar *)calendar;

+ (RKSTDateAnswerFormat *)dateAnswerFormat;
+ (RKSTDateAnswerFormat *)dateAnswerFormatWithDefaultDate:(NSDate *)defaultDate
                                      minimumDate:(NSDate *)minimumDate
                                      maximumDate:(NSDate *)maximumDate
                                         calendar:(NSCalendar *)calendar;

+ (RKSTTextAnswerFormat *)textAnswerFormat;
+ (RKSTTextAnswerFormat *)textAnswerFormatWithMaximumLength:(NSInteger)maximumLength;

+ (RKSTTimeIntervalAnswerFormat *)timeIntervalAnswerFormat;
+ (RKSTTimeIntervalAnswerFormat *)timeIntervalAnswerFormatWithDefaultInterval:(NSTimeInterval)defaultInterval step:(NSInteger)step;


@end



/**
 * @brief The RKSTScaleAnswerFormat class defines the attributes for a scale type answer.
 * Slider with markers spaced along the line at discrete integer values.
 * Produces RKSTScaleQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTScaleAnswerFormat : RKSTAnswerFormat


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
 * @brief Format for a value picker with a fixed set of text choices.
 * Reports its self to be single choice question. The participant can pick one value from a picker view.
 * Produces RKSTChoiceQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTValuePickerAnswerFormat : RKSTAnswerFormat

/**
 * @brief Create a value picker answer format to select from a set of text choices.
 * @param textChoices         Array of RKSTTextChoice.
 * @discussion RKSTTextChoice's detailText is ignored, text needs to be short enough to fit in a UIPickerView.
 */
- (instancetype)initWithTextChoices:(NSArray *)textChoices NS_DESIGNATED_INITIALIZER;

@property (readonly, copy) NSArray *textChoices; // RKSTTextChoice

@end

/**
 * @brief Format for single choice question with a fixed set of image choices.
 * Produces RKSTChoiceQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTImageChoiceAnswerFormat : RKSTAnswerFormat

/**
 * @brief Create a choice answer format to select on an image scale.
 * @param choices             Array of RKSTImageChoice
 */
- (instancetype)initWithImageChoices:(NSArray *)imageChoices NS_DESIGNATED_INITIALIZER;

@property (readonly, copy) NSArray *imageChoices; // RKSTImageChoice

@end

/**
 * @brief Format for a multiple or single choice question with a fixed set of text choices.
 * Produces RKSTChoiceQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTTextChoiceAnswerFormat : RKSTAnswerFormat

/**
 * @brief Create a choice answer format to select from a set of text choices.
 * @param style               Whether single or multiple-choice.
 * @param textChoices         Array of RKSTTextChoice.
 */
- (instancetype)initWithStyle:(RKChoiceAnswerStyle)style
                  textChoices:(NSArray *)textChoices NS_DESIGNATED_INITIALIZER;

@property (readonly) RKChoiceAnswerStyle style;

@property (readonly, copy) NSArray *textChoices; // RKSTTextChoice

@end

/**
 * @brief The RKSTBooleanAnswerFormat class allow participant pick from Yes or No from answer options.
 * Produces RKSTBooleanQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTBooleanAnswerFormat : RKSTAnswerFormat

@end

/**
 * @brief The RKSTTextChoice class defines brief option text for a option which can be included within RKSTTextChoiceAnswerFormat.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTTextChoice : NSObject <NSSecureCoding, NSCopying, NSObject>

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
 * If no value is provided, the index of the option in the RKSTTextChoiceAnswerFormat options list is used.
 */
@property (readonly, copy) id<NSCopying, NSCoding, NSObject> value;

/**
  * @brief Detailed option text.
  */
@property (readonly, copy) NSString *detailText;

@end

/**
  * @brief The RKAnswerImageOption class defines  brief/detailed option text for a option which can be included within RKSTImageChoiceAnswerFormat.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTImageChoice : NSObject <NSSecureCoding, NSCopying>

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
 * If no value is provided, the index of the option in the RKSTImageChoiceAnswerFormat options list will be used.
 */
@property (readonly, copy) id<NSCopying, NSCoding, NSObject> value;


@end


typedef NS_ENUM(NSInteger, RKNumericAnswerStyle) {
    RKNumericAnswerStyleDecimal,           // Decimal question type asks the participant to enter a decimal number.
    RKNumericAnswerStyleInteger            // Integer question type asks the participant to enter a integer number.
} RK_ENUM_AVAILABLE_IOS(8_3);

/**
 * @brief The RKSTNumericAnswerFormat class defines the attributes for a numeric type answer.
 *
 * Numeric question type asks the participant to enter a numeric value.
 * Produces RKSTNumericQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTNumericAnswerFormat : RKSTAnswerFormat

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
 * Unit string will be saved in RKSTQuestionResult's userInfo under "RKSTResultNumericAnswerUnitUserInfoKey"
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
 * @brief The RKSTDateAnswerFormat class defines the attributes for time of day type answer.
 *
 * Ask for a time in day, can be chosen from a picker.
 * Produces RKSTTimeOfDayQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTTimeOfDayAnswerFormat : RKSTAnswerFormat

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
 * @brief The RKSTDateAnswerFormat class defines the attributes for a date/time type answer.
 *
 * Ask for a date or a combination of date and time, can be chosen from a picker.
 * Produces RKSTDateQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTDateAnswerFormat : RKSTAnswerFormat


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
 * @brief The RKSTTextAnswerFormat class defines the attributes for a text type answer.
 *
 * Text question type collects text input.
 * Produces RKSTTextQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTTextAnswerFormat : RKSTAnswerFormat

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
 * @brief The RKSTTimeIntervalAnswerFormat class defines the attributes for a time interval type answer.
 *
 * Can be used to ask for a certain time span chosen from a picker.
 * Produces RKSTTimeIntervalQuestionResult.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTTimeIntervalAnswerFormat : RKSTAnswerFormat

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
