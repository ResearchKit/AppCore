//
//  RKResult.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKAnswerFormat.h>
#import <ResearchKit/RKDefines.h>

@class RKRecorder;
@class RKStep;
@class RKQuestionStep;
@class RKFormItem;
@class RKFormStep;
@class RKConsentReviewStep;
@class RKQuestionResult;
@class RKConsentSignature;
@class RKConsentDocument;
@class RKConsentSignatureResult;
@class RKStepResult;

/**
 * @brief The RKResult class defines the attributes of a result from one step or a group of steps.
 *
 * A result may be produced either directly in a step or task view controller, or by an RKRecorder subclass.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKResult : NSObject<NSCopying, NSSecureCoding>

- (instancetype)initWithIdentifier:(NSString *)identifier;

/**
 * @brief A meaningful identifier for this particular result.
 * @discussion RKTaskResult receives identifier from RKTask, RKStepResult receives identifier from RKStep,
 * and RKQuestionResult receives identifier from RKStep or RKFormItem, etc.
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
@interface RKTappingSample : NSObject<NSCopying, NSSecureCoding>

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
 * @brief The RKTappingIntervalResult contains result data from tapping interval test.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKTappingIntervalResult : RKResult

/**
 * @brief Collected samples, each item is a RKTappingSample object represents a tapping event.
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
@interface RKFileResult : RKResult

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
 * @brief Base class for leaf results from an item with an RKAnswerFormat.
 * @seealso RKQuestionStep, RKFormItem.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKQuestionResult : RKResult

@property (nonatomic) RKQuestionType questionType;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKScaleQuestionResult : RKQuestionResult

@property (nonatomic, copy) NSNumber *scaleAnswer;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKChoiceQuestionResult : RKQuestionResult

/**
 * @brief Array of selected values, from RKAnswerOption's `value` property.
 * For single choice, the array will have only one entry.
 */
@property (nonatomic, copy) NSArray *choiceAnswers;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKBooleanQuestionResult : RKQuestionResult

@property (nonatomic, copy) NSNumber *booleanAnswer;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKTextQuestionResult : RKQuestionResult

@property (nonatomic, copy) NSString *textAnswer;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKNumericQuestionResult : RKQuestionResult

@property (nonatomic, copy) NSNumber *numericAnswer;

/**
 * @brief Unit string displayed to the user as the value was entered
 */
@property (nonatomic, copy) NSString *unit;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKTimeOfDayQuestionResult : RKQuestionResult

@property (nonatomic, copy) NSDateComponents *dateComponentsAnswer;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKTimeIntervalQuestionResult : RKQuestionResult

@property (nonatomic, copy) NSNumber *intervalAnswer; // Interval in seconds

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKDateQuestionResult : RKQuestionResult

@property (nonatomic, copy) NSDate *dateAnswer;

/**
 * @brief Calendar used when selecting date and time.
 *  If developer specified nil in RKAnswerFormat, this calendar is user's default.
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
@interface RKConsentSignatureResult : RKResult

@property (nonatomic, copy) RKConsentSignature *signature;

- (void)applyToDocument:(RKConsentDocument *)document;

@end



RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKCollectionResult : RKResult

/**
 *  @brief An array of RKResult objects.
 *  @discussion For RKTaskResult, it is an array of RKStepResult objects.
 *  For RKStepResult it is an array of concrete result objects like: RKFileResult/RKQuestionResult.
 */
@property (nonatomic, copy) NSArray /* <RKResult> */ *results;

/**
 *  @brief Convenience method to lookup a result with a particular identifer.
 */
- (RKResult *)resultForIdentifier:(NSString *)identifier;

/**
 *  @brief Convenience method to get first result object from results array, if there is one.
 */
- (RKResult *)firstResult;

@end


@protocol RKTaskResultSource <NSObject>

/**
 *  @brief Return the result for the specified step, or nil for none.
 */
- (RKStepResult *)stepResultForStepIdentifier:(NSString *)stepIdentifier;

@end




/**
 * @brief RKTaskResult containing all results generated from one run of RKTaskViewController.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKTaskResult: RKCollectionResult <RKTaskResultSource>


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
 * @brief RKStepResult containing all results from one step.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKStepResult: RKCollectionResult


- (instancetype)initWithStepIdentifier:(NSString *)stepIdentifier results:(NSArray *)results;


@end








