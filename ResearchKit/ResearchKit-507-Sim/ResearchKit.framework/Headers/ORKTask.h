//
//  ORKTask.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKStep.h>
#import <ResearchKit/ORKResult.h>


typedef struct _ORKTaskProgress {
    NSUInteger current;
    NSUInteger total;
} ORKTaskProgress ORK_AVAILABLE_DECL;

ORK_EXTERN ORKTaskProgress ORKTaskProgressMake(NSUInteger current, NSUInteger total) ORK_AVAILABLE_DECL;

/**
 * @brief The ORKTask protocol defines a task to be carried out by a participant
 *   in a research study.
 *
 * @note Implement this protocol to enable dynamic selection of the steps for a given task.
 *   For simple sequential tasks, ORKOrderedTask implements this protocol.
 */
ORK_AVAILABLE_DECL
@protocol ORKTask <NSObject>

@required
/**
 * @brief Task identifier.
 * @discussion This should be a short string which identifies the task. It will be composed
 * with the step's identifier in "." separated format (<taskId>.<stepId>) when producing
 * an identifier for the results of a step.
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 * @brief Supply the step after a step, if there is any.
 * @param step             Reference step.
 * @param result   Snapshot of the current set of results, for context.
 * @discussion Use the result to determine the next step.
 * @return The step after the reference step, or nil if none.
 */
- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *)result;

/**
 * @brief Supply the step before a step.
 * @param step             Reference step.
 * @param result   Snapshot of the current set of results, for context.
 * @discussion Returning nil can prevent user to revisit previous step.
 * @return The step before the reference step, or nil if none.
 */
- (ORKStep *)stepBeforeStep:(ORKStep *)step withResult:(ORKTaskResult *)result;

@optional

/**
 * @brief Supply the step matching the provided identifier.
 * @param identifier  The identifier of the step to return.
 * @discussion Implementing this method allows state restoration of a task
 * to the particular step. Without this, ORKTaskViewController will restore
 * to the first step of the task.
 * @return The step matching the provided identifier.
 */
- (ORKStep *)stepWithIdentifier:(NSString *)identifier;

/**
 * @brief Progress of current step.
 * @param step            Reference step.
 * @param result  Snapshot of the current set of results, for context.
 * @discussion If this method is not implemented, the progress label will not show. If the returned progress has a count of 0, progress will not be displayed.
 * @return Current step's index and total number of steps.
 */
- (ORKTaskProgress)progressOfCurrentStep:(ORKStep *)step withResult:(ORKTaskResult *)result;

/**
 * @brief Set of HKObjectType to request for reading from HealthKit during this task.
 */
@property (nonatomic, copy, readonly) NSSet *requestedHealthKitTypesForReading;


@end


