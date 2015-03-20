/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import <Foundation/Foundation.h>
#import <ResearchKit/ORKAnswerFormat.h>
#import <ResearchKit/ORKDefines.h>


ORK_ASSUME_NONNULL_BEGIN

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
 The `ORKResult` class defines the attributes of a result from one step or a group
 of steps. In ResearchKit, one normally obtains a result from the `result` property
 of either `ORKTaskViewController` or `ORKStepViewController`.
 Certain types of results may contain other results, expressing a hierarchy --
 these are `ORKCollectionResult` subclasses such as `ORKStepResult` and `ORKTaskResult`.
 
 When receiving a result, it can be temporarily stored by archiving it with
 `NSKeyedArchiver`, since all `ORKResult` objects implement `NSSecureCoding`. It may
 also be useful to serialize it to other formats; implementations for doing this
 exist outside of the ResearchKit framework.
 
 The result object hierarchy does not necessarily include all the data collected
 during a task. Some result objects, such as `ORKFileResult`, may refer to files
 on the filesystem which were generated during the task. These files are all
 located under the `outputDirectory` of the `ORKTaskViewController`, so they
 can all be found together without needing to walk the result hierarchy.
 
 Best practice is that, at a minimum, these files should be protected with `NSFileProtectionComplete`
 while at rest, and that any serialization of `ORKResult` written to disk should
 be similarly protected. It is also generally helpful to keep the result
 together with the referenced files during onward submission to a server back-end; it
 may be convenient to zip all data corresponding to a particular task result into
 a single compressed archive.
 
 Every object in the result hierarchy has an identifier that should correspond
 to the identifier of an object in the original step hierarchy. Similarly, every
 object will have a start date and an end date that correspond to the range of
 times during which the result was collected. For instance, for an `ORKStepResult`,
 this covers the range of time that the step view controller was visible on
 screen.
 
 When implementing a new type of step, it is usually helpful to create a new
 `ORKResult` subclass for holding that type of data, unless one already exists. This
 new result subclass would then be returned as one of the results attached to the
 step's `ORKStepResult`.
 */
ORK_CLASS_AVAILABLE
@interface ORKResult : NSObject <NSCopying, NSSecureCoding>

/**
 Convenience initializer.
 
 `ORKResult` and subclasses are normally instantiated by parts of the framework,
 such as `ORKStepViewController` or `ORKTaskViewController`, rather than in
 application code.
 
 @param identifier     The identifier for this result.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier;

/**
 A meaningful identifier for this particular result.
 
 The identifier can be used to identify the the question
 that was asked or the task that was completed to produce this result. It is
 normally copied from the originating object by the view controller or recorder
 producing it.
 
 For example, ORKTaskResult receives its identifier from an ORKTask,
 ORKStepResult receives its identifier from an ORKStep,
 and ORKQuestionResult receives its identifier from an ORKStep or ORKFormItem.
 Results generated by recorders also receive the identifier corresponding to
 that recorder.
 */
@property (nonatomic, copy) NSString *identifier;

/**
 Time when the task, step, or data collection began.
 
 The `startDate` is set by the view controller or recorder producing the result,
 to indicate when data collection started.
 
 For instantaneous items, startDate and endDate can be the same, and should
 generally correspond to the end of that instantaneous data collection.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSDate *startDate;

/**
 Time when the task, step, or data collection stopped.
 
 The `endDate` is set by the view controller or recorder producing the result,
 to indicate when data collection stopped.
 
 For instantaneous items, startDate and endDate can be the same, and should
 generally correspond to the end of that instantaneous data collection.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSDate *endDate;

/**
 Metadata about the conditions in which this result was acquired.
 
 The userInfo dictionary can be set by the view controller or recorder
 producing the result. In most cases, a new `ORKResult` subclass would
 be a better choice for passing additional information back to users of
 the framework, since use of a dictionary is less type-safe than
 typed accessors.
 
 This dictionary must contain only keys and values suitable for property
 list or JSON serialization.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSDictionary *userInfo;


@end


/**
 Identification of which button was tapped, for an `ORKTappingSample`.
 */
typedef NS_ENUM(NSInteger, ORKTappingButtonIdentifier) {
    /// Touch hit outside the two buttons.
    ORKTappingButtonIdentifierNone,
    
    /// Touch hit the left button.
    ORKTappingButtonIdentifierLeft,
    
    /// Touch hit the right button.
    ORKTappingButtonIdentifierRight
} ORK_ENUM_AVAILABLE;

/**
 The `ORKTappingSample` class represents a single tap on a button.
 
 This object records the location of the tap, which
 button was tapped, and the time the event occurred. A tapping sample is
 included on an `ORKTappingIntervalResult`, and is recorded by the
 step view controller for the corresponding task whenever a tap is
 recognized.
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKTappingSample : NSObject <NSCopying, NSSecureCoding>

/**
 A relative timestamp indicating time of the tap event.
 
 The timestamp is relative to the startDate of the `ORKResult` that includes this
 sample.
 */
@property (nonatomic, assign) NSTimeInterval timestamp;

/** 
 An enumerated value with indicates which button was tapped, if any.
 
 If this is `ORKTappingButtonIdentifierNone`, it indicates that the tap
 was near, but not inside, the one of the target buttons.
 */
@property (nonatomic, assign) ORKTappingButtonIdentifier buttonIdentifier;

/**
 The location of the tap within the step's view.
 
 These coordinates are relative to a rectangle of size corresponding to
 the `stepViewSize` on the enclosing `ORKTappingIntervalResult`.
 */
@property (nonatomic, assign) CGPoint location;

@end

/**
 The `ORKTappingIntervalResult` class records the results of the tapping interval test.
 
 This object records an array of touch samples, one for each tap, and also the geometry of the
 task at the time it was displayed, for reference in interpreting the touch
 samples.
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKTappingIntervalResult : ORKResult

/**
 Collected samples, each item is a `ORKTappingSample` object represents a
 tapping event.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSArray *samples;

/**
 The size of the bounds of the step view containing the tap targets.
 */
@property (nonatomic) CGSize stepViewSize;

/**
 The frame of the left button, in points, relative to the step view bounds.
 */
@property (nonatomic) CGRect buttonRect1;

/**
 The frame of the right button, in points, relative to the step view bounds.
 */
@property (nonatomic) CGRect buttonRect2;

@end

/**
 The `ORKSpatialSpanMemoryGameTouchSample` class represents a tap during the
 spatial span memory game.
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */

ORK_CLASS_AVAILABLE
@interface ORKSpatialSpanMemoryGameTouchSample : NSObject <NSCopying, NSSecureCoding>

/**
 A timestamp in seconds from the beginning of the game.
 */
@property (nonatomic, assign) NSTimeInterval timestamp;

/**
 The index of the target that was tapped.
 
 Normally this index is a value ranging between 0 and the number of targets,
 indicating which target was tapped.
 
 If the touch was outside any of the targets, the targetIndex is -1.
 */
@property (nonatomic, assign) NSInteger targetIndex;

/**
 A point recording the touch location in the step's view.
 */
@property (nonatomic, assign) CGPoint location;

/**
 A boolean value indicating whether the tapped target was the correct one.
 
 This property has the value `YES` if the tapped target is the correct
 one, and `NO` otherwise.
 */
@property (nonatomic, assign, getter=isCorrect) BOOL correct;

@end

/// An enumeration for describing the status of a round of the spatial span memory game.
typedef NS_ENUM(NSInteger, ORKSpatialSpanMemoryGameStatus) {
    
    /// Unknown status. The game is still in progress or has not started.
    ORKSpatialSpanMemoryGameStatusUnknown,
    
    /// Success. The user has completed the sequence.
    ORKSpatialSpanMemoryGameStatusSuccess,
    
    /// Failure. The user has completed the sequence incorrectly.
    ORKSpatialSpanMemoryGameStatusFailure,
    
    /// Timeout. The game timed out during play.
    ORKSpatialSpanMemoryGameStatusTimeout
} ORK_ENUM_AVAILABLE;

/**
 The `ORKSpatialSpanMemoryGameRecord` class is used to record the results of a
 single playable instance of the spatial span memory game.
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 
 These are found in the `records` of an `ORKSpatialSpanMemoryResult`.
 */
ORK_CLASS_AVAILABLE
@interface ORKSpatialSpanMemoryGameRecord : NSObject <NSCopying, NSSecureCoding>

/**
 An integer recording the seed for the sequence.
 
 Pass to another game, and you get the same sequence.
 */
@property (nonatomic, assign) uint32_t seed;

/**
 An array of `NSNumber` representing the sequence that was presented to the user.
 
 The sequence is a sub-array of length sequenceLength of a random permutation of integers (0..`gameSize`-1)
 */
@property (nonatomic, copy, ORK_NULLABLE) NSArray *sequence;

/**
 The size of the game.
 
 The game size is the number of targets (for example, flowers) in the game.
 */
@property (nonatomic, assign) NSInteger gameSize;

/**
 An array of `NSValue` wrapped `CGRect` recording the frames of the target
 tiles as displayed, relative to the step view.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSArray *targetRects;

/**
 An array of `ORKSpatialSpanMemoryGameTouchSample`, recording the locations
 where the user tapped during this game.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSArray *touchSamples;

/**
 An enumeration indicating whether the user completed the sequence, or, if not, why not.
 */
@property (nonatomic, assign) ORKSpatialSpanMemoryGameStatus gameStatus;

/**
 An integer recording the number of points obtained during this game toward
 the total score.
 */
@property (nonatomic, assign) NSInteger score;

@end


/**
 Result of the `ORKSpatialSpanMemoryStep`.
 
 Records the score displayed to the user, the number of games, and
 objects recording the actual game, and the user's taps in response
 to the game.
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKSpatialSpanMemoryResult : ORKResult

/**
 The score in the game.
 
 The score is an integer value that monotonically increases during the game,
 across multiple rounds.
 */
@property (nonatomic, assign) NSInteger score;

/**
 The number of games.
 
 The number of rounds that the user participated in, whether successful or
 failed, or timed out.
 */
@property (nonatomic, assign) NSInteger numberOfGames;

/**
 The number of failures.
 
 The number of rounds where the user participated, and did not correctly
 complete the sequence.
 */
@property (nonatomic, assign) NSInteger numberOfFailures;

/**
 The results of the games played.
 
 Each item in the array is an `ORKSpatialSpanMemoryGameRecord`.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSArray *gameRecords;

@end

/**
 The `ORKFileResult` is a result that references the location of a file produced
 during a task.
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize the linked file for transmission
 to the server.
 
 Active steps typically produce file results when CoreMotion or HealthKit are
 serialized to disk using `ORKDataLogger`. Audio recording also produces a file
 result.
 
 When writing a custom step, use files to report results only when the data
 would likely be too big to hold in memory for the lifetime of the task. For
 instance, fitness tasks using sensors can be quite long, and could generate
 a large number of samples. To compensate, stream the samples to disk during
 the task, and return an `ORKFileResult` in the result hierarchy, usually as a
 child of an `ORKStepResult`.
 */
ORK_CLASS_AVAILABLE
@interface ORKFileResult : ORKResult

/**
 The MIME content type of the result.
 
 For example, `@"application/json"`.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *contentType;

/**
 The URL of the file produced.
 
 It is the responsibility of the receiver of the result object to delete
 the file when it is no longer needed.
 
 The file will normally be written to the outputDirectory of the
 `ORKTaskViewController`, so it is normal to manage the archiving and/or cleanup
 of these files by archiving or deleting the entire `outputDirectory`.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSURL *fileURL;

@end


/**
 Base class for leaf results from an item with an `ORKAnswerFormat`.
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 
 See also: `ORKQuestionStep` and `ORKFormItem`.
 */
ORK_CLASS_AVAILABLE
@interface ORKQuestionResult : ORKResult

/**
 Value indicating the type of question the result came from.
 
 The `questionType` will generally correlate closely with the class, but is
 easier to switch on in Objective-C.
 */
@property (nonatomic) ORKQuestionType questionType;

@end

/**
 The `ORKScaleQuestionResult` class represents the answer to a continuous or
 discrete-valued scale answer format.
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKScaleQuestionResult : ORKQuestionResult

/**
 The answer obtained from the scale question.
 
 This property is `nil` if the user skipped the question or otherwise did not
 enter an answer.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSNumber *scaleAnswer;

@end

/**
 The `ORKChoiceQuestionResult` class represents the single or multiple choice
 answers from a choice based answer format.
 
 For example, an `ORKTextChoiceAnswerFormat` or an `ORKImageChoiceAnswerFormat`
 would produce an `ORKChoiceQuestionResult`.
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKChoiceQuestionResult : ORKQuestionResult

/**
 Array of selected values, from the `value` property of `ORKAnswerOption`.
 For single choice, the array has exactly one entry.
 
 `nil`, if the user skipped the question.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSArray *choiceAnswers;

@end

/**
 The `ORKBooleanQuestionResult` class represents the answer to a Yes/No question.
 
 It is produced by the task view controller when presenting a question or form
 item with a boolean answer format (`ORKBooleanAnswerFormat`).
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKBooleanQuestionResult : ORKQuestionResult

/** Answer. `nil` if the user skipped the question. */
@property (nonatomic, copy, ORK_NULLABLE) NSNumber *booleanAnswer;

@end

/**
 The `ORKTextQuestionResult` class represents the answer to a question or
 form item with an `ORKTextAnswerFormat`.
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKTextQuestionResult : ORKQuestionResult

/** 
 The answer that the user entered.
 
 If the user skipped the question, this property will be `nil`.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *textAnswer;

@end

/**
 Result of a question or form item with an answer format producing a numeric
 answer.
 
 Examples include `ORKScaleAnswerFormat` and `ORKNumericAnswerFormat`.
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKNumericQuestionResult : ORKQuestionResult

/// The number collected, or `nil` if the question was skipped.
@property (nonatomic, copy, ORK_NULLABLE) NSNumber *numericAnswer;

/**
 The unit string displayed to the user when the value was entered.
 
 `nil`, if no unit string was displayed.
 */
@property (nonatomic, copy) NSString *unit;

@end

/**
 The result of a question with an `ORKTimeOfDayAnswerFormat`.
 */

ORK_CLASS_AVAILABLE
@interface ORKTimeOfDayQuestionResult : ORKQuestionResult

/**
 The date components picked by the user.
 
 Normally only hour, minute, and AM/PM will be of interest.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSDateComponents *dateComponentsAnswer;

@end


/**
 The `ORKTimeIntervalQuestionResult` class represents the result of a question
 with an `ORKTimeIntervalAnswerFormat`.
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKTimeIntervalQuestionResult : ORKQuestionResult

/**
 The selected interval, in seconds.
 
 This property will be `nil` if the user skips the question.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSNumber *intervalAnswer;

@end

/**
 Result of a question or form item that asks for a date (`ORKDateAnswerFormat`).
 
 The calendar and timezone are recorded in addition to the answer itself,
 to give the answer context. Usually these correspond to the current calendar
 and timezone at the time of the activity, but may be overridden by setting
 these properties explicitly on the `ORKDateAnswerFormat`.
 */
ORK_CLASS_AVAILABLE
@interface ORKDateQuestionResult : ORKQuestionResult

/**
 The date that the user entered.
 
 `nil` if the user skipped the question.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSDate *dateAnswer;

/**
 The calendar used when selecting date and time.
 
 If the calendar in the `ORKDateAnswerFormat` was nil, this calendar is the system
 calendar at the time of data entry.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSCalendar *calendar;

/**
 The time zone that was current when selecting the date and time.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSTimeZone *timeZone;

@end


/**
 The `ORKConsentSignatureResult` class represents a signature obtained during
 an `ORKConsentReviewStep`. Usually it is found as a child result of the
 `ORKStepResult` for the `ORKConsentReviewStep`.
 
 The result can then be applied to a document to facilitate generation of a
 PDF including the signature, or for presentation in a follow-on
 consent review.
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKConsentSignatureResult : ORKResult

/**
 A copy of the signature obtained.
 
 This signature will be a copy of the signature property on the originating
 `ORKConsentReviewStep`, but will include any name or signature image collected during
 the consent review step.
 */
@property (nonatomic, copy, ORK_NULLABLE) ORKConsentSignature *signature;

/**
 Applies the signature to the consent document.
 
 Looks up the matching signature placeholder in the consent document, by
 identifier, and replaces it with this signature. May throw an exception if
 the document does not contain a signature with a matching identifier.
 
 @param document     The document to which to apply the signature.
 */
- (void)applyToDocument:(ORKConsentDocument *)document;

@end


/**
 The `ORKCollectionResult` class is a result which contains an array of
 child results.
 
 It is the superclass of `ORKTaskResult` and `ORKStepResult`.
 
 This class is not instantiated directly by ResearchKit.
 */
ORK_CLASS_AVAILABLE
@interface ORKCollectionResult : ORKResult

/**
 An array of `ORKResult` objects that are children of this result.
 
 For `ORKTaskResult`, it is an array of `ORKStepResult` objects.
 For `ORKStepResult` it is an array of concrete result objects like `ORKFileResult`
 and `ORKQuestionResult`.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSArray /* <ORKResult> */ *results;

/**
 Looks up the child result with a matching particular identifer.
 
 @param identifier Identifier of the step for which to search.
 @return Returns the matching result, or `nil` if none was found.
 */
- (ORK_NULLABLE ORKResult *)resultForIdentifier:(NSString *)identifier;

/**
 Retrieves the first result.
 
 If there are no results, returns `nil`.
 */
- (ORK_NULLABLE ORKResult *)firstResult;

@end


/**
 `ORKTaskResultSource` is the protocol for `[ORKTaskViewController defaultResultSource]`.
 */
@protocol ORKTaskResultSource <NSObject>

/**
 Returns a step result for a step identifier, if one exists.
 
 The task view controller, when about to present a step, needs to look up a
 suitable default answer.
 
 This could be used to prepopulate a survey with
 the results obtained on a previous run of the same task, by passing an
 `ORKTaskResult` (which itself implements this protocol).
 
 @param stepIdentifier Identifier for which to search.
 @return Returns the result for the specified step, or `nil` for none.
 */
- (ORK_NULLABLE ORKStepResult *)stepResultForStepIdentifier:(NSString *)stepIdentifier;

@end




/**
 An `ORKTaskResult` is a collection result, containing all the step results
 generated from one run of an `ORKTask` or `ORKOrderedTask` in an
 `ORKTaskViewController`.
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 
 The `[ORKCollectionResult results]` property contains the step results
 for this task.
 */
ORK_CLASS_AVAILABLE
@interface ORKTaskResult : ORKCollectionResult <ORKTaskResultSource>

/**
 Initializer.
 
 @param identifier      The identifier from the task that produced this result.
 @param taskRunUUID     The UUID of the run of the task that produced this result.
 @param outputDirectory The directory in which any files referenced by results
            can be found.
 @return Returns a new instance.
 
 */
- (instancetype)initWithTaskIdentifier:(NSString *)identifier
                           taskRunUUID:(NSUUID *)taskRunUUID
                       outputDirectory:(ORK_NULLABLE NSURL *)outputDirectory;


/**
 An unique identifier (UUID) for the presentation of the task that generated
 this result.
 
 Unique identifier for a run of the task controller. This normally comes directly
 from the task view controller that was used to run this task.
 */
@property (nonatomic, copy, readonly) NSUUID *taskRunUUID;

/**
 The directory where generated data files were stored while the task was run.
 
 This comes directly from the task view controller that was used to run this
 task. Generally, when archiving the results of a task, it is useful to archive
 all the files found this output directory.
 
 This file URL will also prefix the file URLs referenced in any child 
 `ORKFileResult` objects.
 */
@property (nonatomic, copy, readonly, ORK_NULLABLE) NSURL *outputDirectory;



@end


/**
 An `ORKStepResult` is a collection result produced by an `ORKStepViewController` to
 hold any child results produced by the step.
 
 This is normally generated by the framework as the task proceeds. When the task
 completes, it may be appropriate to serialize it for transmission to a server,
 or to immediately perform analysis on it.
 
 For instance, an `ORKQuestionStep` will produce an `ORKQuestionResult` that will be
 a child of the `ORKStepResult`. Similarly, an `ORKActiveStep` may produce individual
 child result objects for each of the recorder configurations that was active
 during that step.
 
 The `[ORKCollectionResult results]` property contains the step results
 for this task.
 */
ORK_CLASS_AVAILABLE
@interface ORKStepResult : ORKCollectionResult

/**
 Initializer.
 
 @param stepIdentifier      Identifier of the step.
 @param results             The array of child results. May be nil or empty
            if no results were collected.
 @return Returns a new instance.
 */
- (instancetype)initWithStepIdentifier:(NSString *)stepIdentifier results:(ORK_NULLABLE NSArray *)results;


@end


ORK_ASSUME_NONNULL_END






