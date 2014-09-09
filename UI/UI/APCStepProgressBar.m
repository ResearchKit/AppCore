//
//  APCStepProgressBar.m
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCStepProgressBar.h"
#import "APCStepProgressBar+AppearanceCategory.h"

static CGFloat const kAPCStepProgressBarControlsMinMargin   = 10;

@implementation APCStepProgressBar

- (instancetype) initWithFrame:(CGRect)frame style:(APCStepProgressBarStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        
        _style = style;
        
        _progressView = [UIProgressView new];
        [self addSubview:_progressView];
        
        if (self.style == APCStepProgressBarStyleDefault) {
            _leftLabel = [UILabel new];
            [self addSubview:_leftLabel];
            
            _rightLabel = [UILabel new];
            [self addSubview:_rightLabel];
        }
        
        [self applyStyle];
    }
    return self;
}

- (void) applyStyle {
    CGRect frame = self.bounds;
    
    if (self.style == APCStepProgressBarStyleDefault) {
        CGFloat availableWidth = self.bounds.size.width - (2 * kAPCStepProgressBarControlsMinMargin);
        
        {
            frame.size.width = availableWidth * 0.75;
            frame.origin.x = kAPCStepProgressBarControlsMinMargin;
            
            self.leftLabel.frame = frame;
            self.leftLabel.font = [APCStepProgressBar leftLabelFont];
            self.leftLabel.textColor = [APCStepProgressBar leftLabelTextColor];
        }

        {
            frame.origin.x = CGRectGetMaxX(frame);
            frame.size.width = availableWidth * 0.25;
            
            self.rightLabel.frame = frame;
            self.rightLabel.font = [APCStepProgressBar rightLabelFont];
            self.rightLabel.textColor = [APCStepProgressBar rightLabelTextColor];
            self.rightLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    
    if (self.style == APCStepProgressBarStyleOnlyProgressView) {
        frame = self.bounds;
    }
    else {
        frame = CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1);
    }
    
    self.progressView.frame = frame;
    self.progressView.trackTintColor = [APCStepProgressBar progressBarTrackTintColor];
    self.progressView.progressTintColor = [APCStepProgressBar progressBarProgressTintColor];
}

- (void) setCompletedSteps:(NSUInteger)completedStep animation:(BOOL)animation {
    _completedSteps = completedStep;
    
    CGFloat progress = (CGFloat)completedStep/self.numberOfSteps;
    
    [self.progressView setProgress:progress animated:animation];
}

@end
