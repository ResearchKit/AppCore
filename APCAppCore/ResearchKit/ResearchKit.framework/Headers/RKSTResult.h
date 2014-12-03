//
//  RKSTResult.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKSTAnswerFormat.h>

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
@interface RKSTResult : NSObject<NSCopying,NSSecureCoding>

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
@property (nonatomic, copy) NSDictionary *metadata;


@end


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
@property (nonatomic, copy) NSURL *fileUrl;

@end

@interface RKSTDateAnswer : NSObject<NSCopying,NSSecureCoding>

- (instancetype)initWithDateComponents:(NSDateComponents *)dateComponents calendar:(NSCalendar *)calendar;

@property (nonatomic, copy, readonly) NSDateComponents *dateComponents;
@property (nonatomic, copy, readonly) NSCalendar *calendar;

@end


@interface RKSTQuestionResult : RKSTResult

/**
 * @brief The question's type.
 */
@property (nonatomic) RKSurveyQuestionType questionType;

/**
 * @brief Actual answer to the question.
 *
 * Different types of question use different types of object to store the answer.
 *      Single choice: the selected RKAnswerOption's `value` property.
 *      Multiple choice: array of values from selected RKAnswerOptions' `value` properties.
 *      Boolean: NSNumber
 *      Text: NSString
 *      Scale: NSNumber
 *      Date: RKSTDateAnswer with date components having (NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay).
 *      Time: RKSTDateAnswer with date components having (NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond).
 *      DateAndTime: RKSTDateAnswer with date components having (NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond).
 *      Time Interval: NSNumber, containing a time span in seconds.
 */
@property (nonatomic, copy) id answer;

@end


/**
 * @brief Result containing a completed signature.
 */
@interface RKSTConsentSignatureResult : RKSTResult

@property (nonatomic, copy) RKSTConsentSignature *signature;

// Apply the signature to the document.
- (void)applyToDocument:(RKSTConsentDocument *)document;

@end



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
@interface RKSTStepResult: RKSTCollectionResult


- (instancetype)initWithStepIdentifier:(NSString *)stepIdentifier results:(NSArray *)results;


@end








