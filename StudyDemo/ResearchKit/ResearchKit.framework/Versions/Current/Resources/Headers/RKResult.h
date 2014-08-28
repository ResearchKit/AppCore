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
@interface RKResult : NSObject

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
 * @brief Item identifier describing the result
 */
@property (nonatomic, copy) RKItemIdentifier* itemIdentifier;

/**
 * @brief Result's contentType.
 */
@property (nonatomic, copy) NSString* contentType;

/**
 * @brief Device hardware information.
 */
@property (nonatomic, copy, readonly) NSString* deviceHardware;

/**
 * @brief Metadata about the conditions in which this result was acquired
 */
@property (nonatomic, copy) NSDictionary *metadata;

- (BOOL)addToArchive:(RKDataArchive *)archive error:(NSError * __autoreleasing *)error;

@end

/**
 * @brief The RKDataResult contains result data in NSData format.
 */
@interface RKDataResult : RKResult

/**
 * @brief filename to use when archiving
 */
@property (nonatomic, copy) NSString *filename;

/**
 * @brief Data object attached to the result.
 */
@property (nonatomic, copy) NSData* data;

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