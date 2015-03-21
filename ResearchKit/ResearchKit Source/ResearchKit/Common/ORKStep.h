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
#import <ResearchKit/ORKDefines.h>

ORK_ASSUME_NONNULL_BEGIN

@protocol ORKTask;

/**
 `ORKStep` is the base class for the steps that can compose a task for presentation
 in an `ORKTaskViewController`. Each `ORKStep` represents one logical piece of data
 entry or activity in a larger task.
 
 A step can be a question, an active test, or a simple instruction. Each `ORKStep`
 subclass is normally paired with an `ORKStepViewController` subclass that knows
 how to display the step.
 
 To use a step, instantiate it and populate its properties. Add it to a task,
 such as an `ORKOrderedTask`, and then present the task with an
 `ORKTaskViewController`.
 
 To implement a new step, first subclass `ORKStep` and add your additional
 properties. Then separately subclass `ORKStepViewController` and implement
 your UI. Note that if your step is timed or requires sensor data collection,
 you should consider subclassing `ORKActiveStep` and `ORKActiveStepViewController`
 instead.
 */
ORK_CLASS_AVAILABLE
@interface ORKStep : NSObject <NSSecureCoding, NSCopying>


/**
 Primary designated initializer.
 
 @param identifier   Step's unique indentifier.
 @return Returns a new `ORKStep` instance.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

/**
 Coding initializer.
 
 @param aDecoder    Coder which can be used to initialize the step.
 @return Returns a new `ORKStep` instance.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 The identifier is a short string identifying this step, and should be unique,
 at least within the task.
 
 The identifier is reproduced on the results of steps. Given an `ORKStepResult`,
 the only way to link it to the step that generated it is to look at the
 `identifier`. Therefore it is very important to keep step identifiers unique
 within a task, so that step results can be accurately identified.
 
 In some applications it may be useful to link this to a unique identifier in a
 database; in other cases it may make sense if this identifier is human
 readable.
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 A boolean value indicating whether a task can be restored to this step
 during state restoration (read-only).
 
 `ORKStep` returns `YES` by default, but subclasses may override.
 
 If a task cannot be restored to this state, then typically the task will be restored to the
 last step in the task that is restorable, or simply to the first step, if
 none are available.
 */
@property (nonatomic, readonly, getter=isRestorable) BOOL restorable;

/**
 A Boolean value indicating whether to allow the user to skip this step
 without answering.
 
 If this property is `NO`, the Skip button will not appear on this step.
 
 This property may not be meaningful for all steps; for example, active steps
 may not have a way to skip through the step, as they may need to wait for
 the timer to complete.
 
 The default value is `YES`.
 */
@property (nonatomic, getter=isOptional) BOOL optional;

/**
 The primary text for the step.
 
 This text should be localized to the current language.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *title;

/**
 Additional text for the step.
 
 The text shown in a smaller font below the `title`. For longer questions, it
 is generally better to keep the title short, and put the extended content in
 the `text` property.
 
 This text should be localized to the current language.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *text;


/**
 A weak reference to the parent task object.
 
 This is normally set when a step is added to `ORKOrderedTask`. When
 implementing a custom task, it may be helpful to set that task
 here. This is present only for convenience, and should not be relied
 upon internal to ResearchKit.
 */
@property (nonatomic, weak, ORK_NULLABLE) id<ORKTask> task;

/**
 Checks the parameters of the step and throws exceptions on invalid parameters.
 
 This method is called when there is a need to validate its parameters, typically
 when adding a step to an ORKStepViewController, and when presenting the
 step view controller.
 
 Subclasses should override this method to provide validation of their additional
 properties, and must base-call.
 */
- (void)validateParameters;

@end



ORK_ASSUME_NONNULL_END
