// 
//  APCStepProgressBar.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "UIView+Helper.h"
#import "APCStepProgressBar.h"
#import "APCStepProgressBar+Appearance.h"
#import "UIColor+APCAppearance.h"

static CGFloat const kAPCStepProgressBarControlsMinMargin   = 10;
//static CGFloat const kAPCStepProgressBarHeight = 14.0f;

static NSString * const kAPCStepProgressViewAnimationKey = @"APCStepProgressViewAnimationKey";

@interface APCStepProgressBar()

@property (nonatomic, strong) CAShapeLayer *stepTrackLayer;
@property (nonatomic, strong) CAShapeLayer *stepProgressLayer;

@property (nonatomic, readwrite) APCStepProgressBarStyle style;

@end

@implementation APCStepProgressBar

#pragma mark - Init methods

- (instancetype) initWithFrame:(CGRect)frame style:(APCStepProgressBarStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _style = style;
        
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _numberOfSteps = 1;
    
    [self setupProgressLayers];
    
    if (self.style == APCStepProgressBarStyleDefault) {
        [self setupInfoLabels];
    }
    
    [self layoutSubviews];
}

- (void)setupProgressLayers
{
    /* ivars are used since the method is called from Init method. */
    
    _stepTrackLayer = [CAShapeLayer layer];
    _stepTrackLayer.frame = self.bounds;
    [_stepTrackLayer setFillColor:[APCStepProgressBar progressBarTrackTintColor].CGColor];
    [self.layer addSublayer:_stepTrackLayer];
    
    _stepProgressLayer = [CAShapeLayer layer];
    _stepProgressLayer.frame = self.bounds;
    [_stepProgressLayer setFillColor:[UIColor appTertiaryColor1].CGColor];
    [self.layer addSublayer:_stepProgressLayer];
}

- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    _progressTintColor = progressTintColor;
    [_stepProgressLayer setFillColor:progressTintColor.CGColor];
}

- (void)setupInfoLabels
{
    _leftLabel = [UILabel new];
    _leftLabel.font = [APCStepProgressBar leftLabelFont];
    _leftLabel.textColor = [APCStepProgressBar leftLabelTextColor];
    [self addSubview:_leftLabel];
    
    _rightLabel = [UILabel new];
    _rightLabel.font = [APCStepProgressBar rightLabelFont];
    _rightLabel.textColor = [APCStepProgressBar rightLabelTextColor];
    _rightLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_rightLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat availableHeight = self.innerHeight;
    
    if (availableHeight < 20.0) {
        self.style = APCStepProgressBarStyleOnlyProgressView;
        
        _stepTrackLayer.frame = self.bounds;
        _stepTrackLayer.path = [UIBezierPath bezierPathWithRect:_stepTrackLayer.bounds].CGPath;
        
        CGFloat progressWidth = self.innerWidth * ((CGFloat)self.completedSteps/self.numberOfSteps);
        _stepProgressLayer.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), progressWidth, self.innerHeight);
        _stepProgressLayer.path = [UIBezierPath bezierPathWithRect:_stepProgressLayer.bounds].CGPath;
        
    } else {
        
        CGRect progressFrame = self.bounds;
        progressFrame.size.height = availableHeight * 0.35;
        progressFrame.origin.y = CGRectGetMaxY(self.bounds) - progressFrame.size.height;
        
        _stepTrackLayer.frame = progressFrame;
        _stepTrackLayer.path = [UIBezierPath bezierPathWithRect:_stepTrackLayer.bounds].CGPath;
        
        CGFloat progressWidth = self.innerWidth * ((CGFloat)self.completedSteps/self.numberOfSteps);
        _stepProgressLayer.frame = progressFrame;
        _stepProgressLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, progressWidth, CGRectGetHeight(progressFrame))].CGPath;
        
        CGFloat availableWidth = self.innerWidth - (2 * kAPCStepProgressBarControlsMinMargin);
        
        {
            CGRect labelFrame = self.bounds;
            labelFrame.origin.x = kAPCStepProgressBarControlsMinMargin;
            labelFrame.size.height = availableHeight * 0.65;
            labelFrame.size.width = availableWidth * 0.75;
            self.leftLabel.frame = labelFrame;
        }
        
        {
            CGRect labelFrame = self.bounds;
            labelFrame.origin.x = kAPCStepProgressBarControlsMinMargin + availableWidth * 0.75;
            labelFrame.size.height = availableHeight * 0.65;
            labelFrame.size.width = availableWidth * 0.25;
            self.rightLabel.frame = labelFrame;
        }
        
    }
}

- (void) setCompletedSteps:(NSUInteger)completedStep animation:(BOOL)animation {
    
    if (completedStep != _completedSteps) {
        _completedSteps = completedStep;
        
        CGFloat progressWidth = self.innerWidth * ((CGFloat)self.completedSteps/self.numberOfSteps);
        
        UIBezierPath *newPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, progressWidth, CGRectGetHeight(self.stepProgressLayer.bounds))];
        
        if (animation) {
            CABasicAnimation *progressAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            progressAnimation.duration = 0.3f;
            progressAnimation.fromValue = (id)self.stepProgressLayer.path;
            progressAnimation.toValue = (id)newPath.CGPath;
            progressAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            progressAnimation.fillMode = kCAFillModeForwards;
            progressAnimation.removedOnCompletion = NO;
            [self.stepProgressLayer addAnimation:progressAnimation forKey:kAPCStepProgressViewAnimationKey];
        }
            self.stepProgressLayer.path = newPath.CGPath;
        
    }    
}

@end
