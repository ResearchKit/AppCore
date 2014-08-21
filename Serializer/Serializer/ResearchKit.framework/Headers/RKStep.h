//
//  RKStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKSerialization.h>

@protocol RKLogicalTask;

/**
 * @brief The RKStep class defines the attributes and behavior of a step appears in RKStepViewController.
 *
 * Step is a sub unit of task, usually one task contains more than one step.
 * Step can be a question, an active test, or a simple instruction.
 */
@interface RKStep : NSObject <RKSerialization>

/**
 * @brief Designated initializer
 * @param identifier   Step's unique indentifier.
 * @param name    Step's name.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier name :(NSString *)name;

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *name;

/**
 * @brief Weak reference to task object, enable program to access task's infomation from a step object.
 */
@property (nonatomic, weak) id<RKLogicalTask> task;

@end
