//
//  RKTask.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKStep.h>

@protocol RKSurveyResultProvider;


typedef struct _RKTaskProgress {
    NSUInteger index;
    NSUInteger count;
} RKTaskProgress;


/**
 * @brief The RKLogicalTask protocol defines a task to be carried out by a participant
 *   in a research study.
 *
 * @note Implement this protocol to enable dynamic selection of the steps for a given task.
 *   For simple linear tasks, RKTask implements this protocol.
 */
@protocol RKLogicalTask <NSObject>

@required
/**
 * @brief Task identifier.
 * @discussion This should be a short string which identifies the task. It will be composed
 * with the step's identifier in "." separated format (<taskId>.<stepId>) when producing
 * an identifier for the results of a step.
 */
- (NSString *)identifier;

/**
 * @brief Supply the step after a step, if there is any.
 * @param step             Reference step.
 * @param resultProvider   Provider of the current set of editable results, for context.
 * @discussion Use surveyResults to determine next step.
 * @return The step after the reference step, or nil if none.
 */
- (RKStep *)stepAfterStep:(RKStep *)step withResultProvider:(id<RKSurveyResultProvider>)resultProvider;

/**
 * @brief Supply the step before a step.
 * @param step             Reference step.
 * @param resultProvider   Provider of the current set of editable results, for context.
 * @discussion Returning nil can prevent user to revisit previous step.
 * @return The step before the reference step, or nil if none.
 */
- (RKStep *)stepBeforeStep:(RKStep *)step withResultProvider:(id<RKSurveyResultProvider>)resultProvider;

@optional

/**
 * @brief Progress of current step.
 * @param step            Reference step.
 * @param resultProvider  Provider of the current set of editable results, for context.
 * @discussion If this method is not implemented, the progress label will not show. If the returned progress has a count of 0, progress will not be displayed.
 * @return Current step's index and total number of steps.
 */
- (RKTaskProgress)progressOfCurrentStep:(RKStep *)step withResultProvider:(id<RKSurveyResultProvider>)resultProvider;

/**
 * @brief Set of HKObjectType to request for reading from HealthKit during this task.
 */
- (NSSet *)requestedHealthTypesForReading;

@end


/**
 * @brief Simple implementation of RKLogicalTask, where all steps are presented in order.
 */
@interface RKTask : NSObject <RKLogicalTask, NSSecureCoding>

/**
 * @brief Designated initializer
 * @param identifier  Task's unique indentifier.
 * @param steps       An array of steps in fixed order.
 */

-(instancetype)initWithIdentifier:(NSString *)identifier
                            steps:(NSArray *)steps;

@property (nonatomic, copy, readonly) NSArray *steps;

@end
