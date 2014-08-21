//
//  RKRecorder.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class RKResult;
@class RKRecorder;

@protocol RKRecorderDelegate <NSObject>

/**
 * @brief Tells the delegate that the recorder is completed and pass out recording result.
 * @note The methods will be called when recording is stopped.
 */
- (void)recorder:(RKRecorder*)recorder didCompleteWithResult:(RKResult*)result;

/**
 * @brief Tells the delegate that recording failed.
 */
- (void)recorder:(RKRecorder*)recorder didFailWithError:(NSError**)error;

@end


@class RKStep;
/**
 * @brief Base class of recorders, defines common interfaces for subclasses.
 *
 * Recorders are used in active tasks to collect data from sensors on the device while the subject is interacting with it and the application is running.
 * Subclasses of RKRecorder provide different recording functionalities.
 * @note To attach a recorder to a step, just attach RKRecorderConfiguration instance to a step object,
 *  recorder instance will be generated from configuration before the step is presented by RKStepViewController.
 *  Recorder class and configuration class are paired; to create a new kind of recorder, remember to create a configuration class.
 */
@interface RKRecorder : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 * Designated initializer.
 */
- (instancetype)initWithStep:(RKStep*)step taskInstanceUUID:(NSUUID*)taskInstanceUUID;

@property (nonatomic, strong, readonly) RKStep *step;

@property (nonatomic, copy, readonly) NSUUID *taskInstanceUUID;

@property (nonatomic, weak) id<RKRecorderDelegate> delegate;

/**
 * @brief A preparation step to provide viewController and view before record starting.
 * @note Call this method before starting the recorder.
 */
- (void)viewController:(UIViewController*)viewController willStartStepWithView:(UIView*)view;

/**
 * @brief Start data recording.
 * @return If an error occurs, an NSError object that describes the problem.
 */
- (BOOL)start:(NSError * __autoreleasing *)error NS_REQUIRES_SUPER;

/**
 * @brief Stop data recording.
 * @return If an error occurs, an NSError object that describes the problem.
 */
- (BOOL)stop:(NSError * __autoreleasing *)error NS_REQUIRES_SUPER;

/**
 * @brief Recording status.
 * @return YES if recorder is recording, otherwise NO.
 */
- (BOOL)isRecording;

@end

@protocol RKSerialization;
/**
 * @brief RKRecorderConfiguration is a protocol to supply a real recorder instance.
 *
 * A recorder configuration stores the necessary configuration to instantiate a recorder.
 * @note To use a recorder in a step, just attach its matching configuration object to the step. 
 */
@protocol RKRecorderConfiguration <NSObject, RKSerialization>

/**
 * @brief Generates recorder instance.
 * @return A recorder instance
 */
- (RKRecorder*)recorderForStep:(RKStep*)step taskInstanceUUID:(NSUUID*)taskInstanceUUID;

@end

