// 
//  APCStepProgressBar.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
@import UIKit;

typedef NS_ENUM(NSUInteger, APCStepProgressBarStyle) {
    APCStepProgressBarStyleDefault = 0,
    APCStepProgressBarStyleOnlyProgressView
};

@interface APCStepProgressBar : UIView

@property (nonatomic, readonly) APCStepProgressBarStyle style;

@property (nonatomic, readwrite) NSUInteger numberOfSteps;

@property (nonatomic, readonly) NSUInteger completedSteps;

@property (nonatomic, readonly) UILabel *leftLabel;

@property (nonatomic, readonly) UILabel *rightLabel;

@property (nonatomic, readonly) UIProgressView *progressView;

@property (nonatomic, strong) UIColor * progressTintColor;

- (instancetype) init NS_UNAVAILABLE;

- (instancetype) initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (instancetype) initWithFrame:(CGRect)frame style:(APCStepProgressBarStyle)style;

- (void) setCompletedSteps:(NSUInteger)completedStep animation:(BOOL)animation;

@end
