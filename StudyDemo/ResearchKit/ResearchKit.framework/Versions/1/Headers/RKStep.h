//
//  RKStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RKLogicalTask;

/**
 * @brief Base class for the steps that compose a task.
 *
 * @discussion A step can be a question, an active test, or a simple instruction, and
 * is normally presented using RKStepViewController.
 */
@interface RKStep : NSObject <NSSecureCoding>

/**
 * @brief Designated initializer
 * @param identifier   Step's unique indentifier.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier;

@property (nonatomic, copy, readonly) NSString *identifier;

/**
 * @brief Weak reference to the parent task object.
 * @discussion This is normally set when a step is added to RKTask. When
 * implementing a custom logical task, it may be helpful to set that task
 * here, to ensure that results correctly include the task's identifier.
 */
@property (nonatomic, weak) id<RKLogicalTask> task;

@end
