// 
//  APCCircularProgressView.m 
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
 
#import "APCCircularProgressView.h"
#import "UIColor+APCAppearance.h"

static NSString * const kAPCCircularProgressViewAnimationKey = @"APCCircularProgressViewAnimationKey";

@interface APCCircularProgressView ()

@property (nonatomic, strong) CAShapeLayer *circularTrackLayer;
@property (nonatomic, strong) CAShapeLayer *circularProgressLayer;

@end

@implementation APCCircularProgressView

@synthesize tintColor = _tintColor;

#pragma mark - Init methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
    [self defaultValues];
    
    [self setupProgressLayers];
    [self setupProgresslabel];

    
    self.tintColor = [UIColor appTertiaryColor1];
    self.trackColor = [UIColor colorWithWhite:217/255.0f alpha:1.0];
}

- (void)defaultValues
{
    /* ivars are used since the method is called from Init method. */
    _progress = 0.0f;
    
    _animationDuration = 0.3f;
    _lineWidth = 4.0f;
    _hidesProgressValue = NO;
}

#pragma mark - Setup Sub Views/Layers

- (void)setupProgressLayers
{
    /* ivars are used since the method is called from Init method. */
    
    _circularTrackLayer = [CAShapeLayer layer];
    [_circularTrackLayer setFrame:self.bounds];
    [_circularTrackLayer setFillColor:[UIColor clearColor].CGColor];
    _circularTrackLayer.strokeColor = [UIColor grayColor].CGColor;
    [self.layer addSublayer:_circularTrackLayer];
    
    _circularProgressLayer = [CAShapeLayer layer];
    [_circularProgressLayer setFrame:self.bounds];
    [_circularProgressLayer setFillColor:[UIColor clearColor].CGColor];
    [self.layer addSublayer:_circularProgressLayer];
}

- (void)setupProgresslabel
{
    /* iVars are used since the method is called from Init method. */
    
    //Calc. frame of the largest square that fits inside the circle
    CGFloat circleDiameter = CGRectGetWidth(self.bounds) - self.lineWidth;;
    CGFloat labelFrameWidth = circleDiameter/sqrt(2.0);
    
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - labelFrameWidth)/2, (CGRectGetHeight(self.bounds) - labelFrameWidth)/2, labelFrameWidth, labelFrameWidth)];
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    _progressLabel.adjustsFontSizeToFitWidth = YES;
    [_progressLabel setTextColor:[UIColor darkGrayColor]];
    [self addSubview:_progressLabel];
    
    _progressLabel.backgroundColor = [UIColor clearColor];
    [self setProgressLabelText:0];
}

#pragma mark - View Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.circularTrackLayer.frame = self.bounds;
    self.circularTrackLayer.cornerRadius = MIN(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    self.circularTrackLayer.path = [self circularArcPath].CGPath;
    self.circularTrackLayer.lineWidth = self.lineWidth;
    
    self.circularProgressLayer.frame = self.bounds;
    self.circularProgressLayer.cornerRadius = MIN(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    self.circularProgressLayer.path = [self circularArcPath].CGPath;
    self.circularProgressLayer.lineWidth = self.lineWidth;
    
    self.progressLabel.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    
    self.progressLabel.textColor = (self.progress == 0) ? self.trackColor : self.tintColor;
}

- (UIBezierPath *)circularArcPath
{
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    CGFloat radius = MIN(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2) - self.lineWidth/2;
    
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = 3*M_PI_2;
    
    UIBezierPath *circularArcBezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    return circularArcBezierPath;
}

#pragma mark - Public Accessors

#pragma mark Tint/Track Color

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    self.circularProgressLayer.strokeColor = tintColor.CGColor;
}

- (void)setTrackColor:(UIColor *)trackColor
{
    _trackColor = trackColor;
    self.circularTrackLayer.strokeColor = trackColor.CGColor;
}

#pragma mark Line Width

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    
    self.circularTrackLayer.lineWidth = lineWidth;
    self.circularProgressLayer.lineWidth = lineWidth;
}

- (void)setHidesProgressValue:(BOOL)hidesProgressValue
{
    _hidesProgressValue = hidesProgressValue;
    self.progressLabel.hidden = hidesProgressValue;
}

#pragma mark - Progress

- (void)setProgressLabelText:(CGFloat)progress
{
    NSUInteger progressPercent = progress * 100;
    
    NSString *progressText = [NSString stringWithFormat:@"%lu%%", (unsigned long)progressPercent];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:progressText];
    NSUInteger length = attributedString.length;
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:14.0f]} range:NSMakeRange(length-1, 1)];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:39.0f]} range:NSMakeRange(0, length-1)];
    _progressLabel.attributedText = attributedString;
}

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:NO];
}

-(void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    progress = MAX(0.0, MIN(1.0, progress));
    
    if (progress != _progress) {
        
        if (animated) {
            [self animateLayerForProgress:progress];
            _progress = progress;
        } else {
            [self updateStrokeEndForProgress:progress];
            _progress = progress;
            
            [self setProgressLabelText:progress];
            
            
           
        }
    }
    
    self.progressLabel.textColor = (progress == 0) ? self.trackColor : self.tintColor;
}

- (void)updateStrokeEndForProgress:(CGFloat)progress
{
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
    self.circularProgressLayer.strokeEnd = progress;
    [CATransaction commit];
}

#pragma mark - Animations

- (void)animateLayerForProgress:(CGFloat)progress
{
    CABasicAnimation *progressAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    progressAnimation.duration = self.animationDuration;
    progressAnimation.fromValue = @(self.progress);
    progressAnimation.toValue = @(progress);
    progressAnimation.delegate = self;
    progressAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.circularProgressLayer addAnimation:progressAnimation forKey:kAPCCircularProgressViewAnimationKey];
    
}

#pragma mark - CAAnimationDelegate methods

- (void)animationDidStop:(CAAnimation *) __unused anim finished:(BOOL) __unused flag
{
    [self updateStrokeEndForProgress:_progress];

    [self setProgressLabelText:_progress];
}

@end
