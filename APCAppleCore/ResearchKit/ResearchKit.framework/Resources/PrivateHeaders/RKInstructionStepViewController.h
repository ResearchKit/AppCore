//
//  RKInstructionStepViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

typedef NS_ENUM(NSInteger, RKInstructionStepViewControllerLayoutStyle) {
    RKInstructionStepViewControllerLayoutStyleButtonBelowTitle,
    RKInstructionStepViewControllerLayoutStyleButtonAtBottom
};

@interface RKInstructionStepViewController : RKStepViewController


/**
 * Add a custom view to the step. Use constraints or sizeThatFits:
 * to request the size needed.
 *
 */
@property (nonatomic, strong) UIView *customView;

@property (nonatomic) RKInstructionStepViewControllerLayoutStyle layoutStyle;

@end
