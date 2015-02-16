//
//  ORKRecorder_Private.h
//  ResearchKit
//
//  Created by John Earl on 10/29/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/ORKRecorder.h>


@class ORKStep;

/**
 * @brief ORKTouchRecorderConfiguration implements ORKRecorderConfiguration and able to generate ORKTouchRecorder instance.
 */
ORK_CLASS_AVAILABLE
@interface ORKTouchRecorderConfiguration: ORKRecorderConfiguration

+ (instancetype)configuration;

@end


@interface ORKRecorder()

- (instancetype)_init;

- (instancetype)initWithStep:(ORKStep*)step
             outputDirectory:(NSURL *)outputDirectory;


/**
 * @brief A preparation step to provide viewController and view before record starting.
 * @note Call this method before starting the recorder.
 */
- (void)viewController:(UIViewController*)viewController willStartStepWithView:(UIView*)view;

/**
 * @brief Recording has failed; stop recording and report the error to the delegate
 */
- (void)finishRecordingWithError:(NSError *)error;

- (void)_applyFileProtection:(ORKFileProtectionMode)fileProtection toFileAtURL:(NSURL *)url;

@end


@interface ORKRecorderConfiguration()

- (instancetype)_init;

- (ORKPermissionMask)requestedPermissionMask;


@end















