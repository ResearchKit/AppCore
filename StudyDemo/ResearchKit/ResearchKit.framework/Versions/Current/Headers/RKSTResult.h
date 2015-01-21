//
//  RKSTResult.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKSTAnswerFormat.h>
#import <ResearchKit/RKSTDefines.h>

@class RKSTRecorder;
@class RKSTStep;
@class RKSTQuestionStep;
@class RKSTFormItem;
@class RKSTFormStep;
@class RKSTConsentReviewStep;
@class RKSTQuestionResult;
@class RKSTConsentSignature;
@class RKSTConsentDocument;
@class RKSTConsentSignatureResult;
@class RKSTStepResult;

/**
 * @brief The RKSTResult class defines the attributes of a result from one step or a group of steps.
 *
 * A result may be produced either directly in a step or task view controller, or by an RKSTRecorder subclass.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTResult : NSObject<NSCopying, NSSecureCoding>

- (instancetype)initWithIdentifier:(NSString *)identifier;

/**
 * @brief A meaningful identifier for this particular result.
 * @discussion RKSTTaskResult receives identifier from RKSTTask, RKSTStepResult receives identifier from RKSTStep,
 * and RKSTQuestionResult receives identifier from RKSTStep or RKSTFormItem, etc.
 */
@property (nonatomic, copy) NSString *identifier;

/**
 * @brief Time when the task, step, or data collection began.
 * @note For instantaneous items, startDate and endDate will be the same.
 */
@property (nonatomic, copy) NSDate *startDate;

/**
 * @brief Time when the task, step, or data collection stop. 
 * @note For instantaneous items, startDate and endDate will be the same.
 */
@property (nonatomic, copy) NSDate *endDate;

/**
 * @brief Metadata about the conditions in which this result was acquired.
 */
@property (nonatomic, copy) NSDictionary *userInfo;


@end



typedef NS_ENUM(NSInteger, RKTappingButtonIdentifier) {
    RKTappingButtonIdentifierNone,                  // Touch hit outside the two buttons.
    RKTappingButtonIdentifierLeft,
    RKTappingButtonIdentifierRight
} RK_ENUM_AVAILABLE_IOS(8_3);

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTTappingSample : NSObject<NSCopying, NSSecureCoding>

/**
 * @brief Between 0 and duration end.
 */
@property (nonatomic, assign) NSTimeInterval timestamp;

@property (nonatomic, assign) RKTappingButtonIdentifier buttonIdentifier;

/**
 * @brief Tapping location in step's view
 */
@property (nonatomic, assign) CGPoint location;

@end

/**
 * @brief The RKSTTappingIntervalResult contains result data from tapping interval test.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTTappingIntervalResult : RKSTResult

/**
 * @brief Collected samples, each item is a RKSTTappingSample object represents a tapping event.
 */
@property (nonatomic, copy) NSArray *samples;

/**
 * @brief button's rectangles and base view's size
 */
@property (nonatomic) CGSize stepViewSize;

@property (nonatomic) CGRect buttonRect1;

@property (nonatomic) CGRect buttonRect2;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTFileResult : RKSTResult

/**
 * @brief Result's contentType.
 */
@property (nonatomic, copy) NSString *contentType;

/**
 * @brief URL of the file produced.
 *
 * It is the responsibility of the receiver of the result object to delete
 * the file when it is no longer needed.
 */
@property (nonatomic, copy) NSURL *fileURL;

@end


/**
 * @brief Base class for leaf results from an item with an RKSTAnswerFormat.
 * @seealso RKSTQuestionStep, RKSTFormItem.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTQuestionResult : RKSTResult

@property (nonatomic) RKQuestionType questionType;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTScaleQuestionResult : RKSTQuestionResult

@property (nonatomic, copy) NSNumber *scaleAnswer;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTChoiceQuestionResult : RKSTQuestionResult

/**
 * @brief Array of selected values, from RKAnswerOption's `value` property.
 * For single choice, the array will have only one entry.
 */
@property (nonatomic, copy) NSArray *choiceAnswers;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTBooleanQuestionResult : RKSTQuestionResult

@property (nonatomic, copy) NSNumber *booleanAnswer;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTTextQuestionResult : RKSTQuestionResult

@property (nonatomic, copy) NSString *textAnswer;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTNumericQuestionResult : RKSTQuestionResult

@property (nonatomic, copy) NSNumber *numericAnswer;

/**
 * @brief Unit string displayed to the user as the value was entered
 */
@property (nonatomic, copy) NSString *unit;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTTimeOfDayQuestionResult : RKSTQuestionResult

@property (nonatomic, copy) NSDateComponents *dateComponentsAnswer;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTTimeIntervalQuestionResult : RKSTQuestionResult

@property (nonatomic, copy) NSNumber *intervalAnswer; // Interval in seconds

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTDateQuestionResult : RKSTQuestionResult

@property (nonatomic, copy) NSDate *dateAnswer;

/**
 * @brief Calendar used when selecting date and time.
 *  If developer specified nil in RKSTAnswerFormat, this calendar is user's default.
 */
@property (nonatomic, copy) NSCalendar *calendar;

/**
 * @brief User's time zone when selecting date and time.
 */
@property (nonatomic, copy) NSTimeZone *timeZone;

@end


/**
 * @brief Result containing a completed signature.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTConsentSignatureResult : RKSTResult

@property (nonatomic, copy) RKSTConsentSignature *signature;

- (void)applyToDocument:(RKSTConsentDocument *)document;

@end



RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTCollectionResult : RKSTResult

/**
 *  @brief An array of RKSTResult objects.
 *  @discussion For RKSTTaskResult, it is an array of RKSTStepResult objects.
 *  For RKSTStepResult it is an array of concrete result objects like: RKSTFileResult/RKSTQuestionResult.
 */
@property (nonatomic, copy) NSArray /* <RKSTResult> */ *results;

/**
 *  @brief Convenience method to lookup a result with a particular identifer.
 */
- (RKSTResult *)resultForIdentifier:(NSString *)identifier;

/**
 *  @brief Convenience method to get first result object from results array, if there is one.
 */
- (RKSTResult *)firstResult;

@end


@protocol RKSTTaskResultSource <NSObject>

/**
 *  @brief Return the result for the specified step, or nil for none.
 */
- (RKSTStepResult *)stepResultForStepIdentifier:(NSString *)stepIdentifier;

@end




/**
 * @brief RKSTTaskResult containing all results generated from one run of RKSTTaskViewController.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTTaskResult: RKSTCollectionResult <RKSTTaskResultSource>


- (instancetype)initWithTaskIdentifier:(NSString *)identifier
                           taskRunUUID:(NSUUID *)taskRunUUID
                       outputDirectory:(NSURL *)outputDirectory;


/**
 * @brief Task instance UUID
 *
 * @discussion Unique identifier for a run of the task controller.
 *
 */
@property (nonatomic, copy, readonly) NSUUID *taskRunUUID;

/**
 * @brief Designated directory to store generated data files.
 */
@property (nonatomic, copy, readonly) NSURL *outputDirectory;



@end


/**
 * @brief RKSTStepResult containing all results from one step.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTStepResult: RKSTCollectionResult


- (instancetype)initWithStepIdentifier:(NSString *)stepIdentifier results:(NSArray *)results;


@end








