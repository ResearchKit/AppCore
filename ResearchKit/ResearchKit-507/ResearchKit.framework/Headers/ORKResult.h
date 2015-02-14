//
//  ORKResult.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ORKAnswerFormat.h>
#import <ResearchKit/ORKDefines.h>

@class ORKRecorder;
@class ORKStep;
@class ORKQuestionStep;
@class ORKFormItem;
@class ORKFormStep;
@class ORKConsentReviewStep;
@class ORKQuestionResult;
@class ORKConsentSignature;
@class ORKConsentDocument;
@class ORKConsentSignatureResult;
@class ORKStepResult;

/**
 * @brief The ORKResult class defines the attributes of a result from one step or a group of steps.
 *
 * A result may be produced either directly in a step or task view controller, or by an ORKRecorder subclass.
 */
ORK_CLASS_AVAILABLE
@interface ORKResult : NSObject<NSCopying, NSSecureCoding>

- (instancetype)initWithIdentifier:(NSString *)identifier;

/**
 * @brief A meaningful identifier for this particular result.
 * @discussion ORKTaskResult receives identifier from ORKTask, ORKStepResult receives identifier from ORKStep,
 * and ORKQuestionResult receives identifier from ORKStep or ORKFormItem, etc.
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



typedef NS_ENUM(NSInteger, ORKTappingButtonIdentifier) {
    ORKTappingButtonIdentifierNone,                  // Touch hit outside the two buttons.
    ORKTappingButtonIdentifierLeft,
    ORKTappingButtonIdentifierRight
} ORK_ENUM_AVAILABLE;

ORK_CLASS_AVAILABLE
@interface ORKTappingSample : NSObject<NSCopying, NSSecureCoding>

/**
 * @brief Between 0 and duration end.
 */
@property (nonatomic, assign) NSTimeInterval timestamp;

@property (nonatomic, assign) ORKTappingButtonIdentifier buttonIdentifier;

/**
 * @brief Tapping location in step's view
 */
@property (nonatomic, assign) CGPoint location;

@end

/**
 * @brief The ORKTappingIntervalResult contains result data from tapping interval test.
 */
ORK_CLASS_AVAILABLE
@interface ORKTappingIntervalResult : ORKResult

/**
 * @brief Collected samples, each item is a ORKTappingSample object represents a tapping event.
 */
@property (nonatomic, copy) NSArray *samples;

/**
 * @brief button's rectangles and base view's size
 */
@property (nonatomic) CGSize stepViewSize;

@property (nonatomic) CGRect buttonRect1;

@property (nonatomic) CGRect buttonRect2;

@end

ORK_CLASS_AVAILABLE
@interface ORKSpatialSpanMemoryGameTouchSample : NSObject<NSCopying, NSSecureCoding>

/**
 * @brief Between 0 and duration end.
 */
@property (nonatomic, assign) NSTimeInterval timestamp;

/**
 * @brief Tapped target's index. Value -1 for none of the targets are tapped.
 */
@property (nonatomic, assign) NSInteger targetIndex;

/**
 * @brief Touch location in step's view
 */
@property (nonatomic, assign) CGPoint location;

/**
 * @brief Whether tapped target is the correct one.
 */
@property (nonatomic, assign, getter=isCorrect) BOOL correct;

@end

typedef NS_ENUM(NSInteger, ORKSpatialSpanMemoryGameStatus) {
    ORKSpatialSpanMemoryGameStatusUnknown,
    ORKSpatialSpanMemoryGameStatusSuccess,
    ORKSpatialSpanMemoryGameStatusFailure,
    ORKSpatialSpanMemoryGameStatusTimeout
} ORK_ENUM_AVAILABLE;

ORK_CLASS_AVAILABLE
@interface ORKSpatialSpanMemoryGameRecord : NSObject<NSCopying, NSSecureCoding>

/**
 * @brief Seed for the sequence. Pass to another game, and you get the same game
 */
@property (nonatomic, assign) uint32_t seed;

/**
 * @brief The sequence is a sub-array of length sequenceLength of a random permutation of integers (0..gameSize-1)
 */
@property (nonatomic, copy) NSArray *sequence;

/**
 * @brief Number of targets in the game
 */
@property (nonatomic, assign) NSInteger gameSize;

/**
 * @brief A array of target tiles' frame in step view ordered by target index
 */
@property (nonatomic, copy) NSArray *targetRects;

/**
 * @brief A array of ORKSpatialSpanMemoryGameTouchSample
 */
@property (nonatomic, copy) NSArray *touchSamples;

@property (nonatomic, assign) ORKSpatialSpanMemoryGameStatus gameStatus;

/**
 * @brief Score for this game
 */
@property (nonatomic, assign) NSInteger score;

@end


ORK_CLASS_AVAILABLE
@interface ORKSpatialSpanMemoryResult : ORKResult

@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger numberOfGames;
@property (nonatomic, assign) NSInteger numberOfFailures;

/**
 * @brief Results of the games played.
 * Each item is an ORKSpatialSpanMemoryGameRecord.
 */
@property (nonatomic, copy) NSArray *gameRecords;

@end


ORK_CLASS_AVAILABLE
@interface ORKFileResult : ORKResult

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
 * @brief Base class for leaf results from an item with an ORKAnswerFormat.
 * @seealso ORKQuestionStep, ORKFormItem.
 */
ORK_CLASS_AVAILABLE
@interface ORKQuestionResult : ORKResult

@property (nonatomic) ORKQuestionType questionType;

@end

ORK_CLASS_AVAILABLE
@interface ORKScaleQuestionResult : ORKQuestionResult

@property (nonatomic, copy) NSNumber *scaleAnswer;

@end

ORK_CLASS_AVAILABLE
@interface ORKChoiceQuestionResult : ORKQuestionResult

/**
 * @brief Array of selected values, from ORKAnswerOption's `value` property.
 * For single choice, the array will have only one entry.
 */
@property (nonatomic, copy) NSArray *choiceAnswers;

@end

ORK_CLASS_AVAILABLE
@interface ORKBooleanQuestionResult : ORKQuestionResult

@property (nonatomic, copy) NSNumber *booleanAnswer;

@end

ORK_CLASS_AVAILABLE
@interface ORKTextQuestionResult : ORKQuestionResult

@property (nonatomic, copy) NSString *textAnswer;

@end

ORK_CLASS_AVAILABLE
@interface ORKNumericQuestionResult : ORKQuestionResult

@property (nonatomic, copy) NSNumber *numericAnswer;

/**
 * @brief Unit string displayed to the user as the value was entered
 */
@property (nonatomic, copy) NSString *unit;

@end

ORK_CLASS_AVAILABLE
@interface ORKTimeOfDayQuestionResult : ORKQuestionResult

@property (nonatomic, copy) NSDateComponents *dateComponentsAnswer;

@end

ORK_CLASS_AVAILABLE
@interface ORKTimeIntervalQuestionResult : ORKQuestionResult

@property (nonatomic, copy) NSNumber *intervalAnswer; // Interval in seconds

@end

ORK_CLASS_AVAILABLE
@interface ORKDateQuestionResult : ORKQuestionResult

@property (nonatomic, copy) NSDate *dateAnswer;

/**
 * @brief Calendar used when selecting date and time.
 *  If developer specified nil in ORKAnswerFormat, this calendar is user's default.
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
ORK_CLASS_AVAILABLE
@interface ORKConsentSignatureResult : ORKResult

@property (nonatomic, copy) ORKConsentSignature *signature;

- (void)applyToDocument:(ORKConsentDocument *)document;

@end



ORK_CLASS_AVAILABLE
@interface ORKCollectionResult : ORKResult

/**
 *  @brief An array of ORKResult objects.
 *  @discussion For ORKTaskResult, it is an array of ORKStepResult objects.
 *  For ORKStepResult it is an array of concrete result objects like: ORKFileResult/ORKQuestionResult.
 */
@property (nonatomic, copy) NSArray /* <ORKResult> */ *results;

/**
 *  @brief Convenience method to lookup a result with a particular identifer.
 */
- (ORKResult *)resultForIdentifier:(NSString *)identifier;

/**
 *  @brief Convenience method to get first result object from results array, if there is one.
 */
- (ORKResult *)firstResult;

@end


@protocol ORKTaskResultSource <NSObject>

/**
 *  @brief Return the result for the specified step, or nil for none.
 */
- (ORKStepResult *)stepResultForStepIdentifier:(NSString *)stepIdentifier;

@end




/**
 * @brief ORKTaskResult containing all results generated from one run of ORKTaskViewController.
 */
ORK_CLASS_AVAILABLE
@interface ORKTaskResult: ORKCollectionResult <ORKTaskResultSource>


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
 * @brief ORKStepResult containing all results from one step.
 */
ORK_CLASS_AVAILABLE
@interface ORKStepResult: ORKCollectionResult


- (instancetype)initWithStepIdentifier:(NSString *)stepIdentifier results:(NSArray *)results;


@end








