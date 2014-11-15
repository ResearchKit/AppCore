//
//  RKResult.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKAnswerFormat.h>

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
@interface RKResult : NSObject<NSCopying,NSSecureCoding>

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
@property (nonatomic, copy) NSDictionary *metadata;


@end


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
@property (nonatomic, copy) NSURL *fileUrl;

@end

@interface RKDateAnswer : NSObject<NSCopying,NSSecureCoding>

- (instancetype)initWithDateComponents:(NSDateComponents *)dateComponents calendar:(NSCalendar *)calendar;

@property (nonatomic, copy, readonly) NSDateComponents *dateComponents;
@property (nonatomic, copy, readonly) NSCalendar *calendar;

@end


@interface RKQuestionResult : RKResult

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
 *      Date: RKDateAnswer with date components having (NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay).
 *      Time: RKDateAnswer with date components having (NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond).
 *      DateAndTime: RKDateAnswer with date components having (NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond).
 *      Time Interval: NSNumber, containing a time span in seconds.
 */
@property (nonatomic, copy) id answer;

@end


/**
 * @brief Result containing a completed signature.
 */
@interface RKConsentSignatureResult : RKResult

@property (nonatomic, copy) RKConsentSignature *signature;

// Apply the signature to the document.
- (void)applyToDocument:(RKConsentDocument *)document;

@end



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
@interface RKStepResult: RKCollectionResult


- (instancetype)initWithStepIdentifier:(NSString *)stepIdentifier results:(NSArray *)results;


@end








