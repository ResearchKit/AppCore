//
//  RKResult.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKAnswerFormat.h>

@class RKRecorder;
@class RKDataArchive;
@class RKItemIdentifier;
@class RKStep;
@class RKQuestionStep;
@class RKFormItem;
@class RKFormStep;
@class RKSurveyResult;
@class RKQuestionResult;
@class RKFormResult;

@protocol RKSurveyResultProvider<NSObject>

@optional

- (RKFormResult *)resultForFormStep:(RKFormStep *)formStep;

- (RKQuestionResult *)resultForQuestionStep:(RKQuestionStep *)questionStep;

@end

/**
 * @brief The RKResult class defines the attributes of a result from one step or a group of steps.
 *
 * A result may be produced either directly in a step or task view controller, or by an RKRecorder subclass.
 */
@interface RKResult : NSObject<NSCopying,NSSecureCoding>

/**
 * @brief Convenience initializer.
 * @discussion Picks up the itemIdentifier from step object during initialization.
 * @param step The step that produced the result object.
 */
- (instancetype)initWithStep:(RKStep *)step;

/**
 * @brief Unique task instance identifier.
 * 
 * Each time a task is presented to participant, a new task instance
 * identifier is generated to identify task events.
 */
@property (nonatomic, copy) NSUUID *taskInstanceUUID;

/**
 * @brief Timestamp for result's generation.
 */
@property (nonatomic, copy) NSDate *timestamp;

/**
 * @brief Item identifier describing the result.
 * @note Composed in "." separated format from task, step, and possible
 * subsidiary identifiers.
 */
@property (nonatomic, copy) NSString *itemIdentifier;

/**
 * @brief Result's contentType.
 */
@property (nonatomic, copy) NSString *contentType;

/**
 * @brief Metadata about the conditions in which this result was acquired
 */
@property (nonatomic, copy) NSDictionary *metadata;


@end

/**
 * @brief Kind of result that may be changed as the task continues.
 */
@interface RKEditableResult : RKResult

@end


@interface RKFileResult : RKResult

/**
 * If ownsContainingDirectory is set, the directory containing the file will
 * be removed on dealloc.
 */
@property (nonatomic) BOOL ownsContainingDirectory;

/**
 * If ownsFile is set, the file will be removed on dealloc.
 */
@property (nonatomic) BOOL ownsFile;

/**
 * @brief URL of the file produced.
 *
 * It is the responsibility of the receiver of the result object to delete
 * the file when it is no longer needed.
 */
@property (nonatomic, copy) NSURL *fileUrl;

@end


@interface RKQuestionResult : RKEditableResult


/**
 * @brief Convenience initializer.
 * @param formItem  The formItem that produced result object.
 */
- (instancetype)initWithFormItem:(RKFormItem *)formItem ;

/**
 * @brief The question's type.
 */
@property (nonatomic) RKSurveyQuestionType questionType;

/**
 * @brief Actual answer to the question.
 *
 * Different types of question use different types of object to store the answer.
 *      Single choice type uses NSNumber to store the chosen option's index.
 *      Multiple choice type uses NSArray to store the chosen options' indexes.
 *      Boolean type uses NSNumber
 *      Text type uses NSString to store the user's input.
 *      Scale type uses NSNumber to store the marked value.
 *      Date type uses NSDateComponents to store a date value (NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay).
 *      Time type uses NSDateComponents to store a time value (NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond).
 *      DateAndTime type uses NSDateComponents to store a date-time value (NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond).
 *      Time Interval uses NSNumber to store a time span in seconds.
 *  @note All NSDateComponents values are computed using Gregorian Calendar.
 */
@property (nonatomic, copy) id answer;

@end


@interface RKFormResult : RKEditableResult

/**
 * @brief Designated initializer
 * @param questionResults Array of RKQuestionResult resulting from this form
 */
- (instancetype)initWithQuestionResults:(NSArray /* <RKQuestionResult> */ *)questionResults;

@property (nonatomic, copy) NSArray /* <RKQuestionResult> */ *formResults;

/// Convenience to look up the result for a specific form item.
- (RKQuestionResult *)resultForFormItem:(RKFormItem *)item;

@end


/**
 * @brief A combined result covering all the editable results in a task.
 */
@interface RKSurveyResult : RKResult<RKSurveyResultProvider>

/**
 * @brief Designated initializer
 * @param editableResults Array of RKEditableResult resulting from this survey, in order of answering
 */
- (instancetype)initWithEditableResults:(NSArray /* <RKEditableResult> */ *)editableResults;

@property (nonatomic, strong) NSArray /* <RKEditableResult> */ *editableResults;

/// Convenience to look up the result for a specific step.
- (RKEditableResult *)resultForStep:(RKStep *)step;

@end

