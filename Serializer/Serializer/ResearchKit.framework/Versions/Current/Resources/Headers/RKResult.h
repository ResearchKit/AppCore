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
/**
 * @brief The RKResult class defines the attributes of a result from one step or a group of steps.
 *
 * A result may be produced either directly in a step or task view controller, or by an RKRecorder subclass.
 */
@interface RKResult : NSObject <NSSecureCoding>

/**
 * @brief Produce a recorder with taskInstanceUUID, taskItemId, and stepItemId filled in
 *
 */
+ (instancetype)resultForRecorder:(RKRecorder*)recorder;

/**
 * @brief Step initializer
 * Pick up itemIdentifier/taskIdentifier from step object during initialization.
 * @param step    The step produced result object.
 */
- (instancetype)initWithStep:(RKStep*)step;

/**
 * @brief Unique task instance identifier.
 * 
 * Each time a task is presented to participant, a new task instance identifier is generated to identify task events.
 */
@property (nonatomic, strong) NSUUID* taskInstanceUUID;

/**
 * @brief Timestamp of result's generation.
 */
@property (nonatomic, copy) NSDate* timestamp;

/**
 * @brief Identifier of study.
 */
@property (nonatomic, copy) NSString* studyIdentifier;

/**
 * @brief Result producer's task identifier.
 */
@property (nonatomic, copy) NSString* taskIdentifier;

/**
 * @brief Result producer's step identifier.
 */
@property (nonatomic, copy) NSString* stepIdentifier;

/**
 * @brief Result's data type.
 */
@property (nonatomic, copy) NSString* dataType;

/**
 * @brief Result's contentType.
 */
@property (nonatomic, copy) NSString* contentType;

/**
 * @brief Suggested name for result file.
 */
@property (nonatomic, copy) NSString* filename;

/**
 * @brief Device hardware information.
 */
@property (nonatomic, copy, readonly) NSString* deviceHardware;

/**
 * @brief Convenience method to generate itemIdentifier from taskIdentifier and stepIdentifier
 */
- (RKItemIdentifier *)itemIdentifier;

/**
 * @brief Produce dataArchive instance.
 */
- (RKDataArchive *)dataArchive;

@end

/**
 * @brief The RKDataResult contains result data in NSData format.
 */
@interface RKDataResult : RKResult

/**
 * @brief Data object attached to the result.
 */
@property (nonatomic, copy) NSData* data;

@end


/**
 * @brief The RKQuestionResult class defines the attributes of a question result.
 */
@interface RKQuestionResult : RKResult

/**
 * @brief Question's type.
 */
@property (nonatomic) RKSurveyQuestionType questionType;

/**
 * @brief Actual answer to the question.
 *
 * Different types of question use different types of object to store the answer.
 *      Single choice type use NSNumber to store the chosen option's index.
 *      Mutiple choice type use NSArray to store the chosen options' indexes.
 *      Text type use NSString to store user's input.
 *      Scale type use NSNumber to store marked value.
 *      Date type use NSString to store a date value in format of "yyyy-MM-dd".
 *      Time type use NSString to store a time value in format of "HH:mm:ss".
 *      DateAndTime type use NSString to store a date-time value in format of "yyyy-MM-dd'T'HH:mm:ssZ".
 *      Time Interval use NSNumber to store a time span in seconds.
 */
@property (nonatomic, strong) NSObject* answer;

@end


/**
 * @brief Reports data from an RKAccelerometerRecorder (CMAccelerometerData)
 */
@interface RKAccelerometerResult : RKResult

/**
 * @brief Accelerometer sampling frequency in Hz.
 */
@property (nonatomic) double frequency;

/**
 * @brief A list of CMAccelerometerData objects collected over a mount of time by RKAccelerometerRecorder.
 */
@property (nonatomic, copy) NSArray* dataArray;

@end

/**
 * @brief Reports data from an RKDeviceMotionRecorder (CMDeviceMotion).
 */
@interface RKDeviceMotionResult : RKResult

/**
 * @brief Device motion sampling frequency in Hz.
 */
@property (nonatomic) double frequency;

/**
 * @brief A list of CMDeviceMotion collected over a mount of time by RKDeviceMotionRecorder.
 */
@property (nonatomic, copy) NSArray* dataArray;

@end

/**
 * @brief The RKTouchResult class defines the attributes of touch events data result.
 */
@interface RKTouchResult : RKResult

/**
 * @brief A list of NSDictionary objects for each captured touch event.
 */
@property (nonatomic, copy) NSArray* dataArray;

@end

/**
 * @brief The RKConsentResult class defines the attributes of consent step result.
 */
@interface RKConsentResult : RKResult

@property (nonatomic, copy) NSString* signatureName;
@property (nonatomic, copy) NSString* signatureDate;

@end

/**
 * @brief The RKSurveyResult class defines the attributes of survey answers result.
 */
@interface RKSurveyResult : RKResult

- (instancetype)initWithSurveyResults:(NSDictionary *)surveyResults;

/**
 * @brief A dictionary contains all question anwsers.
 * 
 * Keys are step identifiers.
 * Values are RKStepQuestionResult objects.
 */
@property (nonatomic, strong) NSDictionary *surveyResults;

@end