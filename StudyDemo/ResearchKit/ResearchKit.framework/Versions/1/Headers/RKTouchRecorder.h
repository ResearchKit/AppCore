//
//  RKTouchRecorder.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/RKRecorder.h>

/**
 * @brief The RKTouchRecorder class defines the attributes and behavior of touch events recorder.
 *
 * Just add its customView to view hierarchy to allow the recorder to receive touch events.
 */
@interface RKTouchRecorder : RKRecorder

/**
 * @brief The RKTouchRecorder attach gesture recognizer to touchView to receive touch events.
 * @note Use (viewController:willStartStepWithView:) to set this.
 */
@property (nonatomic, strong, readonly) UIView* touchView;

@end

/**
 * @brief RKTouchRecorderConfiguration implements RKRecorderConfiguration and able to generate RKTouchRecorder instance.
 */
@interface RKTouchRecorderConfiguration: NSObject<RKRecorderConfiguration>

+ (instancetype)configuration;

@end





