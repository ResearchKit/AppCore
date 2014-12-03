//
//  RKSTInstructionStepViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

typedef NS_ENUM(NSInteger, RKSTInstructionStepViewControllerLayoutStyle) {
    RKSTInstructionStepViewControllerLayoutStyleButtonBelowTitle,
    RKSTInstructionStepViewControllerLayoutStyleButtonAtBottom
};

@interface RKSTInstructionStepViewController : RKSTStepViewController


/**
 * Add a custom view to the step. Use constraints or sizeThatFits:
 * to request the size needed.
 *
 */
@property (nonatomic, strong) UIView *customView;

@property (nonatomic) RKSTInstructionStepViewControllerLayoutStyle layoutStyle;

@end
