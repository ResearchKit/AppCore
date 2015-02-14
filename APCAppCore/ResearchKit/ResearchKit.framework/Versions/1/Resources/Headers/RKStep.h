//
//  RKStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKDefines.h>

@protocol RKTask;

/**
 * @brief Base class for the steps that compose a task.
 *
 * @discussion A step can be a question, an active test, or a simple instruction, and
 * is normally presented using RKStepViewController.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKStep : NSObject <NSSecureCoding, NSCopying>


/**
 * @brief Create a new step
 * @param identifier   Step's unique indentifier.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, readonly) NSString *identifier;

/**
 * @brief Controls whether a task can be restored to this step during state restoration.
 * @note YES by default, but subclasses may override.
 */
@property (nonatomic, readonly, getter=isRestorable) BOOL restorable;

/**
 * @brief Allow user to skip current step with no answer.
 * @note Default value is YES.
 */
@property (nonatomic, getter=isOptional) BOOL optional;

/**
 * @brief Primary text of the step.
 */
@property (nonatomic, copy) NSString *title;

/**
 * @brief Additional text for the step.
 */
@property (nonatomic, copy) NSString *text;


/**
 * @brief Weak reference to the parent task object.
 * @discussion This is normally set when a step is added to RKOrderedTask. When
 * implementing a custom task, it may be helpful to set that task
 * here.
 */
@property (nonatomic, weak) id<RKTask> task;

@end
