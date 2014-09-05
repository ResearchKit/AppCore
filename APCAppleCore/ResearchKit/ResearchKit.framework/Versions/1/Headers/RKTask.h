//
//  RKTask.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKStep.h>
#import <ResearchKit/RKSerialization.h>

/**
 * @brief The RKLogicalTask protocol defines necessary methods describing a task object.
 *
 * RKLogicalTask supplies identifier, name , and steps to RKtaskViewController.
 * @note Implement this protocol to enable dynamic selection of the steps for a given task.
 */
@protocol RKLogicalTask <NSObject>

@required
/**
 * @brief Task unique identifier
 */
- (NSString *)identifier;

/**
 * @brief Task's name
 */
- (NSString *)name;

/**
 * @brief Supply one step after a step, if there is any.
 * @param step    Reference step.
 * @param surveyResults   Collected survey results til now (keys are step identifiers), which assist dynamic selection of the steps.
 * @discussion Use surveyResults to determine next step.
 * @return A step after reference step, if there is none return nil.
 */
- (RKStep *)stepAfterStep:(RKStep *)step withSurveyResults:(NSDictionary *)surveyResults;

/**
 * @brief Supply one step before a step, if there is any.
 * @param step    Reference step.
 * @param surveyResults   Collected survey results til now (keys are step identifiers), which assist dynamic selection of the steps.
 * @discussion Return nil can prevent user to revisit previous step.
 * @return A step before reference step, if there is none return nil.
 */
- (RKStep *)stepBeforeStep:(RKStep *)step withSurveyResults:(NSDictionary *)surveyResults;

@end


/**
 * @brief Default implementation of RKLogicalTask.
 *
 * RKTask can be preconfigured with name, identifier, and an array of steps in fixed order.
 * RKTask always make its steps appear in fixed order.
 */

@interface RKTask : NSObject <RKLogicalTask, RKSerialization>

/**
 * @brief Designated initializer
 * @param name    Task's name.
 * @param identifier  Task's unique indentifier.
 * @param steps   An array of steps in fixed order.
 */

-(instancetype)initWithName:(NSString *)name
                 identifier:(NSString *)identifier
                      steps:(NSArray *)steps;

@property (nonatomic, copy, readonly) NSArray *steps;

@end
